## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

import sys
from twisted.internet import reactor
sys.path.append('../')
from Pubnub import Pubnub

publish_key   = len(sys.argv) > 1 and sys.argv[1] or 'demo'
subscribe_key = len(sys.argv) > 2 and sys.argv[2] or 'demo'
secret_key    = len(sys.argv) > 3 and sys.argv[3] or 'demo'
cipher_key    = len(sys.argv) > 4 and sys.argv[4] or 'demo'
ssl_on        = len(sys.argv) > 5 and bool(sys.argv[5]) or False

## -----------------------------------------------------------------------
## Initiate Pubnub State
## -----------------------------------------------------------------------
pubnub = Pubnub( publish_key, subscribe_key, secret_key,cipher_key, ssl_on )
crazy  = 'hello_world'

## -----------------------------------------------------------------------
## Subscribe Example
## -----------------------------------------------------------------------
def message_received(message):
    print(message)

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
reactor.run()
