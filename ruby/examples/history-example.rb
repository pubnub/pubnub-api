##including required libraries
require 'rubygems'
require './lib/pubnub.rb'

##declaring publish_key, subscribe_key, secret_key, cipher_key
  publish_key = 'demo'
  subscribe_key = 'demo'
  secret_key =''
  cipher_key ='demo'
  ssl_on = !!ARGV[4]

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

puts('Creating new Pubnub Client API')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on=false)

## Request Past Publishes (HISTORY)

puts('Requesting History with history() Function')
message = pubnub.history(
  {
      'channel' => 'HelloWorld',
      'limit'   => 20
})
puts(message)
