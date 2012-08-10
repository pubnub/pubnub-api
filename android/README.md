##### VIDEO - ANDROID + PUBNUB
[http://www.youtube.com/watch?v=pkxUYYhwb04](http://www.youtube.com/watch?v=pkxUYYhwb04)

##### Android Updates Provided By

Garett Rogers - [@GarettRogers](http://twitter.com/garettrogers)

##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.

http://www.pubnub.com/account

## PubNub 3.2 Real-time Cloud Push API - ANDROID

http://www.pubnub.com - PubNub Real-time Push Service in the Cloud.
http://www.pubnub.com/tutorial/java-push-api

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

##### PubNub Java Client API Boiler Plate

This is a full android sample app with the ability to Subscribe
and UnSubscribe from PubNub channels.
This will lead you within the resources allotted for your contract using the
PubNub Cloud.  By UnSubscribing from channels, you will save resources and
ultimately save billing costs and save on prices.  Note that the example
included has only shown you how to properly connect/disconnect users
from a subscribed channel.  You must review the included example app.
I've also included a screenshot with the navigation pointing to the important
reference file needed to learn how to use the PubNub UnSubscribe ability.

The Attached Android App provides you Two new Abilities/Examples:
Subscribe + UnSubscribe to a PubNub Channel.
Provides a superior alternative to C2DM for broadcasting messages to entire user base.

##### How to Get Started with Sub/UnSub Methods:

- Just click subscribe or unsubscribe.  The sample included provides a sample UI which interacts with the new Sub/UnSub methodology.
- While subscribed, sending any message to "androidsample" will show a popup in the app saying that it received a message.
- When unsubscribed, nothing will happen when you send that message, because the connection goes away.

- C2DM Alternative:
- First launch of the app will start the service.
- Phone boot starts the service as well.
- Send message to "c2dmalt" on with this format:

```javascript
{
    "title":"Android PubNub", 
    "text" : "This is a push to all users! woot!", 
    "url" : "http://www.pubnub.com"
}
```

- You will see a push notification in the Android Notification Bar with your message!
- This is MUCH preferred to than the C2DM slow network that Google provides you. C2DM is hard to implement, it imposes artificial limits for you to reach very quickly.  C2DM is not recommended to use as it is a "broadcast" mechanism according to Google.  C2DM is Slow.  Google forces you to send a single message at a time (1 http connection per message).

Caveats:
- The method of unsubscribing is harsh yet swift, all resources are cleared associated to the connections.
- The C2DM alternative will work as long as they have an internet connection or can re-connect before the queue has been freed.  PubNub is reliable this way.  In the case where the user may be between network signals, or their phone is switched off for extended period of time, they will not receive the message.

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
Java: (History)
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

