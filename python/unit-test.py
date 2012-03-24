## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------

from Pubnub import Pubnub
import sys

publish_key   = len(sys.argv) > 1 and sys.argv[1] or 'demo'
subscribe_key = len(sys.argv) > 2 and sys.argv[2] or 'demo'
secret_key    = len(sys.argv) > 3 and sys.argv[3] or None
ssl_on        = len(sys.argv) > 4 and bool(sys.argv[4]) or False


## -----------------------------------------------------------------------
## Initiat Class
## -----------------------------------------------------------------------

pubnub = Pubnub( publish_key, subscribe_key, secret_key, ssl_on )
crazy  = ' ~`!@#$%^&*(顶顅Ȓ)+=[]\\{}|;\':",./<>?abcd'

## ---------------------------------------------------------------------------
## Unit Test Function
## ---------------------------------------------------------------------------
def test( trial, name ) :
    if trial :
        print( 'PASS: ' + name )
    else :
        print( 'FAIL: ' + name )

## -----------------------------------------------------------------------
## Publish Example
## -----------------------------------------------------------------------
pubish_success = pubnub.publish({
    'channel' : crazy,
    'message' : crazy
})
test( pubish_success[0] == 1, 'Publish First Message Success' )

## -----------------------------------------------------------------------
## History Example
## -----------------------------------------------------------------------
history = pubnub.history({
    'channel' : crazy,
    'limit'   : 1
})
test(
    history[0].encode('utf-8') == crazy,
    'History Message: ' + history[0]
)
test( len(history) == 1, 'History Message Count' )

## -----------------------------------------------------------------------
## PubNub Server Time Example
## -----------------------------------------------------------------------
timestamp = pubnub.time()
test( timestamp > 0, 'PubNub Server Time: ' + str(timestamp) )

## -----------------------------------------------------------------------
## Subscribe Example
## -----------------------------------------------------------------------
def receive(message) :
    print(message)
    return True

pubnub.subscribe({
    'channel'  : crazy,
    'callback' : receive 
})


