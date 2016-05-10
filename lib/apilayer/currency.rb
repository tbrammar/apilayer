module Apilayer
  module Currency
    extend ConnectionHelper

    def self.connection
      @connection ||= ::Faraday.new(:url => 'http://apilayer.net', 
                                    :params => {"access_key" => Apilayer.configs[:currency_key]})
    end

    def self.live(*currencies)
      if currencies.any?
        currencies_str = join_by_commas(currencies)
        params = {:currencies => currencies_str}
        get_and_parse("live", params)
      else
        get_and_parse("live")
      end
    end

    def self.historical(date, *currencies)      
      params = {:date => date}
      params.merge!(:currencies => join_by_commas(currencies)) if currencies.any?
      get_and_parse("historical", params)
    end

=begin
    def self.convert(from, to, amount, date=nil)
      params = {:from => from, :to => to, :amount => amount}
      params.merge!(:date => date) if date
      get_and_parse("convert", params)
    end
=end
    def self.join_by_commas(currencies)
      currencies.map(&:strip).join(",")
    end

  end
end
