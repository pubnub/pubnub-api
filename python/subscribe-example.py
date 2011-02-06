import sys
from Pubnub import Pubnub

## Initiat Class
pubnub = Pubnub( 'demo', 'demo', None, False )


## Subscribe Example
def receive(message) :
    print(message)
    return True

channel = sys.argv[1] or 'hello_world'
print("Listening for messages on '%s' channel..." % channel)
pubnub.subscribe({
    'channel'  : channel,
    'callback' : receive 
})


