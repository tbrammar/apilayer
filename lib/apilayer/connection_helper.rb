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

      # Damn it apilayer! Why an exception for vat#validation response? valid instead of success like everywhere else!
      if body["success"] || body["valid"]
        return body
      else
        raise Apilayer::Error.new(
          body['error']['info'],
          body['error']['code']
        )
      end      
    end
  end
end
