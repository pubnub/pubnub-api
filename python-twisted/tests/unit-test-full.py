## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## TODO Tests
##
## - wait 20 minutes, send a message, receive and success.
## - 
## - 
## 
## 

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

import sys
sys.path.append('../')
from Pubnub import Pubnub

publish_key   = len(sys.argv) > 1 and sys.argv[1] or 'demo'
subscribe_key = len(sys.argv) > 2 and sys.argv[2] or 'demo'
secret_key    = len(sys.argv) > 3 and sys.argv[3] or None 
cipher_key    = len(sys.argv) > 4 and sys.argv[4] or None
ssl_on        = len(sys.argv) > 5 and bool(sys.argv[5]) or False

## -----------------------------------------------------------------------
## Command Line Options Supplied PubNub
## -----------------------------------------------------------------------
pubnub_user_supplied_options = Pubnub(
    publish_key,   ## OPTIONAL (supply None to disable)
    subscribe_key, ## REQUIRED
    secret_key,    ## OPTIONAL (supply None to disable)
    cipher_key,    ## OPTIONAL (supply None to disable)
    ssl_on         ## OPTIONAL (supply None to disable)
)

## -----------------------------------------------------------------------
## High Security PubNub
## -----------------------------------------------------------------------
pubnub_high_security = Pubnub(
    ## Publish Key
    'pub-c-a30c030e-9f9c-408d-be89-d70b336ca7a0',

    ## Subscribe Key
    'sub-c-387c90f3-c018-11e1-98c9-a5220e0555fd',

    ## Secret Key
    'sec-c-MTliNDE0NTAtYjY4Ni00MDRkLTllYTItNDhiZGE0N2JlYzBl',

    ## Cipher Key
    'YWxzamRmbVjFaa05HVnGFqZHM3NXRBS73jxmhVMkjiwVVXV1d5UrXR1JLSkZFRr'+
    'WVd4emFtUm1iR0TFpUZvbiBoYXMgYmVlbxWkhNaF3uUi8kM0YkJTEVlZYVFjBYi'+
    'jFkWFIxSkxTa1pGUjd874hjklaTFpUwRVuIFNob3VsZCB5UwRkxUR1J6YVhlQWa'+
    'V1ZkNGVH32mDkdho3pqtRnRVbTFpUjBaeGUgYXNrZWQtZFoKjda40ZWlyYWl1eX'+
    'U4RkNtdmNub2l1dHE2TTA1jd84jkdJTbFJXYkZwWlZtRnKkWVrSRhhWbFpZVmFz'+
    'c2RkZmTFpUpGa1dGSXhTa3hUYTFwR1Vpkm9yIGluZm9ybWFNfdsWQdSiiYXNWVX'+
    'RSblJWYlRGcFVqQmFlRmRyYUU0MFpXbHlZV2wxZVhVNFJrTnR51YjJsMWRIRTJU'+
    'W91ciBpbmZvcm1hdGliBzdWJtaXR0ZWQb3UZSBhIHJlc3BvbnNlLCB3ZWxsIHJl'+
    'VEExWdHVybiB0am0aW9uIb24gYXMgd2UgcG9zc2libHkgY2FuLuhcFe24ldWVns'+
    'dSaTFpU3hVUjFKNllWaFdhRmxZUWpCaQo34gcmVxdWlGFzIHNveqQl83snBfVl3',

    ## 2048bit SSL ON - ENABLED TRUE
    True
)

## -----------------------------------------------------------------------
## Channel | Message Test Data (UTF-8)
## -----------------------------------------------------------------------
crazy            = ' ~`â¦â§!@#$%^&*(顶顅Ȓ)+=[]\\{}|;\':",./<>?abcd'
many_channels    = [ str(x) + '-many_channel_test' for x in range(10) ]
runthroughs      = 0
planned_tests    = 2
delivery_retries = 0
max_retries      = 10

## -----------------------------------------------------------------------
## Unit Test Function
## -----------------------------------------------------------------------
def test( trial, name ) :
    if trial : print( 'PASS: ' + name )
    else :     print( '- FAIL - ' + name )

def test_pubnub(pubnub):
    global runthroughs, planned_tests, delivery_retries, max_retries

    ## -----------------------------------------------------------------------
    ## Many Channels
    ## -----------------------------------------------------------------------
    def phase2():
        status = {
            'sent'        : 0,
            'received'    : 0,
            'connections' : 0
        }

        def received( message, chan ):
            global runthroughs

            test( status['received'] <= status['sent'], 'many sends' )
            status['received'] += 1
            pubnub.unsubscribe({ 'channel' : chan })
            if status['received'] == len(many_channels):
                runthroughs += 1
                if runthroughs == planned_tests: pubnub.stop()

        def publish_complete( info, chan ):
            global delivery_retries, max_retries
            status['sent'] += 1
            test( info, 'publish complete' )
            test( info and len(info) > 2, 'publish response' )
            if not info[0]:
                delivery_retries += 1
                if max_retries > delivery_retries: sendit(chan)

        def sendit(chan):
            tchan = chan
            pubnub.publish({
                'channel'  : chan,
                'message'  : "Hello World",
                'callback' : (lambda msg:publish_complete( msg, tchan ))
            })

        def connected(chan):
            status['connections'] += 1
            sendit(chan)

        def delivered(info):
            if info and info[0]: status['sent'] += 1

        def subscribe(chan):
            pubnub.subscribe({
                'channel'  : chan,
                'connect'  : (lambda:connected(chan+'')),
                'callback' : (lambda msg:received( msg, chan ))
            })

        ## Subscribe All Channels
        for chan in many_channels: subscribe(chan)
        
    ## -----------------------------------------------------------------------
    ## Time Example
    ## -----------------------------------------------------------------------
    def time_complete(timetoken):
        test( timetoken, 'timetoken fetch' )
        test( isinstance( timetoken, int ), 'timetoken int type' )

    pubnub.time({ 'callback' : time_complete })

    ## -----------------------------------------------------------------------
    ## Publish Example
    ## -----------------------------------------------------------------------
    def publish_complete(info):
        test( info, 'publish complete' )
        test( info and len(info) > 2, 'publish response' )

        pubnub.history( {
            'channel'  : crazy,
            'limit'    : 10,
            'callback' : history_complete
        })

    ## -----------------------------------------------------------------------
    ## History Example
    ## -----------------------------------------------------------------------
    def history_complete(messages):
        test( messages and len(messages) > 0, 'history' )
        test( messages, 'history' )


    pubnub.publish({
        'channel'  : crazy,
        'message'  : "Hello World",
        'callback' : publish_complete
    })

    ## -----------------------------------------------------------------------
    ## Subscribe Example
    ## -----------------------------------------------------------------------
    def message_received(message):
        test( message, 'message received' )
        pubnub.unsubscribe({ 'channel' : crazy })

        def done() :
            pubnub.unsubscribe({ 'channel' : crazy })
            pubnub.publish({
                'channel'  : crazy,
                'message'  : "Hello World",
                'callback' : (lambda x:x)
            })

        def dumpster(message) :
            test( 0, 'never see this' )

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

    phase2()

## -----------------------------------------------------------------------
## Run Tests
## -----------------------------------------------------------------------
test_pubnub(pubnub_user_supplied_options)
test_pubnub(pubnub_high_security)
pubnub_high_security.start()

