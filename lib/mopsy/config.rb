module Mopsy
  class Config

    @defaults = {}

    attr_reader :conf

    def initialize
      @conf = self.class.defaults.dup
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

    def to_bool(value)
      !(value.nil? || value == '' || value =~ /^(false|f|no|n|0)$/i || value == false)
    end

    def self.defaults
      @defaults
    end

    def self.coerce(name, type, val)
      case type
        when :boolean then
          to_bool val
        when :integer then
          val.to_i
        when :string then
          val.to_s
        else
          raise ArgumentError, "Failed to coerce setting '#{name}' to type '#{type}'"
      end
    end

    def self.configure
      conf = Mopsy::Config.new
      yield conf
      conf
    end

    def self.key_for(attr)
      key = attr.to_s.gsub('.', '_').upcase
      "MOPSY_#{key}"
    end

    def self.setting(name, type, default)
      @defaults[name.to_sym] = try_env_var(name, type)
      @defaults[name.to_sym] ||= default

      define_method(:"#{name}") do
        return self.conf[name.to_sym]
      end

      define_method(:"#{name}=") do |val|
        self.conf[name.to_sym] = self.class.coerce(name, type, val)
      end
    end

    def self.try_env_var(name, type)
      env = ENV.fetch(key_for(name), nil)
      env.nil? ? nil : coerce(name, type, env)
    end

    private_class_method :setting

    setting :prefetch, :integer, 1
    setting :threads, :integer, 1
    setting :share_threads, :boolean, false
    setting :manual_ack, :boolean, true
    setting :heartbeat, :integer, 30

    setting :exchange_name, :string, "mopsy"
  end
end
