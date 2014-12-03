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

    context "#interpolate" do
      it "interpolates with 1-D ruby Array" do
        f = Interpolation::OneDimensional.new([0,1,2,3,4,5,6,7,8,9], [1.0, 
          2.718281828459045, 7.38905609893065, 20.085536923187668, 54.598150033144236, 
          148.4131591025766, 403.4287934927351, 1096.6331584284585, 2980.9579870417283, 
          8103.083927575384], {type: :linear, sorted: true})

        expect(f.interpolate(2.5)).to eq 13.737
      end

      it "interpolates with single axis inout" do
        f = Interpolation::OneDimensional.new(@x, @y, {type: :linear, 
          precision: 3})

        expect(f.interpolate(2.5))              .to eq 13.737

        expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq [13.737, 888.672, 
          1.515, 6054.234]

        # expect(f.interpolate(NMatrix.new([4,1], [2.5,6.7,0.3,8.6]))).to eq NMatrix.new(
        #   [4], [13.737, 888.672, 1.515, 6054.234])
      end

      it "interpolates over all axes" do
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

      it "interpolates on specified axis" do
       f = Interpolation::OneDimensional.new(@x, @nd, {type: :linear, axis: 1, 
        sorted: true, precision: 3})
       
       expect(f.interpolate(3.5))              .to eq 37.342

       expect(f.interpolate([2.5,6.7,0.3,8.6])).to eq [13.737, 888.672, 
        1.515, 6054.234]

       # expect(f.interpolate(NMatrix.new([4,1], [2.5,6.7,0.3,8.6]))).to eq NMatrix.new(
       #  [4], [13.737, 888.672, 1.515, 6054.234])
      end
    end

    context "#interp"
  end

  context :slinear do
    
  end

  context :quadratic do
    
  end

  context :cubic do
    before :each do
      @x  = (0..9).step(1).to_a
      @y  = @x.map { |e| Math.exp(e) }
      @nd = Matrix.columns [@y, @y, @y]
    end

    context "#interpolation" do
      it "correctly interpolates for single axis co-ordinates" do
        f = Interpolation::OneDimensional.new(@x, @y, type: :cubic, sorted: true)

        expect(f.interpolate(2.5)).to eq(12.287)
      end

      it "interpolates for multiple points" do
        f = Interpolation::OneDimensional.new(@x, @y, type: :cubic, sorted: true)
        
        expect(f.interpolate([2.5,3.5,4,6.5])).to eq([12.287, 32.577, 54.598, 688.288])
      end

      it "interpolates over all axes" do
        f = Interpolation::OneDimensional.new(@x, @nd, type: :cubic, sorted: true, axis: :all)

        expect(f.interpolate(2.5)).to eq([12.287, 12.287, 12.287])

        expect(f.interpolate([2.5,3.5,4,6.5])). to eq([
          [12.287, 12.287, 12.287],
          [32.577, 32.577, 32.577], 
          [54.598, 54.598, 54.598], 
          [688.288, 688.288, 688.288]      
        ]
          )
      end

      it "interpolates only on the specified axis" do
        f = Interpolation::OneDimensional.new(@x, @nd, type: :cubic, sorted: true, axis: 1)

        expect(f.interpolate([2.5,3.5,4,6.5])).to eq([12.287, 32.577, 54.598, 688.288])
      end
    end

    context "#interp" do

    end
  end
end