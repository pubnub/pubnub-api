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
secret_key    = len(sys.argv) > 3 and sys.argv[3] or 'demo' 
cipher_key    = len(sys.argv) > 4 and sys.argv[4] or 'demo' 
ssl_on        = len(sys.argv) > 5 and bool(sys.argv[5]) or False

## -----------------------------------------------------------------------
## Initiat Class
## -----------------------------------------------------------------------
pubnub = Pubnub( publish_key, subscribe_key, secret_key,cipher_key, ssl_on )
crazy  = 'hello_world'

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
    'message' : "Hello World",
    'callback' : publish_complete
})

## -----------------------------------------------------------------------
## Subscribe Example
## -----------------------------------------------------------------------
def message_received(message):
    print(message)
    print('Disconnecting...')
    pubnub.unsubscribe({ 'channel' : crazy })

    def done() :
        print('final connection, done :)')
        pubnub.unsubscribe({ 'channel' : crazy })
        tornado.ioloop.IOLoop.instance().stop()

    def dumpster(message) :
        print('never see this')
        print(message)

    print('reconnecting...')
    pubnub.subscribe({
        'channel'  : crazy,
        'connect'  : done,
        'callback' : dumpster
    })

def connected() :
    pubnub.publish({
        'channel' : crazy,
        'message' : { 'Info' : 'Connected!' }
    })

pubnub.subscribe({
    'channel'  : crazy,
    'connect'  : connected,
    'callback' : message_received
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
tornado.ioloop.IOLoop.instance().start()
