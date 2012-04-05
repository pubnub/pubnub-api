## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------

try: import json
except ImportError: import simplejson as json

import time
import hashlib
import urllib2

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
        info = pubnub.publish({
            'channel' : 'hello_world',
            'message' : {
                'some_text' : 'Hello my World'
            }
        })
        print(info)

        """
        ## Fail if bad input.
        if not (args['channel'] and args['message']) :
            return [ 0, 'Missing Channel or Message' ]

        ## Capture User Input
        channel = args['channel']
        message = json.dumps(args['message'], separators=(',',':'))

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

        ## Send Message
        return self._request([
            'publish',
            self.publish_key,
            self.subscribe_key,
            signature,
            channel,
            '0',
            message
        ])


    def subscribe( self, args ) :
        """
        #**
        #* Subscribe
        #*
        #* This is BLOCKING.
        #* Listen for a message on a channel.
        #*
        #* @param array args with channel and message.
        #* @return false on fail, array on success.
        #**

        ## Subscribe Example
        def receive(message) :
            print(message)
            return True

        pubnub.subscribe({
            'channel'  : 'hello_world',
            'callback' : receive 
        })

        """

        ## Fail if missing channel
        if not 'channel' in args :
            raise Exception('Missing Channel.')
            return False

        ## Fail if missing callback
        if not 'callback' in args :
            raise Exception('Missing Callback.')
            return False

        ## Capture User Input
        channel   = args['channel']
        callback  = args['callback']

        ## Begin Subscribe
        while True :

            timetoken = 'timetoken' in args and args['timetoken'] or 0
            try :
                ## Wait for Message
                response = self._request([
                    'subscribe',
                    self.subscribe_key,
                    channel,
                    '0',
                    str(timetoken)
                ])

                messages          = response[0]
                args['timetoken'] = response[1]

                ## If it was a timeout
                if not len(messages) :
                    continue

                ## Run user Callback and Reconnect if user permits.
                for message in messages :
                    if not callback(message) :
                        return

            except Exception:
                time.sleep(1)

        return True


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
            raise Exception('Missing Channel')
            return False

        ## Get History
        return self._request([
            'history',
            self.subscribe_key,
            channel,
            '0',
            str(limit)
        ]);


    def time(self) :
        """
        #**
        #* Time
        #*
        #* Timestamp from PubNub Cloud.
        #*
        #* @return int timestamp.
        #*

        ## PubNub Server Time Example
        timestamp = pubnub.time()
        print(timestamp)

        """
        return self._request([
            'time',
            '0'
        ])[0]


    def _encode( self, request ) :
        return [
            "".join([ ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.find(ch) > -1 and
                hex(ord(ch)).replace( '0x', '%' ).upper() or
                ch for ch in list(bit)
            ]) for bit in request]


    def _request( self, request, origin = None, encode = True ) :
        ## Build URL
        url = (origin or self.origin) + '/' + "/".join(
            encode and self._encode(request) or request
        )

        ## Send Request Expecting JSONP Response
        try:
            try: usock = urllib2.urlopen( url, None, 200 )
            except TypeError: usock = urllib2.urlopen( url, None )
            response = usock.read()
            usock.close()
            return json.loads( response )
        except:
            return None

