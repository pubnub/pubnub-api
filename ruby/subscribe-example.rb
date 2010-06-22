require 'Pubnub'
require 'pp'

publish_key   = ARGV[0]
subscribe_key = ARGV[1]


## Print usage if missing info.
if !(publish_key && subscribe_key)
    puts("
    Get API Keys at http://www.pubnub.com/account
    ==============
    EXAMPLE USAGE:
    ==============
    ruby subscribe.rb PUBLISH-KEY SUBSCRIBE-KEY
    ruby subscribe.rb PUBLISH-KEY SUBSCRIBE-KEY

    ")
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key )

## ----------------------
## Listen for Messages (SUBSCRIBE)
## ----------------------
puts('Listening for new messages with subscribe() Function')
puts('Press CTRL+C to quit.')
pubnub.subscribe({
    'channel'  => 'hello_world',
    'callback' => lambda do |message|
        pp(message) ## print message
        return true ## keep listening?
    end
})

puts('Done.')
