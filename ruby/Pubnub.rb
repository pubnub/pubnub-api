## www.pubnub.com - PubNub realtime push service in the cloud. 
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog 

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.0 Real-time Push Cloud API
## -----------------------------------

require 'digest/md5'
require 'open-uri'
require 'uri'
require 'json'
require 'pp'

class Pubnub
    #**
    #* Pubnub
    #*
    #* Init the Pubnub Client API
    #*
    #* @param string publish_key required key to send messages.
    #* @param string subscribe_key required key to receive messages.
    #* @param string secret_key required key to sign messages.
    #* @param boolean ssl required for 2048 bit encrypted messages.
    #*
    def initialize( publish_key, subscribe_key, secret_key, ssl_on )
        @publish_key   = publish_key
        @subscribe_key = subscribe_key
        @secret_key    = secret_key
        @ssl           = ssl_on
        @origin        = 'pubsub.pubnub.com'
        @limit         = 1800

        if @ssl
            @origin = 'https://' + @origin
        else
            @origin = 'http://'  + @origin
        end
    end

    #**
    #* Publish
    #*
    #* Send a message to a channel.
    #*
    #* @param array args with channel and message.
    #* @return array success information.
    #*
    def publish(args)
        ## Fail if bad input.
        if !(args['channel'] && args['message'])
            puts('Missing Channel or Message')
            return false
        end

        ## Capture User Input
        channel = args['channel']
        message = args['message'].to_json

        ## Sign Message
        signature = @secret_key.length > 0 ? Digest::MD5.hexdigest([
            @publish_key,
            @subscribe_key,
            @secret_key,
            channel,
            message
        ].join('/')) : '0'

        ## Fail if message too long.
        if message.length > @limit
            puts('Message TOO LONG (' + @limit.to_s + ' LIMIT)')
            return [ 0, 'Message Too Long.' ]
        end

        ## Send Message
        return self._request([
            'publish',
            @publish_key,
            @subscribe_key,
            signature,
            channel,
            '0',
            message
        ])
    end

    #**
    #* Subscribe
    #*
    #* This is BLOCKING.
    #* Listen for a message on a channel.
    #*
    #* @param array args with channel and message.
    #* @return false on fail, array on success.
    #*
    def subscribe(args)
        ## Capture User Input
        channel   = args['channel']
        callback  = args['callback']
        timetoken = args['timetoken'] ? args['timetoken'] : 0

        ## Fail if missing channel
        if !channel
            echo("Missing Channel.\n")
            return false
        end

        ## Fail if missing callback
        if !callback
            echo("Missing Callback.\n")
            return false
        end

        ## Begin Recusive Subscribe
        begin
            ## Wait for Message
            response = self._request([
                'subscribe',
                @subscribe_key,
                channel,
                '0',
                timetoken.to_s
            ])

            messages          = response[0]
            args['timetoken'] = response[1]

            ## If it was a timeout
            if !messages.length
                return self.subscribe(args)
            end

            ## Run user Callback and Reconnect if user permits.
            messages.each do |message|
                if !callback.call(message)
                    return
                end
            end

            ## Keep Listening.
            return self.subscribe(args)
        rescue Timeout::Error
            return self.subscribe(args)
        rescue
            sleep(1)
            return self.subscribe(args)
        end
    end

    #**
    #* History
    #*
    #* Load history from a channel.
    #*
    #* @param array args with 'channel' and 'limit'.
    #* @return mixed false on fail, array on success.
    #*
    def history(args)
        ## Capture User Input
        limit   = +args['limit'] ? +args['limit'] : 10
        channel = args['channel']

        ## Fail if bad input.
        if (!channel)
            echo('Missing Channel')
            return false
        end

        ## Get History
        return self._request([
            'history',
            @subscribe_key,
            channel,
            '0',
            limit.to_s
        ]);
    end

    #**
    #* Time
    #*
    #* Timestamp from PubNub Cloud.
    #*
    #* @return int timestamp.
    #*
    def time()
        return self._request([
            'time',
            '0'
        ])[0]
    end

    #**
    #* Request URL
    #*
    #* @param array request of url directories.
    #* @return array from JSON response.
    #*
    def _request(request)
        ## Construct Request URL
        url = @origin + '/' + request.map{ |bit| bit.split('').map{ |ch|
            ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.index(ch) ?
            '%' + ch.unpack('H2')[0].to_s.upcase : URI.encode(ch)
        }.join('') }.join('/')

        response = ''
        open(url) do |f|
            response = f.read
        end

        return JSON.parse(response)
    end
end

