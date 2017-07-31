require_relative '../spec_helper'

require 'mopsy/handlers/action_handler'

# Handler with no call to subscribe.
class BareActionHandler
  include Mopsy::Handlers::ActionHandler

  def perform(info, meta, msg)
  end
end

# A handler which subscribes to a queue.
class ListeningActionHandler
  include Mopsy::Handlers::ActionHandler

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

  describe 'handler execution' do
    it 'should perform the work of a handler' do
      h = BareActionHandler.new(@queue, test_pool)

      expect(h.queue.name).to eq(@queue.name)
      expect(h).to receive(:perform).with(nil, msg_meta, "msg")

      h.do_perform(nil, msg_meta, "msg")
    end

    it 'can subscribe to a queue' do
      h = ListeningActionHandler.new(nil, test_pool)
      expect(h.queue).to be_an_instance_of(Mopsy::Rabbit::Queue)
      expect(h.queue.name).to eq('listening.test.queue')
    end

    it 'extracts action metadata' do
      h = ListeningActionHandler.new(nil, test_pool)
      h.do_perform(nil, msg_meta, "msg")

      expect(h.reply_to).to eq('rpc.reply.queue')
    end
  end
end
