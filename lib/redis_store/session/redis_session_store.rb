require 'action_controller'

module ActionController
  module Session
    class RedisSessionStore < AbstractStore
      def initialize(app, options = {})
        options[:expire_after] ||= options[:expires]

        super

        @options = {
          :namespace => 'rack:session',
          :key_prefix => ''
        }.update(options)

        @data = options[:cache] || ::RedisStore::MarshalledClient.new(::RedisStore::Config.new(options))
      end

      private

      def prefixed(sid)
        "#{@options[:key_prefix]}#{sid}"
      end
      
      def get_session(env, sid)
        sid ||= generate_sid
        begin
          data = @data.marshalled_get(prefixed(sid))
          session = data.nil? ? {} : data
        rescue Errno::ECONNREFUSED
          session = {}
        end
        [sid, session]
      end

      def set_session(env, sid, session_data)
        options = env['rack.session.options']
        expiry  = options[:expires_in] || options[:expire_after] || nil
        
        write_options = expiry.nil? ? {} : { :expires_in => expiry }
        @data.marshalled_set(prefixed(sid), session_data, write_options)
          
        return true
      rescue Errno::ECONNREFUSED
        return false
      end
    end    
  end
end
