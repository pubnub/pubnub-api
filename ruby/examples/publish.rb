$:.unshift '/opt/pubnub/github/ruby'
require 'Pubnub'
require 'pp'

publish_key   = ARGV[0]
subscribe_key = ARGV[1]
message       = ARGV[2]


## Print usage if missing info.
if !(publish_key && subscribe_key && message)
    puts("
    ==============
    EXAMPLE USAGE:
    ==============
    ruby publish.rb PUBLISH-KEY SUBSCRIBE-KEY 'ANY MESSAGE HERE'
    ruby publish.rb PUBLISH-KEY SUBSCRIBE-KEY 'Hey what is up?'

    ")
    exit()
end

## -----------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## -----------------------------------------
puts('Creating new Pubnub Client API')
pubnub = Pubnub.new( publish_key, subscribe_key )



## ----------------------
## Send Message (PUBLISH)
## ----------------------
puts('Sending a message with Publish Function')
info = pubnub.publish({
    "channel" => 'hello_world',
    "message" => message
})

## Print Pretty
pp(info)
#puts(info)
