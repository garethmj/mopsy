class DumbJobExample
  include Mopsy::Handlers::Handler

  subscribe 'example.work.queue'

  def perform(delivery_info, metadata, msg)
    logger.info "DumbJobExample received:"
    logger.info delivery_info
    logger.info metadata
    logger.info msg

    (1..20).each { |i| logger.info "DumbJobExample: doing fake work #{i}"; sleep(0.5) }
  end
end
