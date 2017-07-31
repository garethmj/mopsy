module Mopsy
  module Handlers
    module Handler
      attr_reader :pool, :queue

      def initialize(queue = nil, pool = nil, opts = {})
        # There's really no point in carrying on if no one bothered to supply a queue of some sort.
        unless self.class.queue_name || queue
          raise ArgumentError, "#{self.class.name} must subscribe to a queue, call 'subscribe'"
        end

        opts        = Mopsy.conf.merge(opts)
        @pool       = pool || Concurrent::FixedThreadPool.new(1)
        @queue      = maybe_create_queue(queue, opts)
      end

      #
      # Handler method that is actually registered with Bunny to be called when a message is received by the
      # Mopsy::Rabbit::Queue.
      #
      def do_perform(delivery_info, metadata, msg)
        # Send this call off to a thread from the thread pool.
        @pool.post do
          logger.debug {"Handling message from #{@queue.name}"}

          extract_metadata delivery_info, metadata

          if self.respond_to?(:perform)
            self.perform(delivery_info, metadata, msg)
          else
            logger.error "No action supplied"
          end
        end
      end

      #
      # The `run` method is called by Mopsy::Handlers::RunGroup#run which is, in turn, called by ServerEngine.
      #
      def run
        logger.debug {"Subscribing #{self.class.name} to queue #{@queue.name}"}
        @queue.subscribe(self)
      end

      #
      # Called by ServerEngine when it traps SIGINT/SIGTERM to enable a graceful exit.
      #
      def stop
        logger.info {"Stopping #{self.class.name}"}
        @pool.shutdown
        @pool.wait_for_termination
        logger.info {"Stopped #{self.class.name}"}
      end

      def maybe_create_queue(q, opts)
        return q if !q.nil? && q.respond_to?(:subscribe) & q.respond_to?(:name)
        Mopsy::Rabbit::Queue.new(self.class.queue_name, opts)
      end

      private :maybe_create_queue
    end
  end
end
