module Apilayer
  module ConnectionHelper

    def get_and_parse_request(url, params={})
      resp = connection.get do |req|
        req.url "api/#{url}"
        params.each_pair do |k,v|
          req.params[k] = v
        end
      end
      JSON.parse(resp.body)      
    end

  end
end
