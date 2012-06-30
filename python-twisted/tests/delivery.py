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
import math

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
origin = '184.72.9.220'

## -----------------------------------------------------------------------
## Analytics
## -----------------------------------------------------------------------
analytics = {
    'publishes'            : 0,   ## Total Send Requests
    'received'             : 0,   ## Total Received Messages (Deliveries)
    'queued'               : 0,   ## Total Unreceived Queue (UnDeliveries)
    'successful_publishes' : 0,   ## Confirmed Successful Publish Request
    'failed_publishes'     : 0,   ## Confirmed UNSuccessful Publish Request
    'failed_deliveries'    : 0,   ## (successful_publishes - received)
    'deliverability'       : 0    ## Percentage Delivery
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
    analytics['queued']    += 1

    pubnub.timeout( send, 0.1 )

def send():
    if analytics['queued'] < 100:
        pubnub.publish({
            'channel'  : channel,
            'callback' : publish_sent,
            'message'  : "1234567890"
        })

def received(message):
    analytics['queued']   -= 1
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

def show_status():
    ## Update Failed Deliveries
    analytics['failed_deliveries'] = \
        analytics['successful_publishes'] \
        - analytics['received'] \
        + analytics['queued'] \
        + analytics['failed_publishes']

    ## Update Deliverability
    analytics['deliverability'] = (
        float(analytics['received']) / \
        float(analytics['publishes'] or 1.0)
    ) * 100.0

    """
    if analytics['deliverability'] > 100.0:
        analytics['deliverability'] = 100.0
    """

    ## Print Display
    print( (
       "max:%(max)03d/sec  "                  + \
       "avg:%(avg)03d/sec  "                  + \
       "pubs:%(publishes)05d  "               + \
       "received:%(received)05d  "            + \
       "spub:%(successful_publishes)05d  "    + \
       "fpub:%(failed_publishes)05d  "        + \
       "failed:%(failed_deliveries)05d  "     + \
       "queued:%(queued)03d  "                + \
       "delivery:%(deliverability)03f%%  "    + \
       ""
    ) % {
        'max'                  : trips['max'],
        'avg'                  : trips['avg'],
        'publishes'            : analytics['publishes'],
        'received'             : analytics['received'],
        'successful_publishes' : analytics['successful_publishes'],
        'failed_publishes'     : analytics['failed_publishes'],
        'failed_deliveries'    : analytics['failed_deliveries'],
        'publishes'            : analytics['publishes'],
        'deliverability'       : analytics['deliverability'],
        'queued'               : analytics['queued']
    } )
    pubnub.timeout( show_status, 1 )

def connected():
    show_status()
    pubnub.timeout( send, 1 )

print( "Connected: %s\n" % origin )
pubnub.subscribe({
    'channel'  : channel,
    'connect'  : connected,
    'callback' : received
})

## -----------------------------------------------------------------------
## IO Event Loop
## -----------------------------------------------------------------------
pubnub.start()
