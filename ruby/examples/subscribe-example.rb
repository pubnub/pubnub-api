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
    ruby subscribe-example.rb PUBLISH-KEY SUBSCRIBE-KEY SSL-ON
    ruby subscribe-example.rb demo demo true

    ')
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key, nil, ssl_on )

## -------------------------------
## Listen for Messages (SUBSCRIBE)
## -------------------------------
puts('Listening for new messages with subscribe() Function')
puts('Press CTRL+C to quit.')
pubnub.subscribe({
    'channel'  => 'hello_world',
    'callback' => lambda do |message|
        puts(message) ## print message
        return true   ## keep listening?
    end
})
