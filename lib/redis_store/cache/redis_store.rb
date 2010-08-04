module ActiveSupport
  module Cache
    # A cache store implementation which stores data in Redis.
    class RedisStore < Store
      # Creates a new RedisStore client object, with the given Redis server
      # address. The address should be given as a string. For example:
      #
      #   ActiveSupport::Cache::RedisStore.new("localhost:6379/22")
      #
      # If no addresses are specified, then RedisStore will connect to the
      # default Redis server port on localhost.
      #
      def initialize(address_or_options = {})
        @data = ::RedisStore::MarshalledClient.new(::RedisStore::Config.new(address_or_options))
      end

      # Read a value from the cache.
      def read(key, options = nil)
        super
        @data.marshalled_get(key, options)
      end

      # Write a value to the cache.
      #
      # Possible options:
      # - +:unless_exist+ - set to true if you don't want to update the cache
      #   if the key is already set.
      # - +:expires_in+ - the number of seconds that this value may stay in
      #   the cache. See ActiveSupport::Cache::Store#write for an example.
      #
      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :marshalled_setnx : :marshalled_set
        @data.send(method, key, value, options)
      end

      # Deleted a named value from the cache.
      def delete(key, options = nil)
        super
        @data.del(key)
      end

      # Check for the existence of a particular key value.
      def exist?(key, options = nil)
        super
        @data.exists(key)
      end

      # Note: to comply with the established cache store interface, matcher
      # should be a Regexp. However, converting Regexps to globs (supported by
      # Redis) is non-trivial.
      #
      # For now, we accept a string. Sorry about the conditional logic that is
      # sure to follow :(.
      #
      def delete_matched(matcher, options = nil)
        super
        raise ArgumentError.new("Sorry, matcher must be a String") unless matcher.is_a?(String)
        @data.keys(matcher).each { |key| @data.del(key) }
      end

      # Note: if key does not exist it will be initialized and return '1'.
      def increment(key, amount = 1)
        @data.incrby(key, amount)
      end

      # Note: if key does not exist it will be initialized and return '0'.
      def decrement(key, amount = 1)
        @data.decrby(key, amount)
      end

      def clear
        @data.flushdb
      end

      def stats
        @data.info
      end
    end
  end
end
