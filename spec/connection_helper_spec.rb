require "spec_helper"

module Apilayer
  module Vat
    extend Apilayer::ConnectionHelper

    def self.validate(vat_number)
      params = {:vat_number => vat_number}
      get_and_parse("validate", params)
    end  
  end
end

describe Apilayer::ConnectionHelper do
  subject(:extended_module){Apilayer::Vat}
  let(:slug){"validate"}
  let(:params){{access_key: "vat_layer_key123", vat_number: "LU26375245"}}
  let(:empty_resp){double(:body => '{"success":true}')}
  let(:error_resp){double(:body => '{"success":false,"error":{"code":101,"type":"invalid_access_key","info":"You have not supplied a valid API Access Key. [Technical Support: support@apilayer.com]"}}')}

  describe :init_configs do
    it "returns a Struct" do
      configs = extended_module.init_configs
      expect(configs).to be_a Struct
    end

    it "contains access_key and https members" do
      configs = extended_module.init_configs
      expect(configs.members).to include :access_key
      expect(configs.members).to include :https
    end
  end

  describe :configs do
    context "configs already set" do
      it "won't invoke init_configs again" do
        expect(extended_module).to receive(:init_configs).once.and_call_original
        extended_module.configure do |config|
          config.access_key = "foo123"
        end
        extended_module.configs
      end
    end
  end

  describe :reset_configs! do
    it "returns an empty @configs" do
      extended_module.reset_configs!
      expect(extended_module.instance_variable_get(:@configs).access_key).to be_nil
      expect(extended_module.instance_variable_get(:@configs).https).to be_nil
    end
  end

  describe :configure do
    it "sets access_key and https for extended_module" do
      extended_module.configure do |config|
        config.access_key = "foo123"
        config.https = true
      end
      expect(extended_module.configs.access_key).to eq "foo123"
      expect(extended_module.configs.https).to eq true
    end

    it "resets observers" do
      subject::OBSERVERS.each do |observer|
        expect(observer).to receive(:reset_connection).twice
      end
      
      subject.configure do |config|
        config.vat_key = "bar456"
      end

      subject.configure do |config|
        config.vat_key = "foo123"
      end      
    end
  end  

  describe :connection do
    subject{ Apilayer::Vat.connection }

    before do
      Apilayer::Vat.configure do |c|
        c.access_key = "123abc"
        c.https = true
      end
    end      

    it "returns a connection with the configured values for access_key and https" do
      expect(subject.params).to eq({"access_key" => "123abc"})
      expect(subject.url_prefix.scheme).to eq "https"
    end

    it "returns a Faraday::Connection object" do
      expect(subject).to be_a Faraday::Connection
    end

    it "memoized @connection" do
      expect(Faraday).to receive(:new).once.and_call_original
      Apilayer::Vat.connection
      Apilayer::Vat.connection
    end
  end

  describe :protocol do
    subject{ Apilayer::Vat.protocol }

    context "configured with https" do
      before do
        Apilayer::Vat.configure{|c| c.https = true }
      end
      it "returns the correct scheme" do
        expect(subject).to eq "https"
      end
    end

    context "configured with http" do
      before do
        Apilayer::Vat.configure{|c| c.https = false }
      end
      it "returns the correct scheme" do
        expect(subject).to eq "http"
      end      
    end
  end

  describe :get_and_parse do
    it "invokes get_request and parse_response with the correct arguments" do
      expect(extended_module).to receive(:get_request).with(slug, params).and_return empty_resp
      expect(extended_module).to receive(:parse_response).with empty_resp

      extended_module.get_and_parse(slug, params)
    end

  end

  describe :get_request do
    it "returns sends a request to the apilayer.net, along with the slug and params" do
      VCR.use_cassette("vat/validation") do
        resp = extended_module.get_request slug, params
        url = resp.to_hash[:url]
        expect(url.request_uri).to eq "/api/validate?access_key=vat_layer_key123&vat_number=LU26375245"
        expect(url.host).to eq "apilayer.net"
      end      
    end

    it "returns a Faraday::Response object" do
      VCR.use_cassette("vat/validation") do
        resp = extended_module.get_request slug, params
        expect(resp).to be_a Faraday::Response
      end
    end
  end

  describe :parse_response do
    context "body has no error" do
    end

    context "body has an error" do
      it "raises and Apilayer::Error" do
        expect{extended_module.parse_response error_resp}.to raise_error(
          Apilayer::Error,
          "You have not supplied a valid API Access Key. [Technical Support: support@apilayer.com]"
        )
      end
    end

    context "body has no error" do
      it "returns response.body as a hash" do
        body = extended_module.parse_response(empty_resp)
        expect(body).to eq({"success" => true})
      end
    end
  end
end