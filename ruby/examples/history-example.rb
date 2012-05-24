## -----------------------------------
## PubNub Ruby API History Example
## -----------------------------------

## including required libraries
require 'rubygems'
require './lib/pubnub.rb'

## declaring publish_key, subscribe_key, secret_key, cipher_key and ssl flag
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key    = 'demo'
ssl_on = true

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
end

## Create Pubnub Client API (INITIALIZATION)
puts('Initialize new Pubnub state')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on)

## Request Past Publishes (HISTORY)
puts('Requesting History with history() Function')
message = pubnub.history(
{
  'channel' => 'hello_world',
  'limit'   => 3
})
puts(message)
