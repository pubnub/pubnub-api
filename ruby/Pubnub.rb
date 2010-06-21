require 'open-uri'
require 'uri'
require 'json'
#require 'net/http'

$ORIGIN = 'http://pubnub-prod.appspot.com'
$LIMIT  = 1700

class Pubnub
    def initialize( publish_key, subscribe_key )
        @publish_key   = publish_key
        @subscribe_key = subscribe_key
    end

    # info = pubnub.publish({
    #     "channel" => 'hello_world',
    #     "message" => { 'text' => 'some text data' }
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


    ## TODO This function isn't done yet.
    # pubnub.subscribe({
    #     "channel"  => 'hello_world',
    #     "callback" => proc
    # })
    def subscribe(args)
        ## Fail if missing channel
        if !args['channel']
            puts('Missing Channel.')
            return false
        end

        ## Fail if missing channel
        if !args['callback']
            puts('Missing Callback.')
            return false
        end

        return 'this function is not finished...'
    end


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

        return response['messages'];
    end


    def _request( request, args )
        ## Expecting JSONP
        args['unique'] = Time.new.to_f.to_s.gsub!( /\./, '' );

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

        return JSON.parse(response);
    end
end


