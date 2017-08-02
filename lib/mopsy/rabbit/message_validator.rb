module Mopsy
  module Rabbit
    module MessageValidator
      def must_set(map, key)
        # TODO: I'm very much in two minds about this. Defining instance vars in an included module seems crappy but works nicely here.
        unless instance_variable_defined?(:@missing) && @missing.respond_to?(:<<)
          instance_variable_set :@missing, Array.new
        end

        if map.has_key?(key)
          instance_variable_set "@#{key}", map[key]
          self.class.send(:attr_reader, key)
        else
          @missing << key
        end
      end
    end
  end
end
