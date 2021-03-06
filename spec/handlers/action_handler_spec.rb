require_relative '../spec_helper'

require 'mopsy/handlers/action_handler'

# Handler with no call to subscribe.
class BareActionHandler < Mopsy::Handlers::ActionHandler
  def perform(info, meta, msg)
  end
end

# A handler which subscribes to a queue.
class ListeningActionHandler < Mopsy::Handlers::ActionHandler
  subscribe 'listening.test.queue'

  def perform(info, meta, msg)
  end
end

RSpec.describe Mopsy::Handlers::ActionHandler do
  before do
    Mopsy.configure

    @queue    = double()
    @exchange = double()
    allow(@queue).to receive(:exchange).and_return(@exchange)
    allow(@queue).to receive(:name).and_return('another.test.queue')
    allow(@queue).to receive(:opts).and_return({})
    allow(@queue).to receive(:subscribe).and_return(true)
  end

  let(:test_pool) {Concurrent::ImmediateExecutor.new}
  let(:msg_meta) {{ reply_to: 'rpc.reply.queue', correlation_id: 'zzzzz' }}
  let(:msg_info) {{ delivery_tag: 'fffff' }}

  describe 'handler configuration' do
    it 'raises an error when no queue subscription is provided' do
      expect {BareActionHandler.new(nil, test_pool)}.to raise_error(Mopsy::InvalidHandlerError)
    end
  end

  describe 'handler execution' do
    it 'should perform the work of a handler' do
      h = BareActionHandler.new(@queue, test_pool)
      expect(h.queue.name).to eq(@queue.name)
      expect(h).to receive(:perform).with(msg_info, msg_meta, "msg")

      h.do_perform(msg_info, msg_meta, "msg")
    end

    it 'can subscribe to a queue' do
      h = ListeningActionHandler.new(nil, test_pool)
      expect(h.queue).to be_an_instance_of(Mopsy::Rabbit::Queue)
      expect(h.queue.name).to eq('listening.test.queue')
    end

    it 'extracts action metadata' do
      h = ListeningActionHandler.new(nil, test_pool)
      h.do_perform(msg_info, msg_meta, "msg")
      expect(h.reply_to).to eq('rpc.reply.queue')
    end

    it 'raises an error when required metadata is missing' do
      h            = ListeningActionHandler.new(nil, test_pool)
      expected_msg = "Action message is missing attributes: correlation_id, reply_to, delivery_tag"

      expect {h.do_perform({}, {}, "msg")}
        .to raise_error(Mopsy::InvalidActionMessageError, expected_msg)
    end
  end
end
