from Pubnub import Pubnub

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

