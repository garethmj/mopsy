require_relative '../spec_helper'

require 'mopsy/handlers/run_group'

RSpec.describe Mopsy::Handlers::RunGroup do
  before do
    # A do-nothing handler class for use as a mock type thingy.
    class FakeHandler
      include Mopsy::Handlers::JobHandler

      subscribe 'fake.queue'

      def perform
      end
    end

    # Can't create an instance of a module so include it in a wrapper class.
    class MyRunGroup
      include Mopsy::Handlers::RunGroup
    end

    # Need to make sure logger is configured.
    Mopsy.configure

    # Fake the injected `config` var from ServerEngine black magic.
    allow_any_instance_of(Mopsy::Handlers::RunGroup).to receive(:config).and_return({ worker_classes: [FakeHandler] })
  end

  let(:rg) { MyRunGroup.new }

  describe 'handler configuration' do
    it 'fetches worker classes from ServerEngine injected config' do
      expect(rg.load_handlers.first).to be_an_instance_of(FakeHandler)
      expect(rg.load_handlers.first.pool).to be_an_instance_of(Concurrent::FixedThreadPool)
    end
  end

  describe '#run' do
    it 'sends #do_perform to registered handlers' do
      allow_any_instance_of(ServerEngine::BlockingFlag).to receive(:wait_for_set).and_return(true)
      rg.load_handlers
      expect(rg.handlers.first).to receive(:run)
      rg.run
    end
  end
end
