require 'Pubnub'

publish_key   = ARGV[0]
subscribe_key = ARGV[1]
secret_key    = ARGV[2]
message       = ARGV[3]
ssl_on        = !!ARGV[4]

## Print usage if missing info.
if !message
    puts('
    Get API Keys at http://www.pubnub.com/account
    ==============
    EXAMPLE USAGE:
    ==============
    ruby publish-example.rb PUB-KEY SUB-KEY SECRET-KEY "message text" SSL-ON
    ruby publish-example.rb demo demo "" "hey what is up?" true

    ')
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key, secret_key, ssl_on )

## ----------------------
## Send Message (PUBLISH)
## ----------------------
puts('Sending a message with publish() Function')
info = pubnub.publish({
    'channel' => 'hello_world',
    'message' => message
})

## Print Pretty
puts(info)
