## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------

import sys
import json
import time
import hashlib
import urllib2

from twisted.internet import reactor
from twisted.internet.defer import Deferred
from twisted.internet.protocol import Protocol
from twisted.web.client import Agent

class Pubnub():
    def __init__(
        self,
        publish_key,
        subscribe_key,
        secret_key = False,
        ssl_on = False,
        origin = 'pubsub.pubnub.com'
    ) :
        """
        #**
        #* Pubnub
        #*
        #* Init the Pubnub Client API
        #*
        #* @param string publish_key required key to send messages.
        #* @param string subscribe_key required key to receive messages.
        #* @param string secret_key required key to sign messages.
        #* @param boolean ssl required for 2048 bit encrypted messages.
        #* @param string origin PUBNUB Server Origin.
        #**

        ## Initiat Class
        pubnub = Pubnub( 'PUBLISH-KEY', 'SUBSCRIBE-KEY', 'SECRET-KEY', False )

        """
        self.origin        = origin
        self.limit         = 1800
        self.publish_key   = publish_key
        self.subscribe_key = subscribe_key
        self.secret_key    = secret_key
        self.ssl           = ssl_on
        self.subscriptions = {}

        if self.ssl :
            self.origin = 'https://' + self.origin
        else :
            self.origin = 'http://'  + self.origin


    def publish( self, args ) :
        """
        #**
        #* Publish
        #*
        #* Send a message to a channel.
        #*
        #* @param array args with channel and message.
        #* @return array success information.
        #**

        ## Publish Example
        def publish_complete(info):
            print(info)

        pubnub.publish({
            'channel' : 'hello_world',
            'message' : {
                'some_text' : 'Hello my World'
            },
            'callback' : publish_complete
        })

        """
        ## Fail if bad input.
        if not (args['channel'] and args['message']) :
            print('Missing Channel or Message')
            return False

        ## Capture User Input
        channel = args['channel']
        message = json.dumps(args['message'])

        ## Capture Callback
        if args.has_key('callback') :
            callback = args['callback']
        else :
            callback = lambda x : x

        ## Sign Message
        if self.secret_key :
            signature = hashlib.md5('/'.join([
                self.publish_key,
                self.subscribe_key,
                self.secret_key,
                channel,
                message
            ])).hexdigest()
        else :
            signature = '0'

        ## Fail if message too long.
        if len(message) > self.limit :
            print('Message TOO LONG (' + str(self.limit) + ' LIMIT)')
            return [ 0, 'Message Too Long.' ]

        ## Send Message
        return self._request([
            'publish',
            self.publish_key,
            self.subscribe_key,
            signature,
            channel,
            '0',
            message
        ], callback )


    def subscribe( self, args ) :
        """
        #**
        #* Subscribe
        #*
        #* This is NON-BLOCKING.
        #* Listen for a message on a channel.
        #*
        #* @param array args with channel and message.
        #* @return false on fail, array on success.
        #**

        ## Subscribe Example
        def receive(message) :
            print(message)
            return True

        ## On Connect Callback
        def connected() :
            pubnub.publish({
                'channel' : 'hello_world',
                'message' : { 'some_var' : 'text' }
            })

        ## Subscribe
        pubnub.subscribe({
            'channel'  : 'hello_world',
            'connect'  : connected,
            'callback' : receive
        })

        """
        ## Fail if missing channel
        if not 'channel' in args :
            print('Missing Channel.')
            return False

        ## Fail if missing callback
        if not 'callback' in args :
            print('Missing Callback.')
            return False

        ## Capture User Input
        channel   = args['channel']
        callback  = args['callback']
        connectcb = args['connect']

        if 'errorback' in args:
            errorback = args['errorback']
        else:
            errorback = lambda x: x

        ## New Channel?
        if not (channel in self.subscriptions) :
            self.subscriptions[channel] = {
                'first'     : False,
                'connected' : 0,
                'timetoken' : '0'
            }

        ## Ensure Single Connection
        if self.subscriptions[channel]['connected'] :
            print("Already Connected")
            return False

        self.subscriptions[channel]['connected'] = 1

        ## SUBSCRIPTION RECURSION 
        def substabizel():
            ## STOP CONNECTION?
            if not self.subscriptions[channel]['connected']:
                return

            def sub_callback(response):
                ## STOP CONNECTION?
                if not self.subscriptions[channel]['connected']:
                    return

                ## CONNECTED CALLBACK
                if not self.subscriptions[channel]['first'] :
                    self.subscriptions[channel]['first'] = True
                    connectcb()

                ## PROBLEM?
                if not response:
                    def time_callback(_time):
                        if not _time:
                            reactor.callLater(time.time()+1, substabizel)
                            return errorback("Lost Network Connection")
                        else:
                            reactor.callLater(time.time()+1, substabizel)

                    ## ENSURE CONNECTED (Call Time Function)
                    return self.time({ 'callback' : time_callback })

                self.subscriptions[channel]['timetoken'] = response[1]
                substabizel()

                for message in response[0]:
                    callback(message)

            ## CONNECT TO PUBNUB SUBSCRIBE SERVERS
            try :
                self._request( [
                    'subscribe',
                    self.subscribe_key,
                    channel,
                    '0',
                    str(self.subscriptions[channel]['timetoken'])
                ], sub_callback )
            except :
                reactor.callLater(time.time()+1, substabizel)
                return

        ## BEGIN SUBSCRIPTION (LISTEN FOR MESSAGES)
        substabizel()


    def unsubscribe( self, args ):
        channel = args['channel']
        if not (channel in self.subscriptions):
            return False

        ## DISCONNECT
        self.subscriptions[channel]['connected'] = 0
        self.subscriptions[channel]['timetoken'] = 0
        self.subscriptions[channel]['first']     = False


    def history( self, args ) :
        """
        #**
        #* History
        #*
        #* Load history from a channel.
        #*
        #* @param array args with 'channel' and 'limit'.
        #* @return mixed false on fail, array on success.
        #*

        ## History Example
        history = pubnub.history({
            'channel' : 'hello_world',
            'limit'   : 1
        })
        print(history)

        """
        ## Capture User Input
        limit   = args.has_key('limit') and int(args['limit']) or 10
        channel = args['channel']

        ## Fail if bad input.
        if not channel :
            print('Missing Channel')
            return False

        ## Get History
        return self._request( [
            'history',
            self.subscribe_key,
            channel,
            '0',
            str(limit)
        ], args['callback'] )

    def time( self, args ) :
        """
        #**
        #* Time
        #*
        #* Timestamp from PubNub Cloud.
        #*
        #* @return int timestamp.
        #*

        ## PubNub Server Time Example
        def time_complete(timestamp):
            print(timestamp)

        pubnub.time(time_complete)

        """
        def complete(response) :
            if not response: return 0
            args['callback'](response[0])

        self._request( [
            'time',
            '0'
        ], complete )

    def _request( self, request, callback ) :
        ## Build URL
        url = self.origin + '/' + "/".join([
            "".join([ ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.find(ch) > -1 and
                hex(ord(ch)).replace( '0x', '%' ).upper() or
                ch for ch in list(bit)
            ]) for bit in request])

        agent   = Agent(reactor)
        request = agent.request( 'GET', url, None )

        def received(response):
            finished = Deferred()
            response.deliverBody(PubNubResponse(finished))
            return finished

        def complete(data):
            try    : obj = json.loads(data)
            except : obj = None

            callback(obj)

        request.addCallback(received)
        request.addBoth(complete)

        ## OLD
        """
        def complete(response) :
            if response.error:
                return callback(None)
            callback(json.loads(response.buffer.getvalue()))

        ## Send Request Expecting JSON Response
        http = tornado.httpclient.AsyncHTTPClient()
        http.fetch(
            url,
            callback=complete,
            connect_timeout=200,
            request_timeout=200
        )
        """
        ## OLD


class PubNubResponse(Protocol):
    def __init__( self, finished ):
        self.finished = finished

    def dataReceived( self, bytes ):
            self.finished.callback(bytes)

    #def connectionLost( self, reason ):
        #print 'Finished receiving body:', reason.getErrorMessage()
