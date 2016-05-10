require "spec_helper"

describe Apilayer::ConnectionHelper do
  describe :get_and_parse do

    context "No access key provided" do
      before do
        Apilayer.reset!        
      end

      it "raises an error" do
        expect do
          VCR.use_cassette("errors/no_access_key") do
            api_resp = Apilayer::Vat.validate("LU26375245")
          end
        end.to raise_error(
          Apilayer::Error,
          "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"
        )
      end
    end

    context "Invalid access key provided" do
      before do
        Apilayer.configure do |config|
          config.vat_key = "invalid_code_1234"
        end
        Apilayer::Vat.reset_connection
      end

      it "raises an error" do
        expect do
          VCR.use_cassette("errors/invalid_access_key") do
            api_resp = Apilayer::Vat.validate("LU26375245")
          end
        end.to raise_error(
          Apilayer::Error,
          "You have not supplied a valid API Access Key. [Technical Support: support@apilayer.com]"
        )
      end
    end

  end
end