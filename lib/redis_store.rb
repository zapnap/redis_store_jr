gem 'redis', '~> 1.0'
gem 'activesupport', '~> 2.3'

require 'redis'
require 'active_support'

require 'redis_store/marshalled_client'
require 'redis_store/cache/redis_store'

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