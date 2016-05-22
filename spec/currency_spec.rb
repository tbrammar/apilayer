require "spec_helper"

describe Apilayer::Currency do
  before(:each) do
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

  describe :list do
    it "invokes .get_and_parse with correct params" do
      expect(Apilayer::Currency).to receive(:get_and_parse).with(Apilayer::Currency::LIST_SLUG)
      Apilayer::Currency.list
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
    context "invalid options provided" do
      it "raises an Apilayer::Error" do
        expect{ 
          Apilayer::Currency.historical("2016-05-06", :foo => "bar")
          }.to raise_error(
            Apilayer::Error,
            Apilayer::Currency::INVALID_OPTIONS_MSG
          )
      end
    end

    context "no options specified" do
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

    context "source currency provided" do
      it "returns a Hash with historical quotes for all currencies with source currency as base" do
        VCR.use_cassette("currency/historical_only_source_specified") do
          api_resp = Apilayer::Currency.historical("2016-05-06", :source => "EUR")
          expect(api_resp).to be_a Hash
          expect(api_resp["source"]).to eq "EUR"
          expect(api_resp["quotes"]["EURAED"]).to eq 4.188816
        end
      end

      it "invokes get_and_parse with :source within params" do
        VCR.use_cassette("currency/historical_only_source_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "historical", 
            hash_including(:date => "2016-05-06", :source => "EUR")
          )
          Apilayer::Currency.historical("2016-05-06", :source => "EUR")
        end
      end
    end

    context "currencies specified within options" do
      it "returns historical exchange rates only for the specified currencies" do
        VCR.use_cassette("currency/historical_with_specified_currencies") do
          api_resp = Apilayer::Currency.historical(
            "2016-05-06", :currencies => ["EUR", "GBP", "CHF"]
          )

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
          Apilayer::Currency.historical("2016-05-06", :currencies => ["EUR", "GBP", "CHF"])
        end
      end
    end

    context "currencies and source provided as options" do
      it "returns a Hash with historical quotes for specicied currencies with source currency as base" do
        VCR.use_cassette("currency/historical_with_currencies_and_source_specified") do
          api_resp = Apilayer::Currency.historical(
            "2016-05-06",
            :currencies => %w[USD GBP CHF], 
            :source => "EUR")

          expect(api_resp).to be_a Hash
          expect(api_resp["source"]).to eq "EUR"  
          expect(api_resp["quotes"]["EURUSD"]).to eq 1.14045
          expect(api_resp["quotes"]["EURGBP"]).to eq 0.790305
          expect(api_resp["quotes"]["EURCHF"]).to eq 1.109127
        end
      end

      it "invokes get_and_parse with :currencies and :source within params" do
        VCR.use_cassette("currency/historical_with_currencies_and_source_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            "historical", hash_including(
              :date => "2016-05-06", :currencies => "USD,GBP,CHF", :source => "EUR")
          )
          Apilayer::Currency.historical(
            "2016-05-06",
            :currencies => ["USD", "GBP", "CHF"], 
            :source => "EUR")
        end
      end      
    end    
  end

  describe :convert do
    context "no date provided" do
      it "invokes get_and_parse with :from, :to and :amount in its params" do
        VCR.use_cassette("currency/convert_without_date_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CONVERT_SLUG, 
            hash_including(:from => "EUR", :to => "CHF", :amount => 10)
          )
          Apilayer::Currency.convert("EUR", "CHF", 10)
        end
      end
    end

    context "date provided" do
      it "invokes get_and_parse with :from, :to, :amount and :date in its params" do
        VCR.use_cassette("currency/convert_with_date_specified") do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CONVERT_SLUG, 
            hash_including(:from => "EUR", :to => "CHF", 
                           :amount => 10, :date => "2016-01-01")            
          )
          Apilayer::Currency.convert("EUR", "CHF", 10, "2016-01-01")
        end
      end
    end
  end

  describe :timeframe do
    context "invalid options provided" do
      it "raises an Apilayer::Error" do
        expect do
          Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", {:foo => "bar"})
        end.to raise_error(
          Apilayer::Error,
          Apilayer::Currency::INVALID_OPTIONS_MSG
        )
      end
    end

    context "no options specified" do
      it "invokes .get_and_parse without :currencies nor :source" do
        expect(Apilayer::Currency).to receive(:get_and_parse).with(
          Apilayer::Currency::TIMEFRAME_SLUG,
          {:start_date => "2016-01-01", :end_date => "2016-06-01"}
        )
        Apilayer::Currency.timeframe("2016-01-01", "2016-06-01")
      end

      it "retrieves exchange-rates for all currencies based on USD for the specified timeframe" do
        VCR.use_cassette("currency/timeframe_without_options.yml") do
          api_resp = Apilayer::Currency.timeframe("2016-01-01", "2016-06-01")
          expect(api_resp["timeframe"]).to be true
          expect(api_resp["start_date"]).to eq "2016-01-01"
          expect(api_resp["end_date"]).to eq "2016-06-01"
          expect(api_resp["source"]).to eq "USD"
          expect(api_resp["quotes"]["2016-01-01"].size).to eq 168
        end
      end
    end

    context "only :currencies option specified" do
      it "returns exchange-rates for the specified currencies only" do
        VCR.use_cassette("currency/timeframe_with_currencies.yml") do
          api_resp = Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", :currencies => %w[GBP CHF])
          expect(api_resp["timeframe"]).to be true
          expect(api_resp["start_date"]).to eq "2016-01-01"
          expect(api_resp["end_date"]).to eq "2016-06-01"
          expect(api_resp["source"]).to eq "USD"
          expect(api_resp["quotes"]["2016-01-01"].size).to eq 2
          expect(api_resp["quotes"]["2016-01-01"]).to have_key "USDGBP"
          expect(api_resp["quotes"]["2016-01-01"]).to have_key "USDCHF"
        end
      end

      it "invokes .get_and_parse with :currencies" do
        expect(Apilayer::Currency).to receive(:get_and_parse).with(
          Apilayer::Currency::TIMEFRAME_SLUG,
          {:start_date => "2016-01-01", :end_date => "2016-06-01", :currencies => "GBP,CHF"}
        )
        Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", :currencies => %w[GBP CHF])
      end
    end

    context "only :source option specified" do
      it "returns exchange-rates based on given currency as source" do
        VCR.use_cassette("currency/timeframe_with_source.yml") do
          api_resp = Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", :source => "EUR")
          expect(api_resp["timeframe"]).to be true
          expect(api_resp["start_date"]).to eq "2016-01-01"
          expect(api_resp["end_date"]).to eq "2016-06-01"
          expect(api_resp["source"]).to eq "EUR"
          expect(api_resp["quotes"]["2016-01-01"].count).to eq 168
        end
      end

      it "invokes .get_and_parse with :source" do
        expect(Apilayer::Currency).to receive(:get_and_parse).with(
          Apilayer::Currency::TIMEFRAME_SLUG,
          {:start_date => "2016-01-01", :end_date => "2016-06-01", :source => "EUR"}
        )
        Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", :source => "EUR")
      end
    end

    context "both :currencies and :source specified" do
      it "returns exchange-rates for the specified currencies based on a specified source-currency" do
        VCR.use_cassette("currency/timeframe_with_currencies_and_source") do
          api_resp = Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", 
            :currencies => %w[GBP CHF], :source => "EUR")
          expect(api_resp["timeframe"]).to be true
          expect(api_resp["start_date"]).to eq "2016-01-01"
          expect(api_resp["end_date"]).to eq "2016-06-01"
          expect(api_resp["source"]).to eq "EUR"
          expect(api_resp["quotes"]["2016-01-01"].count).to eq 2
          expect(api_resp["quotes"]["2016-01-01"]).to have_key "EURGBP"
          expect(api_resp["quotes"]["2016-01-01"]).to have_key "EURCHF"          
        end
      end

      it "invokes .get_and_parse with :source and :currencies" do
        expect(Apilayer::Currency).to receive(:get_and_parse).with(
          Apilayer::Currency::TIMEFRAME_SLUG,
          {:start_date => "2016-01-01", :end_date => "2016-06-01", :source => "EUR", :currencies => "GBP,CHF"}
        )
        Apilayer::Currency.timeframe("2016-01-01", "2016-06-01", :currencies => %w[GBP CHF], :source => "EUR")
      end      
    end
  end

  describe :change do
    context "only start_date given" do
      it "raises an error" do
        expect{ Apilayer::Currency.change("2016-01-01") }.to raise_error(
          Apilayer::Error,
          Apilayer::Currency::INVALID_TIMEFRAME_MSG
        )
      end
    end

    context "only end_date given" do
      it "raises an error" do
        expect{ Apilayer::Currency.change(nil, "2016-01-01") }.to raise_error(
          Apilayer::Error,
          Apilayer::Currency::INVALID_TIMEFRAME_MSG
        )
      end
    end

    context "no start_date nor end_date given" do
      context "no options either" do
        it "returns margin- and percentage-changes for all quotes from yesterday with USD as source" do
          VCR.use_cassette("currency/change_no_timeframe_no_options_specified") do
            api_resp = Apilayer::Currency.change

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "USD"
            expect(api_resp["quotes"].size).to eq 168
          end
        end
      end

      context "with currencies specified" do
        it "returns margin- and percentage-change from last day for the specified quotes" do
          VCR.use_cassette("currency/change_no_timeframe_with_currencies_specified") do
            api_resp = Apilayer::Currency.change(nil,nil,:currencies => %w[CHF GBP])

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "USD"
            expect(api_resp["quotes"].size).to eq 2
            expect(api_resp["quotes"]).to have_key "USDCHF"
            expect(api_resp["quotes"]).to have_key "USDGBP"
          end
        end

        it "invokes .get_and_parse with :currencies as option" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:currencies => "CHF,EUR"}
          )
          Apilayer::Currency.change(nil,nil,:currencies => %w[CHF EUR])
        end
      end

      context "with source specified" do
        it "returns margin- and percentage-changes from last day for a specific source-currency" do
          VCR.use_cassette("currency/change_no_timeframe_with_source_specified") do
            api_resp = Apilayer::Currency.change(nil,nil,:source => "EUR")

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "EUR"
            expect(api_resp["quotes"].size).to eq 168
          end
        end

        it "invokes .get_and_parse with :source as option" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:source => "EUR"}
          )
          Apilayer::Currency.change(nil,nil,:source => "EUR")
        end        
      end

      context "with currencies and source specified" do
        it "returns margin- and percentage-changes from last day for the specified quotes and source-currency" do
          VCR.use_cassette("currency/change_no_timeframe_with_currencies_and_source_specified") do
            api_resp = Apilayer::Currency.change(nil,nil,:currencies => %w[CHF GBP], :source => "EUR")

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "EUR"
            expect(api_resp["quotes"].size).to eq 2
            expect(api_resp["quotes"]).to have_key "EURCHF"
            expect(api_resp["quotes"]).to have_key "EURGBP"
          end
        end

        it "invokes .get_and_parse with :source and :currencies as option" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:source => "EUR", :currencies => "CHF,GBP"}
          )
          Apilayer::Currency.change(nil,nil,:currencies => %w[CHF GBP], :source => "EUR")
        end
      end
    end

    context "both start_date and end_date given" do
      context "with currencies specified" do
        it "returns margin- and percentage-changes for the specified timeframe for the specified quotes" do
          VCR.use_cassette("currency/change_with_timeframe_with_currencies_specified") do
            api_resp = Apilayer::Currency.change("2016-01-01", "2016-03-01", :currencies => %w[CHF GBP])

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "USD"
            expect(api_resp["start_date"]).to eq "2016-01-01"
            expect(api_resp["end_date"]).to eq "2016-03-01"
            expect(api_resp["quotes"].size).to eq 2
            expect(api_resp["quotes"]).to have_key "USDCHF"
            expect(api_resp["quotes"]).to have_key "USDGBP"
          end
        end

        it "invokes .get_and_parse with :currencies, :start_date and :end_date" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:start_date => "2016-01-01", :end_date => "2016-03-01", :currencies => "CHF,GBP"}
          )
          Apilayer::Currency.change("2016-01-01", "2016-03-01", :currencies => %w[CHF GBP])
        end
      end

      context "with source specified" do
        it "returns margin- and percentage-changes for the specified timeframe for the source" do
          VCR.use_cassette("currency/change_with_timeframe_with_source_specified") do
            api_resp = Apilayer::Currency.change("2016-01-01", "2016-03-01", :source => "EUR")

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "EUR"
            expect(api_resp["start_date"]).to eq "2016-01-01"
            expect(api_resp["end_date"]).to eq "2016-03-01"
            expect(api_resp["quotes"].size).to eq 168
          end
        end

        it "invokes .get_and_parse with :source, :start_date and :end_date" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:start_date => "2016-01-01", :end_date => "2016-03-01", :source => "EUR"}
          )
          Apilayer::Currency.change("2016-01-01", "2016-03-01", :source => "EUR")          
        end
      end

      context "with currencies and source specified" do
        it "returns margin- and percentage-change for the specified timeframe scoped by source and quotes" do
          VCR.use_cassette("currency/change_with_timeframe_with_currencies_and_source_specified") do
            api_resp = Apilayer::Currency.change("2016-01-01", "2016-03-01", :source => "EUR", :currencies => %w[CHF GBP])

            expect(api_resp["change"]).to be true
            expect(api_resp["source"]).to eq "EUR"
            expect(api_resp["start_date"]).to eq "2016-01-01"
            expect(api_resp["end_date"]).to eq "2016-03-01"
            expect(api_resp["quotes"].size).to eq 2       
          end
        end
        it "invokes .get_and_parse with :currencies, :source, :start_date and :end_date" do
          expect(Apilayer::Currency).to receive(:get_and_parse).with(
            Apilayer::Currency::CHANGE_SLUG,
            {:source => "EUR", :currencies => "CHF,GBP", :start_date => "2016-01-01", :end_date => "2016-03-01"}
          )
          Apilayer::Currency.change("2016-01-01", "2016-03-01", :source => "EUR", :currencies => %w[CHF GBP])
        end
      end
    end
  end
end
