import json
import time
import urllib2


class Pubnub():
    def __init__( self, publish_key, subscribe_key ) :
        """
            ## Initiat Class
            pubnub = Pubnub( 'PUBLISH-KEY', 'SUBSCRIBE-KEY' )
        """
        self.origin        = 'http://pubnub-prod.appspot.com/'
        self.limit         = 1700
        self.publish_key   = publish_key
        self.subscribe_key = subscribe_key


    def publish( self, args ) :
        """
            ## Initiat Class
            pubnub = Pubnub( 'demo', 'demo' )

            ## Publish Example
            info = pubnub.publish({
                'channel' : 'hello_world',
                'message' : {
                    'some_text' : 'Hello my World'
                }
            })
            print(info)
        """
        ## Fail if bad input
        if not ('channel' in args and 'message' and args) :
            print('Missing Channel or Message')
            return False

        ## Capture User Input
        channel = self.subscribe_key + '/' + args['channel']
        message = json.dumps(args['message'])

        ## Fail if message too long.
        if len(message) > self.limit :
            print('Message TOO LONG (' + self.limit + ' LIMIT)')
            return False

        ## Send Message
        response = self._request( self.origin + '/pubnub-publish', {
            'publish_key' : self.publish_key,
            'channel'     : channel,
            'message'     : message
        } )

        return response


    def subscribe( self, args ) :
        """
            ## Subscribe Example
            def receive(message) :
                print(message)
                return True

            pubnub = Pubnub( 'demo', 'demo' )
            pubnub.subscribe({
                'channel'  : 'hello_world',
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
        channel   = self.subscribe_key + '/' + args['channel']
        callback  = args['callback']
        timetoken = 'timetoken' in args and args['timetoken'] or '0'
        server    = 'server' in args and args['server'] or False
        listening = True

        ## Find Server
        if not server :
            resp_for_server = self._request(
                self.origin + '/pubnub-subscribe',
                {'channel' : channel}
            )

            if not 'server' in resp_for_server :
                print(args)
                print("Incorrect API Keys *OR* Out of PubNub Credits\n")
                print("Account API Keys http://www.pubnub.com/account\n")
                print("Buy Credits http://www.pubnub.com/account-buy-credit\n")
                return False

            server         = resp_for_server['server']
            args['server'] = server

        try :
            ## Wait for Message
            response = self._request( 'http://' + server + '/', {
                'channel'   : channel,
                'timetoken' : timetoken
            } )

            ## If we lost a server connection.
            if not ('messages' in response and response['messages'][0]) :
                args['server'] = False
                return self.subscribe(args)

            ## If it was a timeout
            if response['messages'][0] == 'xdr.timeout' :
                args['timetoken'] = response['timetoken']
                return self.subscribe(args)

            ## Run user Callback and Reconnect if user permits.
            for message in response['messages'] :
                listening = listening and callback(message)

            ## If okay to keep listening.
            if listening :
                args['timetoken'] = response['timetoken']
                return self.subscribe(args)
        except :
            args['server'] = False
            return self.subscribe(args)

        ## Done Listening.
        return True


    def history( self, args ) :
        """
            ## Initiat Class
            pubnub  = Pubnub( 'demo', 'demo' )

            ## History Example
            history = pubnub.history({
                'channel' : 'hello_world',
                'limit'   : 1
            })
            print(history)
        """
        ## Fail if bad input
        if not 'channel' in args :
            print('Missing Channel')
            return False

        ## Capture User Input Channel
        channel = self.subscribe_key + '/' + args['channel']

        ## Limit Provided
        if 'limit' in args :
            limit = int(args['limit'])
        else :
            limit = 10

        ## Get History
        response = pubnub._request( self.origin + '/pubnub-history', {
            'channel' : channel,
            'limit'   : limit
        } )

        return response['messages']

    def _request( self, request, args ) :
        ## Expecting JSONP
        args['unique'] = int(time.time())

        ## Format URL Params
        params = []
        for arg in args :
            params.append(
                urllib2.quote(str(arg)) + '=' +
                urllib2.quote(str(args[arg]))
            )

        ## Append Params
        request = request + '?' + '&'.join(params)

        #print('REQUEST: -> ' + request)

        ## Send Request Expecting JSONP Response
        usock    = urllib2.urlopen(request)
        response = usock.read()
        usock.close()

        response = response[response.find('(')+1: -1]
        #print(response)

        return json.loads( response )


## Demo usage of Pubnub() Class
if __name__ == '__main__':

    ## Initiat Class
    pubnub  = Pubnub( 'demo', 'demo' )

    ## Publish Example
    info = pubnub.publish({
        'channel' : 'hello_world',
        'message' : {
            'some_text' : 'Hello my World'
        }
    })
    print('\n\nPublish Response:')
    print(info)

    ## History Example
    history = pubnub.history({
        'channel' : 'hello_world',
        'limit'   : 1
    })
    print('\n\nHistory Response:')
    print(history)

    ## Subscribe Example
    def receive(message) :
        print('\n\nSubscribe Response:')
        print(message)

        return True

    pubnub.subscribe({
        'channel'  : 'hello_world',
        'callback' : receive 
    })

