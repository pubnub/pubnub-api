## www.pubnub.com - PubNub realtime push service in the cloud. 
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog 

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------

##including required libraries
require 'rubygems'   
require './lib/pubnub.rb' 

##declaring publish_key, subscribe_key, secret_key, cipher_key, message, ssl_on
          publish_key   = ARGV[0] || 'demo'
          subscribe_key = ARGV[1] || 'demo'
          secret_key    = ARGV[2] || 'demo'
          cipher_key    = ARGV[3]||'demo'
          message       ='hellounit'
          ssl_on        = !!ARGV[4]


## ---------------------------------------------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## ---------------------------------------------------------------------------
          pubnub  = Pubnub.new( publish_key, subscribe_key, secret_key,cipher_key, ssl_on=false )
          channel = 'HelloWorld' + rand().to_s


## ---------------------------------------------------------------------------
## Unit Test Function
## ---------------------------------------------------------------------------
          def test( trial, name )
          trial ? puts('PASS: ' + name) : puts('FAIL: ' + name)
          end


## ---------------------------------------------------------------------------
## PubNub Server Time
## ---------------------------------------------------------------------------
          timestamp = pubnub.time()
          test( timestamp > 0, 'PubNub Server Time: ' + timestamp.to_s )


## ---------------------------------------------------------------------------
## PUBLISH
## ---------------------------------------------------------------------------
          first_message  = 'Hi. (顶顅Ȓ)'
          pubish_success = pubnub.publish({'channel' => 'HelloWorld' ,'message' => message})
          test( pubish_success[0] == 1, 'Publish First Message Success' )

## ---------------------------------------------------------------------------
## HISTORY
## ---------------------------------------------------------------------------
          history = pubnub.history({
          'channel' => 'HelloWorld',
          'limit'   => 20
          })
          puts(history)
          test( history.length >= 1, 'Display History' )

## ---------------------------------------------------------------------------
## Subscribe
## ---------------------------------------------------------------------------
          puts('Listening for new messages with subscribe() Function')
          puts('Press CTRL+C to quit.')
          pubnub.subscribe({
          'channel'  => 'HelloWorld',
          'callback' => lambda do |message|
          puts(message) ## print message
          return true   ## keep listening?
          end
          })
