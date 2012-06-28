
##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.0 Real-time Cloud Push API - J2ME

PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
This is a cloud-based service for broadcasting Real-time messages
to thousands of web and mobile clients simultaneously.

##### Example configuration

-Project tested on Netbeans 7 IDE and Java ME SDK 3.0 Device Manager
-Device Configuration - CLDC-1.1
-Device Profile       - MIDP-2.0

-------------------------------------------------------------------------------
J2ME: (Init)
-------------------------------------------------------------------------------

    Pubnub pubnub = new Pubnub(
        "demo",  // PUBLISH_KEY
        "demo",  // SUBSCRIBE_KEY
        "",      // SECRET_KEY
        "",      // CIPHER_KEY (optional)
        false    // SSL_ON?
    );

-------------------------------------------------------------------------------
J2ME: (Publish)
-------------------------------------------------------------------------------

    try {
            // Create JSON Message
            JSONObject message = new JSONObject();
            // Create Hashtable parameter
            message.put("some_key", "Hello World!");

            Hashtable args = new Hashtable(2);
            args.put("channel", "hello_world");        // Channel Name
            args.put("message", message);              // JSON Message
            JSONArray responece = _pubnub.publish(args);
            // Print Response from PubNub JSONP REST Service
            System.out.println(responece.toString());
        } catch (JSONException ex) {
            ex.printStackTrace();
        }

-------------------------------------------------------------------------------
J2ME: (Subscribe)
-------------------------------------------------------------------------------

 // Callback Interface when a Message is Received
    class Receiver implements Callback {

        public boolean execute(Object message) {

            try {
                if (message instanceof JSONObject) {
                    JSONObject obj = (JSONObject) message;
                    Alert a = new Alert("Received", obj.toString(), null, null);
                    a.setTimeout(Alert.FOREVER);
                    getDisplay().setCurrent(a, form);

                    Enumeration keys = obj.keys();
                    while (keys.hasMoreElements()) {
                        System.out.print(obj.get(keys.nextElement().toString()) + " ");
                    }
                    System.out.println();
                } else if (message instanceof String) {
                    String obj = (String) message;
                    System.out.print(obj + " ");
                    System.out.println();

                    Alert a = new Alert("Received", obj.toString(), null, null);
                    a.setTimeout(Alert.FOREVER);
                    getDisplay().setCurrent(a, form);
                } else if (message instanceof JSONArray) {
                    JSONArray obj = (JSONArray) message;
                    System.out.print(obj.toString() + " ");
                    System.out.println();

                    Alert a = new Alert("Received", obj.toString(), null, null);
                    a.setTimeout(Alert.FOREVER);
                    getDisplay().setCurrent(a, form);
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

        public boolean execute(Object message) {
            System.out.println(message.toString());
            return false;
        }
    }

    // Callback Interface when a channel is disconnected
    class DisconnectCallback implements Callback {

        public boolean execute(Object message) {
            System.out.println(message.toString());
            return false;
        }
    }

    // Callback Interface when a channel is reconnected
    class ReconnectCallback implements Callback {

        public boolean execute(Object message) {
            System.out.println(message.toString());
            return false;
        }
    }

    // Callback Interface when error occurs
    class ErrorCallback implements Callback {

        public boolean execute(Object message) {
            System.out.println(message.toString());
            return false;
        }
    }

    Hashtable args = new Hashtable(6);
    args.put("channel", "hello_world");
    args.put("callback", new Receiver());                    // callback to get response
    args.put("connect_cb", new ConnectCallback());           // callback to get connect event (optional)
    args.put("disconnect_cb", new DisconnectCallback());     // callback to get disconnect event (optional)
    args.put("reconnect_cb", new ReconnectCallback());       // callback to get reconnect event (optional)
    args.put("error_cb", new ErrorCallback());               // callback to get error event (optional)

    // Listen for Messages (Subscribe)
    _pubnub.subscribe(args);

------------------------------------------------------------------------------
J2ME: (History)
-------------------------------------------------------------------------------

    // Create HashMap parameter
    Hashtable args = new Hashtable(2);
    args.put("channel", "hello_world");
    args.put("limit", new Integer(2));     // Limit
    
    // Get History
    JSONArray responece = _pubnub.history(args);

    // Print Response from PubNub JSONP REST Service
    System.out.println("History" + responece);
-------------------------------------------------------------------------------
J2ME: (Unsubscribe)
-------------------------------------------------------------------------------

    // Create Hashtable parameter
    Hashtable args = new Hashtable(1);
    String channel = "hello_world";
    args.put("channel", channel);
    _pubnub.unsubscribe(args);

-------------------------------------------------------------------------------
J2ME: (Time)
-------------------------------------------------------------------------------

    // Get server time
    double time = pubnub.time();
    System.out.println("Time : "+time);
