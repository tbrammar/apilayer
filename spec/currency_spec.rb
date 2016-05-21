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
    context "invalid options provided" do
      it "raises an Apilayer::Error" do
        expect{Apilayer::Currency.live(:foo => "bar")}.to raise_error(
          Apilayer::Error,
          Apilayer::Currency::INVALID_OPTIONS_MSG
        )
      end
    end

    context "no options specified" do
      it "returns a Hash with live quotes for all currencies" do
        VCR.use_cassette("currency/live_no_options") do
          api_resp = Apilayer::Currency.live
          expect(api_resp).to be_a Hash

          expect(api_resp).to include "success"
          expect(api_resp).to include "source"
          expect(api_resp).to include "quotes"
          expect(api_resp["quotes"]["USDAED"]).to eq 3.67295
        end      
      end

      it "invokes get_and_parse without params" do
        VCR.use_cassette("currency/live_no_options") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with("live")
          Apilayer::Currency.live
        end
      end
    end

    context "source currency provided" do
      it "returns a Hash with live quotes for all currencies with source currency as base" do
        VCR.use_cassette("currency/live_only_source_specified") do
          api_resp = Apilayer::Currency.live(:source => "EUR")
          expect(api_resp).to be_a Hash
          expect(api_resp["source"]).to eq "EUR"
          expect(api_resp["quotes"]["EURAED"]).to eq 4.121599
        end
      end

      it "invokes get_and_parse with :source within params" do
        VCR.use_cassette("currency/live_only_source_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with("live", {:source => "EUR"})
          Apilayer::Currency.live({:source => "EUR"})
        end
      end
    end

    context "currencies specified with argument" do
      it "returns a Hash with live quotes for specified currencies" do
        VCR.use_cassette("currency/live_with_currencies_specified") do
          api_resp = Apilayer::Currency.live(:currencies => ["EUR", "GBP", "CHF"])
          expect(api_resp).to be_a Hash

          expect(api_resp["quotes"].size).to eq 3
          expect(api_resp["quotes"]).to include "USDEUR"
          expect(api_resp["quotes"]).to include "USDGBP"
          expect(api_resp["quotes"]).to include "USDCHF"          
        end
      end

      it "invokes get_and_parse with :currencies within params" do
        VCR.use_cassette("currency/live_with_valid_currencies_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "live", {:currencies => "EUR,GBP,CHF"}
          )
          Apilayer::Currency.live(:currencies => ["EUR", "GBP", "CHF"])
        end
      end

      context "invalid currency-codes provided" do
        it "raises an error" do
          VCR.use_cassette("currency/live_with_invalid_currencies_specified") do
            expect{Apilayer::Currency.live(:currencies => ["QQQ"])}.to raise_error(
              Apilayer::Error,
              "You have provided one or more invalid Currency Codes. [Required format: currencies=EUR,USD,GBP,...]"
            )
          end
        end
      end
    end

    context "currencies and source provided as options" do
      it "returns a Hash with live quotes for specivied currencies with source currency as base" do
        VCR.use_cassette("currency/live_with_currencies_and_source_specified") do
          api_resp = Apilayer::Currency.live(:currencies => %w[USD GBP CHF], :source => "EUR")
          expect(api_resp).to be_a Hash

          expect(api_resp["source"]).to eq "EUR"
          expect(api_resp["quotes"]["EURUSD"]).to eq 1.122149
          expect(api_resp["quotes"]["EURGBP"]).to eq 0.773416
          expect(api_resp["quotes"]["EURCHF"]).to eq 1.111192
        end
      end

      it "invokes get_and_parse with :currencies and :source within params" do
        VCR.use_cassette("currency/live_with_valid_currencies_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "live", hash_including(:currencies => "USD,GBP,CHF", :source => "EUR")
          )
          Apilayer::Currency.live(:currencies => ["USD", "GBP", "CHF"], :source => "EUR")
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
