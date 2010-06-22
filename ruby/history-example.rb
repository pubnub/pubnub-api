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
    ruby history.rb PUBLISH-KEY SUBSCRIBE-KEY
    ruby history.rb PUBLISH-KEY SUBSCRIBE-KEY

    ")
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key )

## --------------------------------
## Request Past Publishes (HISTORY)
## --------------------------------
puts('Requesting History with history() Function')
messages = pubnub.history({
    'channel' => 'hello_world',
    'limit'   => 10
})

## Print Pretty
pp(messages)
#puts(info)
