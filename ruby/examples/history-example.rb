require '../lib/pubnub'

publish_key   = ARGV[0]
subscribe_key = ARGV[1]
ssl_on        = !!ARGV[2]

## Print usage if missing info.
if !subscribe_key
    puts('
    Get API Keys at http://www.pubnub.com/account
    ==============
    EXAMPLE USAGE:
    ==============
    ruby history-example.rb PUBLISH-KEY SUBSCRIBE-KEY SSL-ON
    ruby history-example.rb demo demo true

    ')
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key, nil, ssl_on )

## --------------------------------
## Request Past Publishes (HISTORY)
## --------------------------------
puts('Requesting History with history() Function')
messages = pubnub.history({
    'channel' => 'hello_world',
    'limit'   => 10
})

puts(messages)
