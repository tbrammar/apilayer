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

    def self.rate_by_country_code(country_code)
      resp = connection.get do |req|
        req.url 'api/rate'
        req.params['country_code'] = country_code
      end
      JSON.parse(resp.body)
    end

    def self.rate_list
      resp = connection.get do |req|
        req.url 'api/rate_list'
      end
      JSON.parse(resp.body)
    end

    def self.price(price, criteria, value)
      unless [:country_code, :ip_address].include? criteria
        raise Apilayer::Error.new("You must provide either :country_code or :ip_address")
      end
      resp = connection.get do |req|
        req.url 'api/price'
        req.params['amount'] = price
        req.params[criteria.to_s] = value
      end
      JSON.parse(resp.body)
    end
  end
end
