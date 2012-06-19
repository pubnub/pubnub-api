##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

----------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - JAVA
----------------------------------------------

##### www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
##### http://www.pubnub.com/tutorial/java-push-api

 PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
 This is a cloud-based service for broadcasting Real-time messages
 to thousands of web and mobile clients simultaneously.

===============================================================================
##### PubNub Java Client API Boiler Plate
===============================================================================

-------------------------------------------------------------------------------
Java: (Init)
-------------------------------------------------------------------------------

    // Initialize Pubnub State
    Pubnub pubnub = new Pubnub(
        "demo",  // PUBLISH_KEY
        "demo",  // SUBSCRIBE_KEY
        "",      // SECRET_KEY (optional)
        "",      // CIPHER_KEY (optional)
        false    // SSL_ON?
    );


-------------------------------------------------------------------------------
Java: (Publish)
-------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------
Java: (Subscribe)
-------------------------------------------------------------------------------

    // Callback Interface when a Message is Received
    class Receiver implements Callback {
        public boolean execute(JSONObject message) {

            // Print Received Message
            System.out.println(message);

            // Continue Listening?
            return true;
        }
    }

    // Create a new Message Receiver
    Receiver message_receiver = new Receiver();
    
    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(2);
    args.put("channel", "hello_world");            // Channel Name
    args.put("callback", message_receiver);        // Receiver Callback Class
    
    // Listen for Messages (Subscribe)
    pubnub.subscribe( args );

------------------------------------------------------------------------------
Java: (History)
-------------------------------------------------------------------------------

    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(2);
    args.put("channel", "hello_world");        // Channel Name
    args.put("limit", 1);                      // Limit
    
    // Get History
    JSONArray response = pubnub.history( args );

    // Print Response from PubNub JSONP REST Service
    System.out.println(response);
    System.out.println(response.optJSONObject(0).optString("some_key"));

-------------------------------------------------------------------------------
Java: (Unsubscribe)
-------------------------------------------------------------------------------

    // Create HashMap parameter
    HashMap<String, Object> args = new HashMap<String, Object>(1);
    args.put("channel", "hello_world");        // Channel Name
        
    // Unsubscribe/Disconnect
    pubnub.unsubscribe( args );

-------------------------------------------------------------------------------
Java: (Time)
-------------------------------------------------------------------------------

    // Get server time
    double time = pubnub.time();
    System.out.println("Time : "+time);

-------------------------------------------------------------------------------
Java: (UUID)
-------------------------------------------------------------------------------

    // Get UUID
    System.out.println("UUID : "+Pubnub.uuid());
