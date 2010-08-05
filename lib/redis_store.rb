gem 'redis', '~> 1.0'
gem 'activesupport', '~> 2.3'
gem 'actionpack', '~> 2.3'

require 'redis'
require 'active_support'
require 'action_controller'

require 'redis_store/marshalled_client'
require 'redis_store/cache/redis_store'
require 'redis_store/session/redis_session_store'

class RedisStore
  class Config < Hash
    def initialize(address_or_options)
      options = if address_or_options.is_a?(Hash)
        address_or_options
      else
        host, port = address_or_options.split(/\:/)
        port, db = port.split(/\//) if port
        { :host => host, :port => port, :db => db }
      end

      self[:host] = options[:host] if options[:host]
      self[:port] = options[:port] if options[:port]
      self[:db] = options[:db] if options[:db]
    end
  end
end

Redis.class_eval do
  def self.deprecate(message, trace = caller[0])
    # No-op. Suppress Redis 2.0 setex warnings (target is Redis 1.2).
  end
end

