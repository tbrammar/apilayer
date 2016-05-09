module Apilayer

  module Currency

    def self.connection
      if Apilayer.configs[:currency_key].nil?
        raise Apilayer::Error.new "Please configure access_key for currency_layer first!"
      else
        @connection ||= ::Faraday.new(:url => 'http://apilayer.net', 
                                      :params => {"access_key" => Apilayer.configs[:currency_key]})
      end
    end

    def self.live(*currencies)
      resp = connection.get do |req|
        req.url 'api/live' 
        req.params['currencies'] = currencies.map(&:strip).join(",")
      end
      JSON.parse(resp.body)
    end

    def self.historical(date, currencies)
      resp = connection.get do |req|
        req.url 'api/historical' 
        req.params['date'] = date
        req.params['currencies'] = currencies.map(&:strip).join(",") if currencies.any?
      end
      JSON.parse(resp.body)
    end

    def self.convert(from, to, amount, date=nil)
      resp = connection.get do |req|
        req.url 'api/convert' # static
        req.params['from'] = from
        req.params['to'] = to
        req.params['amount'] = amount
        req.params['date'] = date if date
      end
      JSON.parse(resp.body)
    end
  end
end
