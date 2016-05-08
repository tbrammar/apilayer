module Apilayer

  module Vat
    def self.connection
      if Apilayer.configs[:vat_key].nil?
        raise "Please configure access_key for vat_layer"
      else
        @connection ||= ::Faraday.new(:url => 'http://apilayer.net', :params => {"access_key" => Apilayer.configs[:vat_key]})
      end
    end

    def self.validate(vat_number, format=1)
      resp = connection.get do |req|
        req.url 'api/validate' # static
        req.params['vat_number'] = vat_number
        req.params['format'] = format
      end
      JSON.parse(resp.body)
    end
  end
end
