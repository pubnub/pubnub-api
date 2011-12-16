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
from twisted.internet import reactor

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

trips = { 'last' : None, 'current' : None, 'max' : 0, 'avg' : 0 }

def received(message):
    current_trip = trips['current'] = str(datetime.datetime.now())[0:19]
    last_trip    = trips['last']    = str(
        datetime.datetime.now() - datetime.timedelta(seconds=1)
    )[0:19]

    ## New Trip Span (1 Second)
    if not trips.has_key(current_trip) :
        trips[current_trip] = 0

        ## Average
        if trips.has_key(last_trip):
            trips['avg'] = (trips['avg'] + trips[last_trip]) / 2

    ## Increment Trip Counter
    trips[current_trip] = trips[current_trip] + 1

    ## Update Max
    if trips[current_trip] > trips['max'] :
        trips['max'] = trips[current_trip]


    print(message)

    pubnub.publish({
        'channel' : crazy,
        'message' : current_trip     +
            " Trip: "                +
            str(trips[current_trip]) +
            " MAX: "                 +
            str(trips['max'])        +
            "/sec "                  +
            " AVG: "                 +
            str(trips['avg'])        +
            "/sec"
    })

pubnub.subscribe({
    'channel'  : crazy,
    'connect'  : connected,
    'callback' : received
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
reactor.run()
