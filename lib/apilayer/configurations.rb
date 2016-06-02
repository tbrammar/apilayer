module Apilayer
  module Configurations
    class << self
      attr_writer :configs
    end

    def init_configs
      keys = Struct.new(:access_key, :https)
      keys.new
    end

    def configs
      @configs ||= init_configs
    end

    def reset!
      @configs = init_configs
    end

    def configure(&block)
      self.reset_connection
      yield(configs)
    end    
  end
end
