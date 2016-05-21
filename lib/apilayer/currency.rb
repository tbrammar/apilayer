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
    LIVE_SLUG = "live"
    HISTORICAL_SLUG = "historical"
    CONVERT_SLUG = "convert"

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
        get_and_parse LIVE_SLUG
      else
        get_and_parse_with_options(LIVE_SLUG, opts)
      end
    end

    ##
    # Api-Method: Calls the /historical endpoint to get exchange rates for a specific date.
    # When no currency-codes are specified, it will return all exchange rates for your source-currency.
    # Example:
    #   Apilayer::Currency.historical("2016-01-01")
    #   Apilayer::Currency.historical("2016-01-01", :currencies => %w[GBP CHF])
    #   Apilayer::Currency.historical(:source => "EUR")
    #   Apilayer::Currency.historical("2016-01-01", :currencies => %w[GBP CHF], :source => "EUR")
    def self.historical(date, opts={})
      validate_options(opts)
      params = {:date => date}

      if opts.empty?
        get_and_parse(HISTORICAL_SLUG, params)
      else
        get_and_parse_with_options(HISTORICAL_SLUG, opts, params)
      end
    end

    ##
    # Api-Method: Calls the /convert endpoint, requires :from, :to and :amount
    # When :date hasn't been passed, the latest available exchange rates will be used for your conversion.
    # Example:
    #   Apilayer::Currency.convert("EUR", "CHF", 100)
    #   Apilayer::Currency.convert("EUR", "CHF", 100, "2015-06-01")
    def self.convert(from, to, amount, date=nil)
      params = {:from => from, :to => to, :amount => amount}
      params.merge!(:date => date) if date
      get_and_parse(CONVERT_SLUG, params)
    end



    ## Internal Methods
    def self.get_and_parse_with_options(slug, opts, params={})
      params = add_options_to_params(opts, params)
      get_and_parse(slug, params)
    end

    def self.add_options_to_params(opts, params)
      if opts[:currencies] && opts[:currencies].any?
        params[:currencies] = join_by_commas(opts[:currencies])
      end
      if opts[:source]
        params[:source] = opts[:source]
      end
      params
    end
    ##
    # Joins currencies in an array as a comma-separated-string
    def self.join_by_commas(currencies)
      currencies.map(&:strip).join(",")
    end

  end
end
