##including required libraries   
require './lib/pubnub.rb'
require 'json'

##declaring publish_key, subscribe_key, secret_key, cipher_key, message
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key = 'demo'
message    = 'HelloRuby'
channel = 'HelloWorld'
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

 end

## Create Pubnub Client API (INITIALIZATION)

puts('Creating new Pubnub Client API')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on=false)

## Send Message (PUBLISH)

puts('Sending a message with publish() Function')
info = pubnub.publish({'channel' => channel ,'message' => message})


## Print Info
puts(info)

