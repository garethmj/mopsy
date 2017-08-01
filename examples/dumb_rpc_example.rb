require 'pry-byebug'

class DumbRpcExample
  include Mopsy::Handlers::ActionHandler

  subscribe 'example.rpc.queue'

  def perform(delivery_info, metadata, msg)
    logger.info "DumbRpcExample received:"
    logger.info delivery_info
    logger.info metadata
    logger.info msg

    ack delivery_info
    reply_with({ status: "OK" })
  end
end
