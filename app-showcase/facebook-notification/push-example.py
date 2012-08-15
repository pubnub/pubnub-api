from Pubnub import Pubnub

## Initiate Class
pubnub = Pubnub( 'demo', 'demo', None, False )

## Publish Example
info = pubnub.publish({
    'channel' : 'example-user-id-1234',
    'message' : 'alert'
})
print(info)

