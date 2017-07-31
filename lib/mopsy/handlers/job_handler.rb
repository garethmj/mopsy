module Mopsy
  module Handlers
    module JobHandler
      include Mopsy::Concerns::Logging
      include Mopsy::Handlers::Handler

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
