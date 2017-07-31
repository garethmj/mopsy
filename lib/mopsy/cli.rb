require 'thor'

module Mopsy
  class CLI < Thor

    desc 'work ExampleHandlerOne,ExampleHandlerTwo', 'Run Mopsy with specified task handler classes'
    method_option :require, alises: '-r', desc: 'Comma separated file paths of your handler classes or a glob in double quotes'

    def work(handlers = '')

      # Attempt to load files required by the user. Silently discards missing files (due to Dir#glob call).
      if options[:require]
        expand_handler_paths(options[:require]).each do |r|
          require_handler(r)
        end
      end

      # Then try to find the handler classes, pack it in and go home if not.
      handlers, missing = Handlers::Loader.find_handlers(handlers)

      unless missing.empty?
        say "Unable to find handler classes: #{missing.join(', ')}"
        exit(1)
      end

      runner = Mopsy::Runner.new(handlers)
      runner.run
    end

    # Force Thor to return non-zero exit code on error.
    def self.exit_on_failure?
      true
    end

    private

    def expand_handler_paths(paths)
      paths.split(',')
        .map { |p| Dir.glob(p) }
        .flatten
    end

    def require_handler(f)
      load File.expand_path(f)
    end
  end
end
