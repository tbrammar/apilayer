module Apilayer
  module ConnectionHelper

    def init_configs
      keys = Struct.new(:access_key, :https)
      keys.new
    end

    def configs
      @configs ||= init_configs
    end

    def reset_configs!
      @configs = init_configs
    end

    def configure(&block)
      self.reset_connection
      yield(configs)
    end

    ##
    # Creates a connection for the extended module to an apilayer-service, such as currencylayer and vatlayer.
    # Uses access_key(s) configured with Apilayer module.
    def connection
      @connection ||= ::Faraday.new(
        :url => "#{protocol}://apilayer.net",
        :params => {"access_key" => self.configs[:access_key]}
      )
    end

    def protocol
      self.configs[:https] ? "https" : "http"
    end
    ##
    # Resets the connection for the extended module. Used when the user needs to re-enter his/her access_key(s)
    def reset_connection
      @connection = nil
    end

    ##
    # Makes a get-request to apilayer's service and parses the JSON response into a Hash
    def get_and_parse(url, params={})
      resp = get_request(url, params)
      parse_response(resp)
    end

    ##
    # Makes a get-request to apilayer's service
    def get_request(slug, params={})
      # calls connection method on the extended module
      connection.get do |req|
        req.url "api/#{slug}"
        params.each_pair do |k,v|
          req.params[k] = v
        end
      end
    end

    ##
    # Parses the JSON response from apilayer into a Hash
    # When errors are returned by apilayer, the 'info' and 'code' from its error will be used to raise an Apilayer::Error
    def parse_response(resp)
      body = JSON.parse(resp.body)
      if body['error']
        raise Apilayer::Error.new(
          body['error']['info'],
          body['error']['code']
        )
      else
        body
      end      
    end
  end
end
