##including required libraries
require 'rubygems'
require './lib/pubnub.rb'

##declaring publish_key, subscribe_key, secret_key, cipher_key
publish_key   = 'demo'
subscribe_key = 'demo'
secret_key    = 'demo'
cipher_key    = 'demo'
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
end

## Create Pubnub Client API (INITIALIZATION)

puts('Creating new Pubnub Client API')
pubnub = Pubnub.new(publish_key,subscribe_key,secret_key,cipher_key,ssl_on=false)

## Listen for Messages (SUBSCRIBE) 

puts('Listening for new messages with subscribe() Function')
puts('Press CTRL+C to quit.')

pubnub.subscribe({
    'channel'  => 'HelloWorld',
    'callback' => lambda do |message|
        puts(message) ## print message
        return true   ## keep listening?
    end
})
