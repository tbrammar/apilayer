require "spec_helper"

describe Apilayer::Vat do
  describe :connection do
    context  "vat_layer access_key has not been set" do
      it "raises an error" do
        Apilayer.reset

        expect{Apilayer::Vat.connection}.to raise_error(
          Apilayer::Error,
          "Please configure access_key for vat_layer first!"
        )
      end
    end

    context  "vat_layer access_key has been set" do
      it "returns a connection with correct attributes" do
        Apilayer.configure do |configs|
          configs.vat_key = "boo456"
        end

        conn = Apilayer::Vat.connection

        expect(conn).to be_a Faraday::Connection
        expect(conn.url_prefix.host).to match "apilayer.net"
        expect(conn.params["access_key"]).to eq "boo456"
      end
    end
  end

  describe :live
  describe :historical
  describe :convert

end
