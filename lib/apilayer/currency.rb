module Apilayer
  module Currency
    extend ConnectionHelper

    CURRENCYLAYER_KEY_MISSING_MSG = "Please configure access_key for currency_layer first!"

    def self.connection
      if Apilayer.configs[:currency_key].nil?
        raise Apilayer::Error.new "Please configure access_key for currency_layer first!"
      else
        @connection ||= ::Faraday.new(:url => 'http://apilayer.net', 
                                      :params => {"access_key" => Apilayer.configs[:currency_key]})
      end
    end

    def self.live(*currencies)
      currencies_str = join_by_commas(currencies)
      params = {:currencies => currencies_str}
      get_and_parse_request("live", params)
    end

    def self.historical(date, *currencies)      
      params = {:date => date}
      params.merge!(:currencies => join_by_commas(currencies)) if currencies.any?
      get_and_parse_request("historical", params)
    end

    def self.convert(from, to, amount, date=nil)
      params = {:from => from, :to => to, :amount => amount}
      params.merge!(:date => date) if date
      get_and_parse_request("convert", params)
    end

    def self.join_by_commas(currencies)
      currencies.map(&:strip).join(",")
    end

  end
end
