## -----------------------------------
## PubNub Ruby API Subscribe Example
## -----------------------------------

## including required libraries
require 'rubygems'
require 'pubnub'

## declaring publish_key, subscribe_key, secret_key, cipher_key, ssl flag (Cipher key is Optional)
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key    = ''    # (Cipher key is Optional)
ssl_on        = false
channel       = 'hello_world'

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

## Create Pubnub Client API (INITIALIZATION)
puts('Initializing new Pubnub state')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on)

## Listen for Messages (SUBSCRIBE)
puts('Listening for new messages with subscribe() Function')
puts('Press CTRL+C to quit.')
pubnub.subscribe({
  'channel'  => channel,
  'callback' => lambda do |message|
  puts(message) ## print message
  return true   ## keep listening?
  end
})
