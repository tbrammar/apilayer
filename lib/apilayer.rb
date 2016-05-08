require 'ostruct'
require 'rubygems'
require "faraday"
require "json"

module Apilayer
  class << self
    attr_writer :configs
  end

  def self.configs
    @configs ||= OpenStruct.new
  end

  def self.reset
    @configs = OpenStruct.new
  end

  def self.configure
    yield(configs)
  end
end

require "apilayer/currency"
require "apilayer/vat"
