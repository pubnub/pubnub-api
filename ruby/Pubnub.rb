## www.pubnub.com - PubNub realtime push service in the cloud. 
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog 

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## -------------
## Ruby Push API
## -------------

require 'open-uri'
require 'uri'
require 'json'
require 'pp'

$ORIGIN = 'http://pubnub-prod.appspot.com'
$LIMIT  = 1700

class Pubnub
    def initialize( publish_key, subscribe_key )
        @publish_key   = publish_key
        @subscribe_key = subscribe_key
    end

    # -------
    # PUBLISH
    # -------
    # Send Message
    # info = pubnub.publish({
    #     'channel' => 'hello_world',
    #     'message' => { 'text' => 'some text data' }
    # })
    def publish(args)
        ## Fail if not enough information
        if !(args['channel'] && args['message'])
            puts('Missing Channel or Message')
            return false
        end

        ## Capture User Input
        channel = @subscribe_key + '/' + args['channel']
        message = args['message'].to_json

        ## Fail if message too long.
        if message.length > $LIMIT
            puts('Message TOO LONG (' + $LIMIT + ' LIMIT)')
            return false
        end

        ## Send Message
        response = self._request( $ORIGIN + '/pubnub-publish', {
            'publish_key' => @publish_key,
            'channel'     => channel,
            'message'     => message
        } )

        return response
    end

    # ---------
    # SUBSCRIBE
    # ---------
    # Listen for Messages *BLOCKING*
    # pubnub.subscribe({
    #     'channel'  => 'hello_world',
    #     'callback' => lambda do |message|
    #         pp(message) ## print message
    #         return true ## keep listening?
    #     end
    # })
    def subscribe(args)
        ## Fail if missing channel
        if !args['channel']
            puts('Missing Channel.')
            return false
        end

        ## Fail if missing callback
        if !args['callback']
            puts('Missing Callback.')
            return false
        end

        ## Capture User Input
        channel   = @subscribe_key + '/' + args['channel']
        callback  = args['callback']
        timetoken = args['timetoken'] || '0'
        server    = args['server']    || false
        continue  = true

        ## Find Server
        if !server
            resp_for_server = self._request( $ORIGIN + '/pubnub-subscribe', {
                'channel' => channel
            })

            server = resp_for_server['server']
            args['server'] = server

            if !server
                pp(args)
                puts('Incorrect API Keys *OR* Out of PubNub Credits')
                puts('Account API Keys http://www.pubnub.com/account')
                puts('Buy Credits http://www.pubnub.com/account-buy-credit')
                return false
            end
        end

        ## Wait for Message
        response = self._request( 'http://' + server + '/', {
            'channel'   => channel,
            'timetoken' => timetoken
        } );

        ## If we lost a server connection.
        if !response['messages'][0]
            args['server'] = false
            return self.subscribe(args);
        end

        ## If it was a timeout
        if response['messages'][0] == 'xdr.timeout'
            args['timetoken'] = response['timetoken']
            return self.subscribe(args)
        end

        ## Run user Callback and Reconnect if user permits.
        response['messages'].each do |message|
            continue = continue && callback.call(message);
        end

        ## If okay to keep listening.
        if continue
            args['timetoken'] = response['timetoken'];
            return self.subscribe(args);
        end

        ## Done Listening
        return true
    end


    # -------
    # HISTORY
    # -------
    # Load Previously Published Messages
    # messages = pubnub.history({
    #     'channel' => 'hello_world',
    #     'limit'   => 10
    # })
    def history(args)
        ## Fail if Missing Channel
        if !args['channel']
            puts('Missing Channel')
            return false
        end

        channel = @subscribe_key + '/' + args['channel']
        limit   = args['limit'] || 10

        response = self._request( $ORIGIN + '/pubnub-history', {
            'channel' => channel,
            'limit'   => limit
        } )

        return response['messages']
    end

    # response = self._request( $ORIGIN + '/pubnub-history', {
    #     'channel' => channel,
    #     'limit'   => limit
    # } )
    def _request( request, args )
        ## Expecting JSONP
        args['unique'] = Time.new.to_f.to_s.gsub!( /\./, '' )

        ## Format URL Params
        params = []
        args.each do |key,val|
            params.push(URI.escape(key.to_s) +'='+ URI.escape(val.to_s))
        end

        ## Append Params to URL
        request += '?' + params.join('&')
        response = ''

        ## Send Request Expecting JSONP Response
        open(request) do |f|
            response = f.read
            response.gsub!( /^this\[[^\]]+\]\((.+?)\)$/, '\1' )
        end

        return JSON.parse(response)
    end
end

