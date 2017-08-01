module Mopsy
  module Handlers
    module ActionHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler

      # Find all the necessary metadata needed for an RPC message.
      #
      def extract_metadata(delivery_info, metadata)
        @reply_to       = metadata[:reply_to]
        @correlation_id = metadata[:correlation_id]

        raise Mopsy::InvalidActionMessageError, "Action message is missing attribute reply_to" unless @reply_to
        raise Mopsy::InvalidActionMessageError, "Action message is missing attribute correlation_id" unless @correlation_id

        logger.debug {"Message correlation-id: #{@correlation_id}, reply-to: #{@reply_to}"}
      end

      # Reply to the :reply_to field in the RPC message using the :correlation_id
      #
      def reply_with(msg = {})
        yield(msg) if block_given?

        props = {
          routing_key:    @reply_to,
          correlation_id: @correlation_id,
          timestamp:      Time.now.to_i,
          headers:        {
            retry_count: 0
          }
        }

        begin
          self.queue.exchange.publish(
            msg.to_json,
            props
          )
        rescue Bunny::ChannelLevelException => e
          logger.debug "Trapped exception: #{e.message}"
        end
      end

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
