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

require 'nmatrix'

$:.unshift File.dirname(__FILE__)

require 'interpolation/one_dimensional.rb'
require 'monkeys.rb'