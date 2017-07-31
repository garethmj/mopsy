class DumbRpcExample
  include Mopsy::Handlers::Handler

  subscribe 'example.rpc.queue'

  def perform(delivery_info, metadata, msg)
    logger.info "DumbRpcExample received:"
    logger.info delivery_info
    logger.info metadata
    logger.info msg

    (1..20).each { |i| logger.info "DumbRpcExample: doing fake work #{i}"; sleep(0.5) }
  end
end
