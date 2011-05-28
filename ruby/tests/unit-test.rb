## www.pubnub.com - PubNub realtime push service in the cloud. 
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog 

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------
require 'Pubnub'

publish_key   = ARGV[0] || 'demo'
subscribe_key = ARGV[1] || 'demo'
secret_key    = ARGV[2] || ''
ssl_on        = !!ARGV[3]


## ---------------------------------------------------------------------------
## Create Pubnub Client API (INITIALIZATION)
## ---------------------------------------------------------------------------
pubnub  = Pubnub.new( publish_key, subscribe_key, secret_key, ssl_on )
channel = 'ruby-unit-test-' + rand().to_s


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
pubish_success = pubnub.publish({
    'channel' => channel,
    'message' => first_message
})
test( pubish_success[0] == 1, 'Publish First Message Success' )

crazy_channel  = ' ~`!@#$%^&*(顶顅Ȓ)+=[]\\{}|;\':",./<>?abcd'
pubish_success = pubnub.publish({
    'channel' => crazy_channel,
    'message' => crazy_channel
})
test( pubish_success[0] == 1, 'Publish First Message Success' )


## ---------------------------------------------------------------------------
## Request Past Publishes (HISTORY)
## ---------------------------------------------------------------------------
history = pubnub.history({
    'channel' => crazy_channel,
    'limit'   => 1
})
test( history.length == 1, 'History Length 2' )
test( history[0] == crazy_channel, 'History Message UTF8: '  + history[0] )


## ---------------------------------------------------------------------------
## Subscribe
## ---------------------------------------------------------------------------
pubnub.subscribe({
    'channel'  => crazy_channel,
    'callback' => lambda do |message|
        puts(message) ## print message
        return true ## keep listening?
    end
})
