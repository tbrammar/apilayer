require "spec_helper"

describe Apilayer::Currency do
  describe :connection do
    context  "currency_layer access_key has not been set" do
      it "raises an error" do
        Apilayer.reset

        expect{Apilayer::Currency.connection}.to raise_error(
          Apilayer::Error,
          "Please configure access_key for currency_layer first!"
        )
      end
    end

    context  "currency_layer access_key has been set" do
      it "returns a connection with correct attributes" do
        Apilayer.configure do |configs|
          configs.currency_key = "foo123"
        end

        conn = Apilayer::Currency.connection

        expect(conn).to be_a Faraday::Connection
        expect(conn.url_prefix.host).to match "apilayer.net"
        expect(conn.params["access_key"]).to eq "foo123"
      end
    end
  end

  describe :validate

end
