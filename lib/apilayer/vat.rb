module Apilayer
  module Vat
    extend ConnectionHelper

    COUNTRY_CRITERIA_MISSING_MSG = "You must provide either :country_code or :ip_address"
    VATLAYER_KEY_MISSING_MSG = "Please configure access_key for vat_layer first!"

    def self.connection
      if Apilayer.configs[:vat_key].nil?
        raise Apilayer::Error.new VATLAYER_KEY_MISSING_MSG
      else
        @connection ||= ::Faraday.new(:url => 'http://apilayer.net',
                                      :params => {"access_key" => Apilayer.configs[:vat_key]})
      end
    end

    def self.validate_country_criteria(criteria)
      unless [:country_code, :ip_address].include? criteria
        raise Apilayer::Error.new COUNTRY_CRITERIA_MISSING_MSG
      end
    end

    def self.validate(vat_number)
      params = {:vat_number => vat_number}
      get_and_parse_request("validate", params)
    end

    def self.rate(criteria, value)
      validate_country_criteria(criteria)
      params = {criteria.to_s => value}
      get_and_parse_request("rate", params)
    end

    def self.rate_list
      get_and_parse_request("rate_list")
    end

    def self.price(price, criteria, value)
      validate_country_criteria(criteria)
      params = {:amount => price, criteria.to_s => value}
      get_and_parse_request("price", params)
    end

  end
end
