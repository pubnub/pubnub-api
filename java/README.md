
##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.1 Real-time Cloud Push API - JAVA

www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/tutorial/java-push-api

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

##### PubNub Java Client API Boiler Plate

-------------------------------------------------------------------------------
Java: (Init)
-------------------------------------------------------------------------------
```java
Pubnub pubnub = new Pubnub(
    "demo",  // PUBLISH_KEY
    "demo",  // SUBSCRIBE_KEY
    "",      // SECRET_KEY
    "",      // CIPHER_KEY (Cipher key is Optional)
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
Java: (Subscribe)
-------------------------------------------------------------------------------

```java
class Receiver implements Callback {
    public boolean execute(Object message) {
       try {
           if (message instanceof JSONObject) {
               JSONObject obj = (JSONObject) message;
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
}

// Callback Interface when a channel is connected
class ConnectCallback implements Callback {

    @Override
    public boolean execute(Object message) {
                System.out.println(message.toString());
                return false;
            }
        }

        // Callback Interface when a channel is disconnected
        class DisconnectCallback implements Callback {

            @Override
            public boolean execute(Object message) {
                System.out.println(message.toString());
                return false;
            }
        }

        // Callback Interface when a channel is reconnected
        class ReconnectCallback implements Callback {

            @Override
            public boolean execute(Object message) {
                System.out.println(message.toString());
                return false;
            }
        }

        // Callback Interface when error occurs
        class ErrorCallback implements Callback {

            @Override
            public boolean execute(Object message) {
                System.out.println(message.toString());
                return false;
            }
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel);
        args.put("callback", new Receiver());                   // callback to get response
        args.put("connect_cb", new ConnectCallback());          // callback to get connect event
        args.put("disconnect_cb", new DisconnectCallback());    // callback to get disconnect event
        args.put("reconnect_cb", new ReconnectCallback());      // callback to get reconnect event
        args.put("error_cb", new ErrorCallback());              // callback to get error event

        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
```

------------------------------------------------------------------------------
Java: (History)
-------------------------------------------------------------------------------

```java
    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(2);
    args.put("channel", "hello_world");        // Channel Name
    args.put("limit", 1);                      // Limit
    
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
