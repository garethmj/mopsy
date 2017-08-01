require 'concurrent/executors'
require 'serverengine'

module Mopsy
  class Runner
    def initialize(handlers, opts={})
      @runner_conf = RunnerConf.new(handlers)
    end

    def run
      @se = ServerEngine.create(nil, Handlers::RunGroup) {@runner_conf.reload!}
      @se.run
    end

    def stop
      # Graceful server engine stop
      @se.stop(true)
    end
  end

  class RunnerConf

    def initialize(handlers)
      @handlers = handlers
    end

    def reload!
      Mopsy.logger.warn("Loading runner conf")

      conf = {}
      conf.merge!({
        logger:                                 Mopsy.logger,
        worker_type:                            'process',
        worker_classes:                         @handlers,
        log_stdout:                             false,
        log_stderr:                             false,
        stop_immediately_at_unrecoverable_exit: true
      })
    end
  end
end
