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
import tornado

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
## Time Example
## -----------------------------------------------------------------------
def time_complete(timestamp):
    print(timestamp)

pubnub.time({ 'callback' : time_complete })

## -----------------------------------------------------------------------
## History Example
## -----------------------------------------------------------------------
def history_complete(messages):
    print(messages)

pubnub.history( {
    'channel'  : crazy,
    'limit'    : 10,
    'callback' : history_complete
})

## -----------------------------------------------------------------------
## Publish Example
## -----------------------------------------------------------------------
def publish_complete(info):
    print(info)

pubnub.publish({
    'channel' : crazy,
    'message' : {
        'some_text' : 'Hello World!'
    },
    'callback' : publish_complete
})

## -----------------------------------------------------------------------
## Subscribe Example
## -----------------------------------------------------------------------
def message_received(message):
    print(message)

pubnub.subscribe({
    'channel'  : crazy,
    'callback' : message_received
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
tornado.ioloop.IOLoop.instance().start()
