module Mopsy
  module Handlers
    class Loader
      class << self
        def class_from_string(str)
          str.split('::').inject(Object) do |mod, class_name|
            mod.const_get(class_name)
          end
        end

        def find_handlers(handler_string = '')
          missing_handlers = []

          handlers = handler_string.split(',').map do |klass|
            begin
              found = class_from_string(klass)
            rescue NameError
              missing_handlers << klass
            end
            found
          end

          [handlers.compact, missing_handlers.compact]
        end
      end
    end
  end
end
