module Apilayer

  module Vat
    def self.connection
      if Apilayer.configs[:vat_key].nil?
        raise Apilayer::Error.new "Please configure access_key for vat_layer first!"
      else
        @connection ||= ::Faraday.new(:url => 'http://apilayer.net',
                                      :params => {"access_key" => Apilayer.configs[:vat_key]})
      end
    end

    def self.validate(vat_number)
      resp = connection.get do |req|
        req.url 'api/validate'
        req.params['vat_number'] = vat_number
      end
      JSON.parse(resp.body)
    end
  end
end
