Pubnub - http://github/pubnub/pubnub-api
@poptartinc on Twitter, @poptart on Github

##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.1 Real-time Cloud Push API - RUBY

www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/blog/ruby-push-api

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

----------------------------
### Ruby Push API
----------------------------

```ruby
pubnub = Pubnub.new(
    "demo",  ## PUBLISH_KEY
    "demo",  ## SUBSCRIBE_KEY
    "demo",  ## SECRET_KEY
    "",      ## CIPHER_KEY (Cipher key is Optional)
    false    ## SSL_ON?
)
```

------------------------------------------------------
### PUBLISH STRING MESSAGE
------------------------------------------------------
##### Send Message

```
pubnub.publish({
    'channel' => 'hello_world',
    'message' => 'hey what is up?',
    'callback' => lambda do |message|
       puts(message)
     end
})
```

-------------------------------------------------------------
### PUBLISH ARRAY OF MESSAGES
-------------------------------------------------------------
##### Send Message

```
pubnub.publish({
    'channel' => 'hello_world',
    'message' => { ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"] },
    'callback' => lambda do |message|
       puts(message)
     end
})
```

----------------------------------------------------------------------------
### PUBLISH OBJECT OF STRING MESSAGE
----------------------------------------------------------------------------
##### Send Message

```
pubnub.publish({
    'channel' => 'hello_world',
    'message' => { 'text' => 'some text data' },
    'callback' => lambda do |message|
       puts(message)
     end
})
```

----------------------
### SUBSCRIBE
----------------------
##### Listen for Messages

```
pubnub.subscribe({
    'channel'  => 'hello_world',
    'callback' => lambda do |message|
        puts(message) ## print message
        return true   ## keep listening?
    end
})
```

-------------------
### HISTORY
-------------------
##### Load Previously Published Messages

```
pubnub.history({
    'channel' => 'hello_world',
    'limit'   => 10,
    'callback' => lambda do |message|
       puts(message)
     end
})
```

-----------
### UUID
-----------
##### Generate UUID

```
uuid = pubnub.UUID()
puts(uuid)
```

