class DumbRpcExample < Mopsy::Handlers::ActionHandler

  subscribe 'example.rpc.queue'

  def perform(delivery_info, metadata, msg)
    logger.info "DumbRpcExample received:"
    logger.info delivery_info
    logger.info metadata
    logger.info msg

    ack
    reply_with({ status: "OK" })
  end
end
