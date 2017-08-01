module Mopsy
  module Handlers
    module RunGroup
      attr_reader :handlers

      def initialize
        @stop        = ServerEngine::BlockingFlag.new
        @worker_pool = Concurrent::FixedThreadPool.new(1) # TODO: Pass opts here in order to use opts[:threads]
      end

      def load_handlers
        @handlers ||= begin
          config[:worker_classes].map do |w|
            w.new(nil, @worker_pool, {})
          end
        rescue => e
          Mopsy.logger.error "Unable to load handlers: #{e.message}"
          exit(1) # TODO: How on earth do we actually exit ServerEngine completely here?
        end
      end

      def run
        load_handlers

        @handlers.each do |h|
          Mopsy.logger.debug {"Starting handler: #{h}"}
          h.run
        end

        until @stop.wait_for_set
          Mopsy.logger.debug("Heartbeat: running threads [#{Thread.list.count}]")
        end
      end

      def stop
        Mopsy.logger.info("Shutting down workers")

        @handlers.each do |h|
          h.stop
        end

        @stop.set!
      end
    end
  end
end
