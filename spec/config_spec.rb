require 'spec_helper'
require 'mopsy/config'

RSpec.describe Mopsy::Config do
  describe 'configure' do

    before do
      Mopsy::Config.reset!
    end

    it 'should be configurable with a block' do
      conf = Mopsy::Config.configure do |c|
        c.heartbeat = 500
      end
      expect(conf).to respond_to(:heartbeat)
      expect(conf.heartbeat).to eq(500)
    end

    it 'should be configurable' do
      c = Mopsy::Config.new
      c.heartbeat = 100
      expect(c.heartbeat).to eq(100)
    end

    it 'should raise an error on invalid config key' do
      c = Mopsy::Config.new
      expect {c.missing_key}.to raise_error(NoMethodError)
    end

    it 'can merge in another config hash' do
      c = Mopsy::Config.new
      extra_conf = { threads: 10 }
      c.merge!(extra_conf)
      expect(c[:threads]).to eq(10)
    end

    it 'can be accessed with []' do
      c = Mopsy::Config.new
      expect(c[:exchange_options][:name]).to eq("mopsy")
    end
  end
end
