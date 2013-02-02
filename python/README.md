#YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
#http://www.pubnub.com/account

PubNub 3.3 Web Data Push Cloud-hosted API - PYTHON
www.pubnub.com - PubNub Web Data Push Service in the Cloud. 
http://github.com/pubnub/pubnub-api/tree/master/python

PubNub is a Massively Scalable Data Push Service for Web and Mobile Games.
This is a cloud-based service for broadcasting messages
to thousands of web and mobile clients simultaneously.

### Python Push API

Check out additional tests and examples in the 3.3 directory!

```python
pubnub = Pubnub(
    "demo",  ## PUBLISH_KEY
    "demo",  ## SUBSCRIBE_KEY
    None,    ## SECRET_KEY
    False    ## SSL_ON?
)
```

### PUBLISH
Send Message

```python
info = pubnub.publish({
    'channel' : 'hello_world',
    'message' : {
        'some_text' : 'Hello my World'
    }
})
print(info)
```

### SUBSCRIBE
Listen for Messages *BLOCKING*

```python
def receive(message) :
    print(message)
    return True

pubnub.subscribe({
    'channel'  : 'hello_world',
    'callback' : receive 
})
```
### PRESENCE
Listen for Presence Event Messages *BLOCKING*

```python
def pres_event(message) :
    print(message)
    return True

pubnub.presence({
    'channel'  : 'hello_world',
    'callback' : receive 
})
```

### HERE_NOW
Get info on who is here right now!

```python
here_now = pubnub.here_now({
    'channel' : 'hello_world',
})

print(here_now['occupancy'])
print(here_now['uuids'])
```
### Channel Analytics
Get usage stats.

```python
analytics = pubnub.analytics({
    'channel'  : 'channel-name-here', ## Leave blank for all channels
    'limit'    : 100,                 ## aggregation range
    'ago'      : 0,                   ## minutes ago to look backward
    'duration' : 100                  ## minutes offset
})
print(analytics)
```

### DETAILED HISTORY
Load Previously Published Messages in Detail
Optional Parameters:

'start' - Start timestamp
'end' - End timestamp
'reverse' - Search from right to left (default is false)

```python
history = pubnub.detailedHistory({
    'channel' : 'hello_world',
    'count'   : 5
    })

print(history)
```
