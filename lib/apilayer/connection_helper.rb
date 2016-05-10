module Apilayer
  module ConnectionHelper

    def reset_connection
      @connection = nil
    end

    def get_and_parse(url, params={})
      resp = get_request(url, params)
      parse_response(resp)
    end

    def get_request(url, params={})
      # calls connection method on the extended module
      connection.get do |req|
        req.url "api/#{url}"
        params.each_pair do |k,v|
          req.params[k] = v
        end
      end
    end

    def parse_response(resp)
      body = JSON.parse(resp.body)
      # According to documentation, currencylayer has a "success" field 
      # while vatlayer has a "valid" field to indicate whether the request was succesful or not.
      # However, for both layers, an unsuccesful request would contain an "error" field.
      # That's why the presence of "error" is chosen to determine whether we should raise an error or not.
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
