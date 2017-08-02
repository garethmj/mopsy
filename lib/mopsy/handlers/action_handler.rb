require 'pry-byebug'

module Mopsy
  module Handlers
    class ActionHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler
      include Mopsy::Rabbit::MessageValidator

      def initialize(queue, pool, opts = {})
        super(queue, pool, opts)
        @missing = []
      end

      # Find all the necessary metadata needed for an RPC message.
      #
      def extract_metadata(delivery_info, metadata)
        must_set metadata, :correlation_id
        must_set metadata, :reply_to
        must_set delivery_info, :delivery_tag

        raise Mopsy::InvalidActionMessageError, "Action message is missing attributes: #{@missing.join(', ')}" unless @missing.empty?
      end

      # Reply to the :reply_to field in the RPC message using the :correlation_id
      #
      def reply_with(msg = {})
        yield(msg) if block_given?

        props = {
          routing_key:    reply_to,
          correlation_id: correlation_id,
          timestamp:      Time.now.to_i
        }

        self.queue.exchange.publish(
          msg.to_json,
          props
        )
      end
    end
  end
end
