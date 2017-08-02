require 'pry-byebug'

module Mopsy
  module Handlers
    class ActionHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler
      include Mopsy::Rabbit::MessageValidator

      # Find all the necessary metadata needed for an RPC message.
      #
      # @param delivery_info [Hash] The message info (currently only Bunny::MessageProperties) represented as a Hash.
      # @param metadata [Hash] The message metadata - as above.
      #
      def extract_metadata(delivery_info, metadata)
        must_set metadata, :correlation_id
        must_set metadata, :reply_to
        must_set delivery_info, :delivery_tag

        unless @missing.empty?
          raise Mopsy::InvalidActionMessageError, "Action message is missing attributes: #{@missing.join(', ')}"
        end
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
