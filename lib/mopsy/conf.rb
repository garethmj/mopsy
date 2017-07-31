require 'forwardable'

module Mopsy
  class Conf
    extend Forwardable
    def_delegators :@hash, :delete, :fetch, :has_key?, :merge, :to_hash, :[], :[]=, :==

    EXCHANGE_OPTION_DEFAULTS = {
      type:        :direct,
      durable:     true,
      auto_delete: false,
      arguments:   {}
    }.freeze

    QUEUE_OPTION_DEFAULTS = {
      durable:     true,
      auto_delete: false,
      exclusive:   false,
      arguments:   {}
    }.freeze

    DEFAULTS = {
      # runner
      runner_config_file: nil,
      metrics:            nil,
      start_worker_delay: 0.2,
      workers:            4,
      log:                STDOUT,
      pid_path:           'mopsy.pid',
      amqp_heartbeat:     30,

      # workers
      timeout_job_after:  5,
      prefetch:           10,
      threads:            10,
      share_threads:      false,
      ack:                true,
      heartbeat:          30,
      hooks:              {},
      exchange:           'mopsy',
      exchange_options:   EXCHANGE_OPTION_DEFAULTS,
      queue_options:       QUEUE_OPTION_DEFAULTS
    }.freeze


    def initialize
      @hash         = DEFAULTS.dup
      @hash[:amqp]  = ENV.fetch('RABBITMQ_URL', 'amqp://guest:guest@localhost:5672')
      @hash[:vhost] = AMQ::Settings.parse_amqp_url(@hash[:amqp]).fetch(:vhost, '/')
    end
  end
end
