require 'bunny'
require 'json'

require 'mopsy/version'
require 'mopsy/conf'
require 'mopsy/cli'
require 'mopsy/errors'
require 'mopsy/concerns/logging'
require 'mopsy/rabbit/message_validator'
require 'mopsy/rabbit/queue'
require 'mopsy/handlers/loader'
require 'mopsy/handlers/handler'
require 'mopsy/handlers/action_handler'
require 'mopsy/handlers/job_handler'
require 'mopsy/handlers/run_group'
require 'mopsy/runner'

module Mopsy
  extend self

  def configure
    @conf         = Mopsy::Conf.new
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    Handlers::ActionHandler.configure_logger(@logger)
    Handlers::JobHandler.configure_logger(@logger)
  end

  def conf
    @conf
  end

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger
  end
end
