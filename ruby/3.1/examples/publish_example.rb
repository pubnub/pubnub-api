## -----------------------------------
## PubNub Ruby API Publish Example
## -----------------------------------

## including required libraries
require 'rubygems'
require 'pubnub'

## declaring publish_key, subscribe_key, secret_key, cipher_key, channel, ssl flag, messages (Cipher key is Optional)
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key    = ''    # (Cipher key is Optional)
ssl_on        = false
channel       = 'hello_world'

strMessage = "Hi. (顶顅Ȓ)"
arrMessage = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
objMessage = {"Name"=>"John","Age"=>"23"}

## Print usage if missing info.
if !strMessage && arrMessage && objMessage
  puts('
  Get API Keys at http://www.pubnub.com/account
  ==============
  EXAMPLE USAGE:
  ==============
  ruby publish-example.rb PUB-KEY SUB-KEY SECRET-KEY "message text" SSL-ON
  ruby publish-example.rb demo demo "demo" "hey what is up?" true
  ')
  exit()
end

## Pubnub state initialization (INITIALIZATION)
puts('Initializing new Pubnub state')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on)

## Send Message (PUBLISH) -- String
puts("\nSending message in String format with publish() Function")
pubnub.publish({
  'channel' => channel,
  'message' => strMessage,
  'callback' => lambda do |message|
    puts(message)
  end
})
#puts(info)

## Send Message (PUBLISH) -- Array
puts("\nSending message in Array format with publish() Function")
pubnub.publish({
  'channel' => channel,
  'message' => arrMessage,
  'callback' => lambda do |message|
    puts(message)
  end
})
#puts(info)

## Send Message (PUBLISH) -- Object (Dictionary)
puts("\nSending message in Dictionary Object format with publish() Function")
pubnub.publish({
  'channel' => channel,
  'message' => objMessage,
  'callback' => lambda do |message|
    puts(message)
  end
})
#puts(info)
