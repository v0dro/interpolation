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

require 'spec_helper.rb'

describe Interpolation::OneDimensional do
  context :linear do
    before :each do
      @x   = NMatrix.seq [10]
      @y   = @x.exp
      @nd  = NMatrix.new([10,3]).each_column { |c| c[0..9] = @y }
    end

    it "tests if OneDimensional accepts Array inputs" do
      f = Interpolation::OneDimensional.new([0,1,2,3,4,5,6,7,8,9], [1.0, 
        2.718281828459045, 7.38905609893065, 20.085536923187668, 54.598150033144236, 
        148.4131591025766, 403.4287934927351, 1096.6331584284585, 2980.9579870417283, 
        8103.083927575384], {type: :linear, sorted: true})

      expect(f.interpolate(2.5)).to eq 13.737
    end

    it "tests for linear interpolation for 1-dimensional y values" do
      f = Interpolation::OneDimensional.new(@x, @y, {type: :linear, 
        precision: 3})

      expect(f.interpolate(2.5))              .to eq 13.737

      expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq [13.737, 888.672, 
        1.515, 6054.234]

      # expect(f.interpolate(NMatrix.new([4,1], [2.5,6.7,0.3,8.6]))).to eq NMatrix.new(
      #   [4], [13.737, 888.672, 1.515, 6054.234])
    end

    it "tests linear interpolation for N-dimensional y values" do

      f = Interpolation::OneDimensional.new(@x,@nd, {type: :linear, 
        sorted: true, precision: 3})

      expect(f.interpolate(2.5))              .to eq [13.737,13.737,13.737]
      
      expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq \
        [ [13.737  , 13.737  , 13.737 ], 
          [888.672 , 888.672 , 888.672],
          [1.515   , 1.515   , 1.515  ],
          [6054.234, 6054.234, 6054.234 ]
        ]

      # expect(f.interpolate(NMatrix.new([4,1], [2.5,6.7,0.3,8.6]))).to eq \
      #   NMatrix.new([4,3], 
      #   [ 13.737  , 13.737  , 13.737 , 
      #     888.672 , 888.672 , 888.672,
      #     1.515   , 1.515   , 1.515  ,
      #     6054.234, 6054.234, 6054.234 
      #   ]) 
      end

    it "tests linear interpolation for N-dimensional y on another axis" do
     f = Interpolation::OneDimensional.new(@x, @nd, {type: :linear, axis: 1, 
      sorted: true, precision: 3})
     
     expect(f.interpolate(3.5))              .to eq 37.342

     expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq [13.737, 888.672, 
      1.515, 6054.234]

     # expect(f.interpolate(NMatrix.new([4,1], [2.5,6.7,0.3,8.6]))).to eq NMatrix.new(
     #  [4], [13.737, 888.672, 1.515, 6054.234])
    end
  end

  context :quadratic do
    before :each do
      @x  = (0..9).step(1).to_a
      @y  = @x.map { |e| Math.exp(e) }
      @nd = [ @y, @y, @y ]
    end

    it "calculates quad interpolation for single axis input of Y co-ordinates" do
      f = Interpolation::OneDimensional.new(@x, @y, type: :quadratic, sorted: true)

      expect(f.interpolate(2.5)).to eq()
    end

    it "calculates quad interpolation for multi-axis input of Y co-ordinates" do
      f = Interpolation::OneDimensional.new(@x, @nd, type: :quadratic, sorted: true)

      expect(f.interpolate(2.5)).to eq()

      expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq()
    end

    it "calculates quad interpolation only on the specified axis" do
      f = Interpolation::OneDimensional.new(@x, @nd, type: :quadratic, sorted: true, axis: 1)

    end
  end
end