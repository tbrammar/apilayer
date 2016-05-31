require "spec_helper"

describe Apilayer do

  describe :init_configs do
    it "returns a Struct" do
      configs = Apilayer.init_configs
      expect(configs).to be_a Struct
    end

    it "contains currency_key and vat_key members" do
      configs = Apilayer.init_configs
      expect(configs.members).to include :currency_key
      expect(configs.members).to include :vat_key
    end
  end

  describe :reset! do
    it "returns an empty @configs" do
      Apilayer.reset!
      expect(Apilayer.instance_variable_get(:@configs).currency_key).to be_nil
      expect(Apilayer.instance_variable_get(:@configs).vat_key).to be_nil
    end
  end

  describe :configure do
    it "sets access_key for currency_layer" do
      Apilayer.configure do |config|
        config.currency_key = "foo123"
      end
      expect(Apilayer.configs.currency_key).to eq "foo123"
    end

    it "sets access_key for vat_layer" do
      Apilayer.configure do |config|
        config.vat_key = "bar456"
      end
      expect(Apilayer.configs.vat_key).to eq "bar456"
    end    

    it "resets observers" do
      Apilayer::OBSERVERS.each do |observer|
        expect(observer).to receive(:reset_connection).twice
      end
      
      Apilayer.configure do |config|
        config.vat_key = "bar456"
      end

      Apilayer.configure do |config|
        config.vat_key = "foo123"
      end      
    end
  end  
end