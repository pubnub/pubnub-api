##### VIDEO - ANDROID + PUBNUB
[http://www.youtube.com/watch?v=pkxUYYhwb04](http://www.youtube.com/watch?v=pkxUYYhwb04)

##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.

http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - ANDROID

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

The PubNub Android client provides a superior alternative to C2DM for broadcasting messages to entire user base.
C2DM is hard to implement, and it imposes artificial limits for you to reach your users quickly.  
C2DM is not recommended as it is a "broadcast" mechanism according to Google.  C2DM is Slow, and limited to 1 message at a time.
Use PubNub Instead!

##### PubNub Android Sample App

This is a full android sample app with the ability to Subscribe and UnSubscribe from PubNub channels. By UnSubscribing from channels, you can save resources and ultimately save billing costs.

Checkout the example app and unit tests for examples on how to use the API!


-------------------------------------------------------------------------------
Java: (Init)
-------------------------------------------------------------------------------

```java
Pubnub pubnub = new Pubnub(
    "demo",  // PUBLISH_KEY   (Optional, supply "" to disable)
    "demo",  // SUBSCRIBE_KEY (Required)
    "",      // SECRET_KEY    (Optional, supply "" to disable)
    "",      // CIPHER_KEY    (Optional, supply "" to disable)
    false    // SSL_ON?
);
```

-------------------------------------------------------------------------------
Java: (Publish)
-------------------------------------------------------------------------------

```java
// Create JSON Message
JSONObject message = new JSONObject();
try { message.put( "some_key", "Hello World!" ); }
catch (org.json.JSONException jsonError) {}

// Create HashMap parameter
HashMap<String, Object> args = new HashMap<String, Object>(2);
args.put("channel", "hello_world");        // Channel Name
args.put("message", message);              // JSON Message

// Publish Message
JSONArray info = pubnub.publish( args );

// Print Response from PubNub JSONP REST Service
System.out.println(info);
```

-------------------------------------------------------------------------------
Java: Subscribe and Presence (see comment at channel set at end of snippet)
-------------------------------------------------------------------------------

```java
    // Callback Interface when a Message is Received
    class Receiver implements Callback {
        public boolean subscribeCallback(String channel, Object message) {
            try {
                if (message instanceof JSONObject) {
                    JSONObject obj = (JSONObject) message;
                    @SuppressWarnings("rawtypes")
                    Iterator keys = obj.keys();
                    while (keys.hasNext()) {
                        System.out.print(obj.get(keys.next().toString()) + " ");
                    }
                    System.out.println();
                } else if (message instanceof String) {
                    String obj = (String) message;
                    System.out.print(obj + " ");
                    System.out.println();
                } else if (message instanceof JSONArray) {
                    JSONArray obj = (JSONArray) message;
                    System.out.print(obj.toString() + " ");
                    System.out.println();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Continue Listening?
            return true;
        }

        @Override
        public void errorCallback(String channel, Object message) {
            System.err.println("Channel:" + channel + "-" + message.toString());
        }

        @Override
        public void presenceCallback(String channel, Object message) {
            System.err.println("Channel:" + channel + "-" + message.toString());
        }


        @Override
        public void connectCallback(String channel) {
            System.out.println("Connected to channel :" + channel);
        }

        @Override
        public void reconnectCallback(String channel) {
            System.out.println("Reconnected to channel :" + channel);
        }

        @Override
        public void disconnectCallback(String channel) {
            System.out.println("Disconnected to channel :" + channel);
        }
    }

    HashMap<String, Object> args = new HashMap<String, Object>(2);
    args.put("channel", channel);              // for presence, channel-name is CHANNEL + "-pnpres"
    args.put("callback", new Receiver());      // callback to get response and events
```

------------------------------------------------------------------------------
Java: (History - Deprecated, please use detailedHistory)
-------------------------------------------------------------------------------

```java
    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(2);
    args.put("channel", "hello_world");        // Channel Name
    args.put("limit", 5);                      // Limit
    
    // Get History
    JSONArray response = pubnub.history( args );

    // Print Response from PubNub JSONP REST Service
    System.out.println(response);
    System.out.println(response.optJSONObject(0).optString("some_key"));
```

-------------------------------------------------------------------------------
Java: (detailedHistory)
-------------------------------------------------------------------------------
```java
    HashMap<String, Object> args = new HashMap<String, Object>();
    args.put("channel", channel);
    args.put("start", starttime);
    args.put("end", endtime);
    args.put("count", count);
    JSONArray response = pubnub.detailedHistory(args);
    JSONArray history = response.getJSONArray(0);
```
-------------------------------------------------------------------------------
Java: (Unsubscribe)
-------------------------------------------------------------------------------

```java
    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(1);
    args.put("channel", "hello_world");        // Channel Name
        
    // Unsubscribe/Disconnect
    pubnub.unsubscribe( args );
```

-------------------------------------------------------------------------------
Java: (Time)
-------------------------------------------------------------------------------

```java
    // Get server time
    double time = pubnub.time();
    System.out.println("Time : "+time);
```

-------------------------------------------------------------------------------
Java: (UUID)
-------------------------------------------------------------------------------

```java
    // Get UUID
    System.out.println("UUID : "+Pubnub.uuid());
```

-------------------------------------------------------------------------------
Java: (here_now)
-------------------------------------------------------------------------------

```java
    // Who is currently on the channel?
    HashMap<String, Object> args = new HashMap<String, Object>(1);
    args.put("channel", channel);
    myMessage = pubnub.here_now(args).toString();

```


