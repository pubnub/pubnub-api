## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

import sys
import datetime
import time

sys.path.append('../')
from Pubnub import Pubnub

## -----------------------------------------------------------------------
## Configuration
## -----------------------------------------------------------------------
publish_key   = len(sys.argv) > 1 and sys.argv[1] or 'demo'
subscribe_key = len(sys.argv) > 2 and sys.argv[2] or 'demo'
secret_key    = len(sys.argv) > 3 and sys.argv[3] or 'demo'
cipher_key    = len(sys.argv) > 4 and sys.argv[4] or 'demo'
ssl_on        = len(sys.argv) > 5 and bool(sys.argv[5]) or False
origin        = len(sys.argv) > 6 and sys.argv[6] or 'pubsub.pubnub.com'
#origin = '184.72.9.220'

## -----------------------------------------------------------------------
## Analytics
## -----------------------------------------------------------------------
analytics = {
    'publishes'            : 0, ## Total Send Requests
    'received'             : 0, ## Total Received Messages (Deliveries)
    'successful_publishes' : 0, ## Confirmed Successful Publish Request
    'failed_publishes'     : 0, ## Confirmed UNSuccessful Publish Request
    'failed_deliveries'    : 0  ## (successful_publishes - received)
}

trips = {
    'last'    : None,
    'current' : None,
    'max'     : 0,
    'avg'     : 0
}

## -----------------------------------------------------------------------
## Initiat Class
## -----------------------------------------------------------------------
channel = 'deliverability-' + str(time.time())
pubnub  = Pubnub(
    publish_key,
    subscribe_key,
    secret_key = secret_key,
    cipher_key = cipher_key,
    ssl_on = ssl_on,
    origin = origin
)

## -----------------------------------------------------------------------
## BENCHMARK
## -----------------------------------------------------------------------
def publish_sent(info = None):
    if info and info[0]: analytics['successful_publishes']   += 1
    else:                analytics['failed_publishes']       += 1

    analytics['publishes'] += 1
    pubnub.publish({
        'channel'  : channel,
        'callback' : publish_sent,
        'message'  : "1234567890"
    })

def received(message):
    analytics['received'] += 1
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

    ## Update Failed Deliveries
    analytics['failed_deliveries'] = \
        analytics['successful_publishes'] - analytics['received']

    ## Print Display
    print( (
       "%(date)s "                           + \
       "trip: %(total)03d "                  + \
       "%(date)s Trip: %(total)03d "         + \
       "max:%(max)03d/sec "                  + \
       "avg: %(avg)03d/sec "                 + \
       "pubs:%(publishes)05d "               + \
       "received:%(received)05d "            + \
       "spub:%(successful_publishes)05d "    + \
       "fpub:%(failed_publishes)05d "        + \
       "failed:%(failed_deliveries)05d "     + \
       ""
    ) % {
        'date'                 : current_trip,
        'total'                : trips[current_trip],
        'max'                  : trips['max'],
        'avg'                  : trips['avg'],
        'publishes'            : analytics['publishes'],
        'received'             : analytics['received'],
        'successful_publishes' : analytics['successful_publishes'],
        'failed_publishes'     : analytics['failed_publishes'],
        'failed_deliveries'    : analytics['failed_deliveries'],
        'publishes'            : analytics['publishes']
    } )

def connected(): publish_sent([1])

pubnub.subscribe({
    'channel'  : channel,
    'connect'  : connected,
    'callback' : received
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
pubnub.start()
