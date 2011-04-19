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
import datetime
import tornado

publish_key   = len(sys.argv) > 1 and sys.argv[1] or 'demo'
subscribe_key = len(sys.argv) > 2 and sys.argv[2] or 'demo'
secret_key    = len(sys.argv) > 3 and sys.argv[3] or None
ssl_on        = len(sys.argv) > 4 and bool(sys.argv[4]) or False

## -----------------------------------------------------------------------
## Initiat Class
## -----------------------------------------------------------------------
pubnub = Pubnub( publish_key, subscribe_key, secret_key, ssl_on )
crazy  = ' ~`!@#$%^&*( 顶顅 Ȓ)+=[]\\{}|;\':",./<>?abcd'

## -----------------------------------------------------------------------
## BENCHMARK
## -----------------------------------------------------------------------
def connected() :
    pubnub.publish({
        'channel' : crazy,
        'message' : { 'Info' : 'Connected!' }
    })

SUP = { 'max' : 0 }
def TMP(message):
    key = str(datetime.datetime.now())[0:19]

    if not SUP.has_key(key) :
        SUP[key] = 0

    SUP[key] = SUP[key] + 1

    if SUP[key] > SUP['max'] :
        SUP['max'] = SUP[key]

    print(message)
    pubnub.publish({
        'channel' : crazy,
        'message' : key +
            " Trip: " +
            str(SUP[key]) +
            " Max Trips: " +
            str(SUP['max']) +
            "/sec"
    })
    
pubnub.subscribe({
    'channel'  : crazy,
    'connect'  : connected,
    'callback' : TMP
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
tornado.ioloop.IOLoop.instance().start()
