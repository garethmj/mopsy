module Mopsy
  module Handlers
    module Handler
      attr_reader :pool, :queue

      def initialize(queue = nil, pool = nil, opts = {})
        # There's really no point in carrying on if no one bothered to supply a queue of some sort.
        unless self.class.queue_name || queue
          raise Mopsy::InvalidHandlerError, "#{self.class.name} must subscribe to a queue, call 'subscribe'"
        end

        opts   = Mopsy.conf.merge!(opts)
        @pool  = pool || Concurrent::FixedThreadPool.new(1)
        @queue = maybe_create_queue(queue, opts)
      end

      def ack
        unless @delivery_tag
          logger.error "Unable to ack message from handler with no delivery_tag."
          return
        end

        queue.channel.ack(self.delivery_tag, false)
      end

      #
      # Handler method that is actually registered with Bunny to be called when a message is received by the
      # Mopsy::Rabbit::Queue.
      #
      def do_perform(delivery_info, metadata, msg)
        # Send this call off to a thread from the thread pool.
        @pool.post do
          logger.debug {"Handling message from #{@queue.name}"}

          begin
            # Bunny::MessageProperties only partly acts like a hash (responds to [] but nothing else). Maybe wrap it? :-\
            extract_metadata delivery_info.to_hash, metadata.to_hash

            if self.respond_to?(:perform)
              self.perform(delivery_info, metadata, msg)
            else
              logger.error "No action supplied"
            end
          rescue => e
            logger.error "Worker error: #{e.message}"
            #exit! 5
            raise
          end
        end
      end

      #
      # An, as yet, empty stub to be used for encoding messages with some form of plugable encoder.
      #
      def encode(msg)
        msg
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
        @queue.unsubscribe
      end

      def maybe_create_queue(q, opts)
        return q if !q.nil? && q.respond_to?(:subscribe) & q.respond_to?(:name)
        Mopsy::Rabbit::Queue.new(self.class.queue_name, opts)
      end

      private :maybe_create_queue

      # Class methods
      #
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_reader :queue_name

        def subscribe(q)
          @queue_name = q.to_s
        end
      end
    end
  end
end
