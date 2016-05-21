##
# Ruby wrapper for currencylayer. See https://currencylayer.com/documentation for more info
module Apilayer
  module Currency
    extend ConnectionHelper

    ##
    # Determines which access_key in Apilayer.configs to use 
    # in order to to make a connection to currencylayer
    APILAYER_CONFIG_KEY = :currency_key
    INVALID_OPTIONS_MSG = "You have provided an invalid option. Allowed options are :currencies and :source"
    ## Validations 
    # 
    def self.validate_options(options)
      options.keys.each do |key|
        unless [:currencies, :source].include? key
          raise Apilayer::Error.new(INVALID_OPTIONS_MSG)
        end
      end
    end

    ### API methods
    #

    ##
    # Api-Method: Calls the /live endpoint to get real-time exchange rates.
    # When no currency-codes are specified, it will return all exchange rates for your source-currency.
    # Example:
    #   Apilayer::Currency.live
    #   Apilayer::Currency.live(:currencies => %w[GBP, CHF])
    #   Apilayer::Currency.live(:source => "EUR")
    #   Apilayer::Currency.live(:source => "EUR", :currencies => %w[GBP, CHF])
    def self.live(opts={})
      validate_options(opts)

      if opts.empty?
        get_and_parse("live")
      else
        params = {}
        if opts[:currencies] && opts[:currencies].any?
          currencies_str = join_by_commas(opts[:currencies])
          params[:currencies ] = currencies_str
        end
        if opts[:source]
          params[:source] = opts[:source]
        end
        get_and_parse("live", params)
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
