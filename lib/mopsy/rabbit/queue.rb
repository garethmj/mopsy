require 'bunny'

module Mopsy
  module Rabbit
    class Queue
      attr_reader :channel, :exchange, :name, :opts, :bunny

      def initialize(name, opts)
        @name = name
        @opts = opts
      end

      def subscribe(handler)
        @bunny ||=
          Bunny.new(opts[:amqp],
            {
              vhost:      opts[:vhost],
              heartbeat:  opts[:heartbeat],
              properties: opts.fetch(:properties, {}),
              logger:     Mopsy.logger
            })
            .tap { |b| b.start }

        @channel = @bunny.create_channel
        @channel.prefetch(opts[:prefetch])

        exchange_name = opts[:exchange]
        routing_key   = opts[:routing_key] || @name
        routing_keys  = [*routing_key]
        @exchange     = @channel.exchange(exchange_name, opts[:exchange_options])
        @queue        = @channel.queue(name, opts[:queue_options])

        if exchange_name.length > 0
          routing_keys.each do |key|
            @queue.bind(@exchange, routing_key: key)
          end
        end

        # Subscribe the handler to the actual Rabbit queue.
        @consumer = @queue.subscribe(block: false, manual_ack: opts[:manual_ack]) do |delivery_info, metadata, msg|
          handler.do_perform(delivery_info, metadata, msg)
        end
      end

      def unsubscribe
        # TODO: better to handle cancel_ok response here?
        @consumer.cancel
      end
    end
  end
end
