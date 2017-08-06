module Mopsy
  module Handlers
    class JobHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler
      include Mopsy::Rabbit::MessageValidator

      # Find all the necessary metadata needed for an RPC message.
      #
      # @param delivery_info [Hash] The message info (currently only Bunny::MessageProperties) represented as a Hash.
      # @param metadata [Hash] The message metadata - as above.
      #
      def extract_metadata(delivery_info, metadata)
      end
    end
  end
end
