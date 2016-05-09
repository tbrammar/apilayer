require 'rubygems'
require "faraday"
require "json"

module Apilayer
  class << self
    attr_writer :configs
  end

  def self.init_configs
    keys = Struct.new(:currency_key, :vat_key)
    keys.new
  end

  def self.configs
    @configs ||= init_configs
  end

  def self.reset
    @configs = init_configs
  end

  def self.configure
    yield(configs)
  end
end

require "apilayer/currency"
require "apilayer/vat"
