module Mopsy
  class Config

    @conf     = {}
    @defaults = {}

    attr_reader :conf

    def initialize
      @conf         = self.class.conf.dup
      @conf[:amqp]  = ENV.fetch('RABBITMQ_URL', 'amqp://guest:guest@localhost:5672')
      @conf[:vhost] = AMQ::Settings.parse_amqp_url(@conf[:amqp]).fetch(:vhost, '/')
    end

    def [](key)
      self.conf[key]
    end

    def []=(key, val)
      self.conf[key] = val
    end

    def merge!(other_hash, &block)
      other_hash.each_pair do |current_key, other_value|
        this_value = self[current_key]

        self[current_key] = if this_value.is_a?(Mopsy::Config) && (other_value.is_a?(Hash) || other_value.is_a?(Mopsy::Config))
          this_value.merge!(other_value, &block)
        else
          if block_given? && key?(current_key)
            block.call(current_key, this_value, other_value)
          else
            other_value
          end
        end
      end

      self
    end

    class << self
      def defaults
        @defaults
      end

      def conf
        @conf = @defaults.dup if @conf.empty?
        @conf
      end

      def coerce(name, type, val)
        case type
          when :boolean then
            to_bool val
          when :hash then
            val.to_h
          when :integer then
            val.to_i
          when :string then
            val.to_s
          when :symbol then
            val.to_sym
          else
            raise ArgumentError, "Failed to coerce setting '#{name}' to type '#{type}'"
        end
      end

      def configure
        c = Mopsy::Config.new
        yield c
        @conf.merge!(c.conf)
        c
      end

      def key_for(attr)
        key = attr.to_s.gsub('.', '_').upcase
        "MOPSY_#{key}"
      end

      def reset!
        @conf = @defaults.dup
      end

      def setting(name, type, default)
        @defaults[name.to_sym] = try_env_var(name, type)
        @defaults[name.to_sym] ||= default

        define_method(:"#{name}") do
          return self.conf[name.to_sym]
        end

        define_method(:"#{name}=") do |val|
          self.conf[name.to_sym] = self.class.coerce(name, type, val)
        end
      end

      def to_bool(value)
        !(value.nil? || value == '' || value =~ /^(false|f|no|n|0)$/i || value == false)
      end

      def try_env_var(name, type)
        env = ENV.fetch(key_for(name), nil)
        env.nil? ? nil : coerce(name, type, env)
      end
    end

    private_class_method :setting

    setting :amqp, :string, "amqp://guest:guest@localhost:5672"
    setting :heartbeat, :integer, 30
    setting :manual_ack, :boolean, true
    setting :prefetch, :integer, 1
    setting :share_threads, :boolean, false
    setting :threads, :integer, 1
    setting :vhost, :string, "/"

    setting :exchange_name, :string, "mopsy"
    setting :exchange_options, :hash, {
      type:        :direct,
      durable:     true,
      auto_delete: false,
      arguments:   {}
    }

    setting :queue_options, :hash, {
      durable:     true,
      auto_delete: false,
      exclusive:   false,
      arguments:   {}
    }
  end
end
