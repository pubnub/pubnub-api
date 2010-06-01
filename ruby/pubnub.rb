require 'open-uri'
require 'uri'
require 'net/http'
$PUBNUB = 'http://localhost/pubnub-'

## HTTP CLient call to GAE, then use class.

class Pubnub
    def initialize( publish_key, subscribe_key )
        @publish_key   = publish_key
        @subscribe_key = subscribe_key
    end

    def publish(channel)
    end
=begin
    def subscribe()
    end

    def unsubscribe()
    end
=end

    def register_callback_url( channel, url )
        # simple http call to server api
        url = $PUBNUB +
              'register-url?' + 
              'subscribe_key=' + 
              @subscribe_key
        r = Net::HTTP.get_response(
            URI.parse(url).host, URI.parse(url).path
        )
    end

    def unregister_callback_url(channel)
    end
end


class Echo < EventMachine::Connection
    def initialize(*args)
        super
    end

    def receive_data(data)
        puts data
    end
end

EventMachine::run {
    EventMachine::connect '127.0.0.1', 8081, Echo
}
