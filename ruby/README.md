Pubnub - http://github/pubnub/pubnub-api
@poptartinc on Twitter, @poptart on Github

##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - RUBY

www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/blog/ruby-push-api

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

# Pubnub 3.3 for Ruby is a complete rewrite, and is NOT compatible with earlier versions of Pubnub Ruby Client.
### Usage Examples
Examine the tests in spec/lib/* for many different scenarios! Specifically, *_integration. But here is a small sample:

### Require it!

```ruby
require 'pubnub' # or require 'pubnub-ruby' if you installed pubnub-ruby (they are now identical gems)
```

### Instantiate a new PN Object

```ruby
    pn = Pubnub.new(:publish_key => @publish_key, # publish_key only required if publishing.
        :subscribe_key => @subscribe_key,         # required
        :secret_key => @secret_key,               # optional, if used, message signing is enabled
        :cipher_key => @cipher_key,               # optional, if used, encryption is enabled
        :ssl => @ssl_enabled)                     # true or default is false 
```

### Publish
For message, you can just pass it a string, a hash, an array, an object -- it will be serialized as a JSON object,
and urlencoded automatically for you.

```ruby

    @my_callback = lambda { |message| puts(message) }

    pn.publish(:channel => :hello_world,
        :message => "hi",
        :callback => @my_callback)
```

### Subscribe

```ruby
    pn.subscribe(:channel => :hello_world,
        :callback => @my_callback)
```

### History (deprecated, use new detailed_history)

```ruby
    pn.history(:cipher_key => "enigma",
        :channel => @no_history_channel,
        :limit => 10,
        :callback => @my_callback)
```

### Detailed Message History

Archive messages of on a given channel. Optional start, end, and reverse option examples can be found in the tests.
```ruby
    pn.detailed_history(:channel => channel,
        :count => 10, 
        :callback => @my_callback)
```

### Presence

Realtime see who channel events, such as joins, leaves, and occupancy.
```ruby
    pn.presence(:channel => :hello_world,
        :callback => @my_callback)
```

### Here_now 

See who is online in a channel at this very moment.
```ruby
    pn.here_now(:channel => channel,
    :callback => @my_callback)
```

### UUID

Session-UUID is automatic, so you will probably not end up ever using this. But if you need a UUID...
```ruby
    Pubnub.new(:subscribe_key => :demo).uuid
```

### Time 

Get the current timetoken.
```ruby
    pn.time("callback" => @my_callback)
```
