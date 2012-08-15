from Pubnub import Pubnub

## Initiate Class
pubnub = Pubnub( 'demo', 'demo', None, False )

## Publish Example
info = pubnub.publish({
    'channel' : 'hello_world',
    'message' : {
        'some_text' : 'Hello my World'
    }
})
print(info)

