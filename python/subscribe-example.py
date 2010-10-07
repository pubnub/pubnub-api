from Pubnub import Pubnub

## Subscribe Example
def receive(message) :
    print(message)
    return True

pubnub = Pubnub( 'demo', 'demo' )
print("Listening for messages...")
pubnub.subscribe({
    'channel'  : 'hello_world',
    'callback' : receive 
})


