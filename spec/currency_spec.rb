require "spec_helper"

describe Apilayer::Currency do
  before do
    Apilayer.configure do |configs|
      configs.currency_key = "currency_layer_key123"
    end    
    Apilayer::Currency.reset_connection
  end

  describe :connection do
    context "currency_layer access_key has been set" do
      it "returns a connection with correct attributes" do
        conn = Apilayer::Currency.connection

        expect(conn).to be_a Faraday::Connection
        expect(conn.url_prefix.host).to match "apilayer.net"
        expect(conn.params["access_key"]).to eq "currency_layer_key123"
      end
    end
  end

  describe :live do
    context "no currencies specified with argument" do
      it "returns a Hash with live quotes for all currencies" do
        VCR.use_cassette("currency/live_no_currencies_specified") do
          api_resp = Apilayer::Currency.live
          expect(api_resp).to be_a Hash

          expect(api_resp).to include "success"
          expect(api_resp).to include "source"
          expect(api_resp).to include "quotes"
          expect(api_resp["quotes"]["USDAED"]).to eq 3.67295
        end      
      end

      it "invokes get_and_parse without currencies" do
        VCR.use_cassette("currency/live_no_currencies_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with("live")
          Apilayer::Currency.live
        end
      end
    end

    context "currencies specified with argument" do
      it "returns a Hash with live quotes for specified currencies" do
        VCR.use_cassette("currency/live_with_currencies_specified") do
          api_resp = Apilayer::Currency.live("EUR", "GBP", "CHF")
          expect(api_resp).to be_a Hash

          expect(api_resp["quotes"].size).to eq 3
          expect(api_resp["quotes"]).to include "USDEUR"
          expect(api_resp["quotes"]).to include "USDGBP"
          expect(api_resp["quotes"]).to include "USDCHF"          
        end
      end

      it "invokes get_and_parse with currencies" do
        VCR.use_cassette("currency/live_with_valid_currencies_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "live", {:currencies => "EUR,GBP,CHF"}
          )
          Apilayer::Currency.live("EUR", "GBP", "CHF")
        end
      end

      context "invalid currency-codes provided" do
        it "raises an error" do
          VCR.use_cassette("currency/live_with_invalid_currencies_specified") do
            expect{Apilayer::Currency.live("QQQ")}.to raise_error(
              Apilayer::Error,
              "You have provided one or more invalid Currency Codes. [Required format: currencies=EUR,USD,GBP,...]"
            )
          end
        end
      end
    end
  end

  describe :historical do
    context "no currencies specified as second argument" do
      it "returns exchange rates for all available currency pairs" do
        VCR.use_cassette("currency/historical_no_currency_specified") do
          api_resp = Apilayer::Currency.historical("2016-05-06")

          expect(api_resp["historical"]).to eq true
          expect(api_resp["quotes"].size).to eq 168
        end    
      end

      it "invokes get_and_parse without currencies" do
        VCR.use_cassette("currency/historical_no_currency_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with("historical", {:date => "2016-05-06"})
          Apilayer::Currency.historical("2016-05-06")
        end    
      end
    end

    context "currencies specified as second argument" do
      it "returns only exchange rates for the specified currencies" do
        VCR.use_cassette("currency/historical_with_specified_currencies") do
          api_resp = Apilayer::Currency.historical("2016-05-06", "EUR", "GBP", "CHF" )

          expect(api_resp["historical"]).to eq true
          expect(api_resp["quotes"].size).to eq 3
          expect(api_resp["quotes"]).to include "USDEUR"
          expect(api_resp["quotes"]).to include "USDGBP"
          expect(api_resp["quotes"]).to include "USDCHF"
        end
      end

      it "invokes get_and_parse with currencies in params-hash" do
        VCR.use_cassette("currency/historical_with_specified_currencies") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "historical", hash_including(:date => "2016-05-06", :currencies => "EUR,GBP,CHF") 
          )
          Apilayer::Currency.historical("2016-05-06", "EUR", "GBP", "CHF" )
        end
      end
    end
  end

  describe :convert

end
