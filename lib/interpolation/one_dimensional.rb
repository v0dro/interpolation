#--
# = Interpolation 
# Copyright (c) 2014, Sameer Deshmukh
# All rights reserved.
#   
# Interpolation is a library for executing various interpolation 
# functions in Ruby.
# 
# == spec/lib/1d_interpolation_spec.rb
#
# Tests for 1D interpolation.
#++

$:.unshift File.dirname(__FILE__)

require 'base.rb'

module Interpolation

  # Implements one dimensional interpolation routines.
  # 
  # ==== Usage
  # 
  # x = (1..10).step(1).to_a
  # y = x.exp
  # 
  # f = Interpolation::OneDimensional.new x, y, {kind: :linear, sorted: true}
  # i = f.interpolate 2.5
  # 
  # puts "Interpolated value for 2.5 is #{i}"
  class OneDimensional < Interpolation::Base

    # Constructor for all One Dimensional interpolation operations.
    # 
    # The function values to be supplied to this class are of the form y = f(x). 
    # 
    # Henceforth, y will be referred to as ordinate and x as absicca. If absicca 
    # and ordinate arrays are not of the same length, then the effective size used 
    # for interpolation will be MIN(x.size, y.size).
    # 
    # ==== Arguments
    # 
    # * +x+ -    The collection of absiccas. Must be a 1 D NMatrix or ruby Array.
    # 
    # * +y+ -    The collection of ordinates corresponding to the absicca. 'y' can 
    #            either be a 1D NMatrix or Array OR a 2D NMatrix. In case y contains 
    #            multiple columns, the interpolation is carried out on each column,
    #            unless specified.
    # 
    # * +opts+ - Various options for carrying out the interpolation, to be specified as
    #            a hash.
    # 
    # ==== Options
    # 
    # * +:type+ - The kind of interpolation that the user wants to perform. Should be 
    #             specified as a symbol. Defaults to linear. Only linear
    #             interpolation supported as of now. 
    # 
    # * +:sorted+ - Set this option as *true* if the absicca collection is supplied in
    #             the arguments in a sorted manner. If not supplied, it will be assumed
    #             that absiccas are not sorted and they will sorted be sorted anyway.
    # 
    # * +:axis+ - In case of a multidimensional ordinate matrix, specify the column over
    #             which interpolation must be performed. *axis* starts indexing from 0 
    #             and should be lower than the number of columns in the ordinate matrix.
    # 
    # * +:precision+ - Specifies the precision of the interpolated values returned. Defaults
    #             to 3.
    # 
    def initialize x, y, opts={}
      super(x,y,opts)

      if @opts[:type] == :cubic
        @opts.merge!({ 
          yp1: 1E99, 
          ypn: 1E99 
        })

        compute_second_derivatives
      end
    end

    # Performs the actual interpolation on the value passed as an argument. Kind of 
    # interpolation performed is determined according to what is specified in the 
    # constructor.
    # 
    # ==== Arguments
    # 
    # * +interpolant+ - The value for which the interpolation is to be performed. Can
    #                   either be a Numeric, Array of Numerics or NMatrix. If multidimensional
    #                   NMatrix is supplied then will flatten it and interpolate over
    #                   all its values. Will return answer in the form of an NMatrix if
    #                   *interpolant* is supplied as an NMatrix.
    def interpolate interpolant
      result = 
      case @opts[:type]
      when :linear
        for_each (interpolant) { |x| linear_interpolation(x)  }
      when :cubic
        cubic_spline_interpolation interpolant
      else
        raise ArgumentError, "1 D interpolation of type #{@opts[:type]} not supported"
      end

      result
    end

   private

    def for_each interpolant
      result = []

      if interpolant.kind_of? Numeric
        return yield interpolant
      else
        interpolant.each { |x| result << yield(x) }
      end

      result
    end

    def linear_interpolation interpolant
      # TODO : Make this more efficient by using hunt/locate from NR
      index  = locate(interpolant)
      same   = @x[index] == @x[index+1]
      result = []              

      if (@y.respond_to?(:vector?) and @y.vector?) or
        @y.instance_of?(Array)

        return @y[index] if same
        return _lin_interpolator @y, index, interpolant
      elsif @opts[:axis] != 0

        return @y.column(@opts[:axis])[index] if same
        return _lin_interpolator @y.column(@opts[:axis]), index, interpolant
      else
        @y.each_column do |c|
          result << (same ? c[index] : _lin_interpolator(c, index, interpolant))
        end
      end

      result
    end

    def _lin_interpolator y, index, interpolant
      (y[index] + 
      ((interpolant - @x[index]) / (@x[index + 1] - @x[index])) * 
       (y[index + 1] - y[index])).round(@opts[:precision])
    end

    # References: Numerical Recipes Edition 3. Chapter 3.3
    def compute_second_derivatives
      @y_sd = Array.new(@size)

      n      = @y_sd.size
      u      = Array.new(n-1)
      yp1    = @opts[:yp1] # first derivative of the 0th point as specified by the user
      ypn    = @opts[:ypn] # first derivative of the nth point as specified by the user
      qn, un = nil, nil

      if yp1 > 0.99E30
        @y_sd[0], u[0] = 0.0, 0.0
      else 
        @y_sd[0] = -0.5
        u[0] = (3.0 / (@x[1] - @x[0])) * ((@y[1] - @y[0]) / (@x[1] - @x[0]) - yp1)
      end
      
      1.upto(n-2) do |i| # decomposition loop for tridiagonal algorithm
        sig      = ( @x[i] - @x[i-1] ) / ( @x[i+1] - @x[i-1] )
        p        = sig * @y_sd[i-1] + 2
        @y_sd[i] = ( sig - 1) / p 
        u[i]     = (( @y[i+1] - @y[i]) / (@x[i+1] - @x[i])) - ((@y[i] - @y[i-1]) / (@x[i] - @x[i-1]))
        u[i]     = ( 6 * u[i] / ( @x[i+1] - @x[i-1] ) - sig * u[i-1] ) / p;
      end

      if ypn > 0.99E30
        qn, un = 0.0, 0.0
      else
        qn = 0.5
        un = (3.0 / ( @x[n-1] - @x[n-2] )) * ( ypn - ( @y[n-1] - @y[n-2] ) / ( @x[n-1] - @x[n-2] ))
      end
      @y_sd[n-1] = ( un - qn * u[n-2] ) / ( qn * @y_sd[n-2] + 1.0 )

      (n-2).downto(0) do |k|
        @y_sd[k] = @y_sd[k] * @y_sd[k+1] + u[k]
      end
    end

    def cubic_spline_interpolation interpolant
      klo = locate interpolant
      khi = klo + 1

      h = @x[khi] - @x[klo]

      raise StandardError, "Wrong input at X index #{klo} and #{khi} for cubic spline" if h == 0

      a = (@x[khi] - interpolant) / h
      b = (interpolant - @x[klo]) / h
      y = a * @y[klo] + b * @y[khi] + ((a * a * a - a) * @y_sd[klo] + # evaluate cubic spline polynomial
          ( b * b * b - b) * @y_sd[khi]) * ( h * h ) / 6.0
      y.round @opts[:precision]
    end
  end
end
