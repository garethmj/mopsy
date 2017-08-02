module Mopsy
  module Rabbit
    module MessageValidator
      def must_set(map, key)
        if map.has_key?(key)
          instance_variable_set "@#{key}", map[key]
          self.class.send(:attr_reader, key)
        else
          if instance_variable_defined?(:@missing) && @missing.respond_to?(:<<)
            @missing << key
          end
        end
      end
    end
  end
end
