require 'pry-byebug'

module Mopsy
  class Config

    # This whole thing is backed by a Hash. The idea being we get to avoid OpenStruct/Hashie etc.
    @conf     = {}
    @defaults = {}

    def initialize
      self.class.defaults = self.class.conf.dup
    end

    def [](key)
      self.class.conf[key]
    end

    def []=(key, val)
      self.class.conf[key] = val
    end

    def coerce(name, type, val)
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

    def self.conf
      @conf
    end

    def self.defaults
      @defaults
    end

    def self.defaults=(hsh)
      @defaults = hsh
    end

    def self.configure
      conf = Mopsy::Config.new
      yield conf
      conf
    end

    def self.reset!
      @conf = @defaults.dup
    end

    def self.setting(name, type = :hash, default = {}, subconf = nil, &block)
      conf              = subconf || @conf
      conf[name.to_sym] = default

      define_method(:"#{name}") do
        return conf[name.to_sym]
      end

      define_method(:"#{name}=") do |val|
        conf[name.to_sym] = coerce(name, type, val)
      end

      if block_given?
        conf[name.to_sym] = Mopsy::Config.new
        block.call conf[name.to_sym]
      end
    end

    private_class_method :setting

    setting :prefetch, :integer, 1
    setting :threads, :integer, 1
    setting :share_threads, :boolean, false
    setting :manual_ack, :boolean, true
    setting :heartbeat, :integer, 30

    setting :exchange_options do |c|
      setting :name, :string, 'mopsy', c
      setting :type, :string, :direct, c
      setting :durable, :boolean, true, c
      setting :auto_delete, :boolean, false, c
      setting :arguments, :hash, {}, c
    end

    setting :queue_options do |c|
    end
  end
end
