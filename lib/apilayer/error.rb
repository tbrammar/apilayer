##
# Error-class for errors that are returned by apilayer's services
module Apilayer
  class Error < StandardError
    attr_reader :code

    def initialize(message, code=nil)
      super(message)
      @code = code
    end
  end
end