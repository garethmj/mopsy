module Mopsy
  module Handlers
    module ActionHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler

      ActionMessageFields = [:correlation_id, :reply_to]

      # Find all the necessary metadata needed for an RPC message.
      #
      def extract_metadata(delivery_info, metadata)
        ActionMessageFields.each do |m|
          raise Mopsy::InvalidActionMessageError, "Action message is missing attribute #{m}" unless metadata.key?(m)
          instance_variable_set("@#{m}", metadata[m])
          self.class.send(:attr_reader, m)
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
