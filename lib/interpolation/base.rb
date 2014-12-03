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

module Interpolation
  class Base
    def initialize x, y, opts
      @x, @y = x, y

      @opts = {
        precision: 3,
        sorted: false,
        type: :linear
      }.merge(opts)

      @size = @x.size # considers size of @x only
      @x    = @x.sort unless @opts[:sorted]
      @x.map! { |n| n = Float(n)}
    end
   protected

    def locate num 
      # Returns the index of the value 'num' such that x[j] > num > x[j+1]
      ascnd = (@x[-1] >= @x[0])

      jl, jm, ju = 0, 0,@x.size-1

      while ju - jl > 1
        jm = (ju+jl)/2

        if num >= @x[jm] == ascnd
          jl = jm
        else
          ju = jm
        end
      end

      return 0       if    num == @x[0]
      return @size-2 if    num == @x[@size - 1]
      return jl                           
    end 
  end
end
