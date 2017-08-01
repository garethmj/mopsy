#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'json'
require 'thread'
require 'uuid'

class RpcClient
  attr_reader :reply_queue, :lock, :condition
  attr_accessor :response, :correlation_id

  def initialize(ch, ex, server_queue)
    @ch           = ch
    @ex           = ex
    @server_queue = server_queue
    @reply_queue  = @ch.queue("", :exclusive => true)
    @lock         = Mutex.new
    @condition    = ConditionVariable.new
    that          = self

    @reply_queue.bind(@ex, routing_key: @reply_queue.name)

    @reply_queue.subscribe do |_, properties, payload|
      if properties[:correlation_id] == that.correlation_id
        that.response = JSON.parse(payload)
        that.lock.synchronize {that.condition.signal}
      else
        puts "  [x] Ignoring message with correlation_id: #{properties[:correlation_id]}"
      end
    end
  end

  def call(user, roles)
    now                 = Time.now
    self.correlation_id = generate_uuid
    msg                 = { user: user, roles: roles }.to_json

    @ex.publish(msg,
      app_id:         "rpc.example",
      routing_key:    @server_queue,
      correlation_id: correlation_id,
      reply_to:       @reply_queue.name,
      timestamp:      now.to_i,
      headers:        {
        retry_count: 0
      }
    )

    lock.synchronize {condition.wait(lock)}
    response
  end

  protected

  def generate_uuid
    UUID.generate
  end
end

conn   = Bunny.new(:automatically_recover => false).tap {|b| b.start}
ch     = conn.create_channel
ex     = ch.direct('mopsy', durable: true)
client = RpcClient.new(ch, ex, 'example.rpc.queue')

puts "  [x] Requesting user update or something."

response = client.call("myuser", ["admin", "somesuch"])

puts "  [x] Got #{response}"

ch.close && conn.close
