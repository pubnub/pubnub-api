import sys
import threading
import time
import random
import string
from Pubnub import Pubnub

## Initiate Class
pubnub = Pubnub( 'demo', 'demo', None, False )

print("My UUID is: "+pubnub.uuid)

channel = ''.join(random.choice(string.ascii_letters + string.digits) for x in range(20))

## Subscribe Example
def receive(message) :
    print(message)
    return False

def pres_event(message):
    print(message)
    return False

def subscribe():
    print("Listening for messages on '%s' channel..." % channel)
    pubnub.subscribe({
        'channel'  : channel,
        'callback' : receive 
    })

def presence():
    print("Listening for presence events on '%s' channel..." % channel)
    pubnub.presence({
        'channel'  : channel,
        'callback' : pres_event 
    })

def publish():
    print("Publishing a test message on '%s' channel..." % channel)
    pubnub.publish({
        'channel'  : channel,
        'message'  : { 'text':'foo bar' }
    })

pres_thread = threading.Thread(target=presence)
pres_thread.daemon=True
pres_thread.start()

sub_thread = threading.Thread(target=subscribe)
sub_thread.daemon=True
sub_thread.start()

time.sleep(3)

publish()


print("waiting for subscribes and presence")
pres_thread.join()

print pubnub.here_now({'channel':channel})

sub_thread.join()

