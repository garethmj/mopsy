require 'spec_helper'

RSpec.describe Mopsy::Config do
  context 'configure' do

    before(:each) do
      Mopsy::Config.reset!
    end

    it 'should return defaults when no other conf provided' do
      c = Mopsy::Config.new
      expect(c.amqp).to eq('amqp://guest:guest@localhost:5672')
      expect(c.vhost).to eq('/')
    end

    it 'should be configurable with a block' do
      conf = Mopsy::Config.configure do |c|
        c.heartbeat = 500
      end
      expect(conf).to respond_to(:heartbeat)
      expect(conf.heartbeat).to eq(500)
    end

    it 'should be configurable' do
      c           = Mopsy::Config.new
      c.heartbeat = 100
      expect(c.heartbeat).to eq(100)
    end

    it 'should raise an error on invalid config key' do
      c = Mopsy::Config.new
      expect {c.missing_key}.to raise_error(NoMethodError)
    end

    it 'can merge in another config hash' do
      c          = Mopsy::Config.new
      extra_conf = { threads: 10 }
      c.merge!(extra_conf)
      expect(c[:threads]).to eq(10)
      expect(c.amqp).to eq('amqp://guest:guest@localhost:5672')
    end

    it 'can be accessed with []' do
      c = Mopsy::Config.new
      expect(c[:exchange_name]).to eq("mopsy")
    end

    it 'must be possible to create independent configs' do
      c           = Mopsy::Config.new
      d           = Mopsy::Config.new
      c.heartbeat = 100
      expect(d.heartbeat).to eq(30)
      expect(c.heartbeat).to eq(100)
    end

    it 'should retain user config across instances' do
      c = Mopsy::Config.configure do |c|
        c.heartbeat = 200
      end
      d = Mopsy::Config.new
      d.exchange_name = "different"

      expect(c.heartbeat).to eq(200)
      expect(d.heartbeat).to eq(200)
      expect(c.exchange_name).to eq("mopsy")
      expect(d.exchange_name).to eq("different")

      d.heartbeat = 300
      expect(d.heartbeat).to eq(300)
    end

    context 'for an attribute set in ENV' do

      it 'returns the value from the ENV var' do
        # See ENV var set in spec_helper.rb. This is due to ENV set-up happening when the class is loaded.
        c = Mopsy::Config.new
        expect(c.prefetch).to eq(1000)
      end
    end
  end
end
