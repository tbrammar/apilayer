##
# Ruby wrapper for currencylayer. See https://currencylayer.com/documentation for more info
module Apilayer
  module Currency
    extend ConnectionHelper

    ##
    # Determines which access_key in Apilayer.configs to use 
    # in order to to make a connection to currencylayer
    APILAYER_CONFIG_KEY = :currency_key

    ### API methods
    #

    ##
    # Api-Method: Calls the /live endpoint to get real-time exchange rates.
    # When no currency-codes are specified, it will return all exchange rates for your source-currency.
    # Example:
    #   Apilayer::Currency.live
    #   Apilayer::Currency.live("EUR", "GBP", "CHF")
    def self.live(*currencies)
      if currencies.any?
        currencies_str = join_by_commas(currencies)
        params = {:currencies => currencies_str}
        get_and_parse("live", params)
      else
        get_and_parse("live")
      end
    end

    ##
    # Api-Method: Calls the /historical endpoint to get exchange rates for a specific date.
    # When no currency-codes are specified, it will return all exchange rates for your source-currency.
    # Example:
    #   Apilayer::Currency.historical("2016-01-01")
    #   Apilayer::Currency.historical("2016-01-01", "EUR", "GBP", "CHF")
    def self.historical(date, *currencies)      
      params = {:date => date}
      params.merge!(:currencies => join_by_commas(currencies)) if currencies.any?
      get_and_parse("historical", params)
    end

    ##
    # Joins currencies in an array as a comma-separated-string
    def self.join_by_commas(currencies)
      currencies.map(&:strip).join(",")
    end

  end
end
