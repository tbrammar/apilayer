##
# Ruby wrapper for vatlayer. See https://vatlayer.com/documentation for more info
module Apilayer
  module Vat
    extend ConnectionHelper

    COUNTRY_CRITERIA_MISSING_MSG = "You must provide either :country_code or :ip_address"

    ##
    # The following constants determine which values in Apilayer.configs to be used
    # in order to make a connection to vatlayer
    APILAYER_CONFIG_KEY = :vat_key
    APILAYER_SECURE = :vat_https
    ##
    # Validates whether a supported criteria has been provided to .rate and .price
    def self.validate_country_criteria(criteria)
      unless [:country_code, :ip_address].include? criteria
        raise Apilayer::Error.new COUNTRY_CRITERIA_MISSING_MSG
      end
    end

    ### API methods
    #

    ##
    # Api-Method: Calls the /validate endpoint to validate a given VAT-number.
    # Example:
    #   Apilayer::Vat.validate("LU26375245")
    def self.validate(vat_number)
      params = {:vat_number => vat_number}
      get_and_parse("validate", params)
    end

    ##
    # Api-Method: Calls the /rate endpoint to get the VAT-rate of a given country, 
    # based on country-code or ip-address.
    # Example:
    #   Apilayer::Vat.rate(:country_code, "NL")
    #   Apilayer::Vat.rate(:ip_address, "176.249.153.36")
    def self.rate(criteria, value)
      validate_country_criteria(criteria)
      params = {criteria.to_sym => value}
      get_and_parse("rate", params)
    end

    ##
    # Api-Method: Calls the /rate_list endpoint to get the standard and reduced VAT-rates
    # for all EU countries.
    # Example:
    #   Apilayer::Vat.rate_list
    def self.rate_list
      get_and_parse("rate_list")
    end

    ##
    # Api-Method: Calls the /price endpoint to get price including and excluding VAT 
    # for a given price and country. It also returns the VAT rate for that country
    # Example:
    #   Apilayer::Vat.price(100, :country, "NL")
    #   Apilayer::Vat.price(100, :ip_address, "176.249.153.36")
    def self.price(price, criteria, value)
      validate_country_criteria(criteria)
      params = {:amount => price, criteria.to_sym => value}
      get_and_parse("price", params)
    end

  end
end
