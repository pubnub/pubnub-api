from Pubnub import Pubnub

## Initiat Class
pubnub = Pubnub( 'demo', 'demo', None, False )

## Subscribe Example
def receive(message) :
    print(message)
    return True

print("Listening for messages...")
pubnub.subscribe({
    'channel'  : 'hello_world',
    'callback' : receive 
})


