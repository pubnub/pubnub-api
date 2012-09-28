
##### YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
##### http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - J2ME

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
J2ME: (Callback)
-------------------------------------------------------------------------------
	Set Callback when pubnub object create.
    public interface Callback {
	    public abstract void publishCallback(String channel,Object message,Object responce);
	    public abstract void subscribeCallback(String channel,Object message);
	    public abstract void historyCallback(String channel,Object message);
	    public abstract void errorCallback(String channel, Object message);
	    public abstract void connectCallback(String channel);
	    public abstract void reconnectCallback(String channel);
	    public abstract void disconnectCallback(String channel);
	    public abstract void hereNowCallback(String channel,Object message);
	    public abstract void presenceCallback(String channel,Object message);
	    public abstract void detailedHistoryCallback(String channel,Object message);
	}



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
            _pubnub.publish(args);
           
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        
    Result back in Publish Callback.
    
    	public void publishCallback(String channel, Object message, Object response) {
	        JSONArray meg = (JSONArray) response;
	        System.out.println("Message sent response:" + message.toString()
	                + " on channel:" + channel);
	        try {
	            int success = Integer.parseInt(meg.get(0).toString());
	            if (success == 1) {
	                stringItem.setLabel("Publish");
	                stringItem.setText("Message sent successfully on channel:"
	                        + channel + "\n" + message.toString());
	            } else {
	                stringItem.setLabel("Publish");
	                stringItem.setText("Message sent failure on channel:" + channel
	                        + "\n" + message.toString());
	            }
	        } catch (Exception ex) {
	            ex.printStackTrace();
	        }
	    }    

-------------------------------------------------------------------------------
J2ME: (Subscribe)
-------------------------------------------------------------------------------

 // Callback Interface when a Message is Received
     public void subscribeCallback(String channel, Object message) {
        System.out.println("Message recevie on channel:" + channel
                + " Message:" + message.toString());
        try {
            if (message instanceof JSONObject) {
                JSONObject obj = (JSONObject) message;
                Alert a = new Alert("Received", obj.toString(), null, null);
                a.setTimeout(Alert.FOREVER);
                getDisplay().setCurrent(a, form);

                Enumeration keys = obj.keys();
                while (keys.hasMoreElements()) {
                    System.out.println(obj.get(keys.nextElement().toString())
                            + " ");
                }

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

    }

    // Callback Interface when a channel is connected
    public void connectCallback(String channel) {
        System.out.println("Connect channel:" + channel);
    }

    // Callback Interface when a channel is reconnected
    public void reconnectCallback(String channel) {
        System.out.println("Reconnect channel:" + channel);
    }
    
   // Callback Interface when a channel is disconnected
    public void disconnectCallback(String channel) {
        System.out.println("Disconnect channel:" + channel);
    }

    // Callback Interface when error occurs
   public void errorCallback(String channel, Object message) {
        System.out.println("Error on channel:" + channel + " Message:" + message.toString());
    }

    Hashtable args = new Hashtable(6);
    args.put("channel", "hello_world");
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
    _pubnub.history(args);

     public void historyCallback(String channel, Object message) {
        JSONArray meg = (JSONArray) message;
        System.out.println("History recevie on channel:" + channel + " Message:" + meg.toString());

        stringItem.setLabel("History");
        stringItem.setText("History recevie on channel:" + channel + "\n" + meg.toString());
    }
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
    long time = pubnub.time();
    System.out.println("Time : "+time);
    
-------------------------------------------------------------------------------
Java: (here_now)
-------------------------------------------------------------------------------

```java
    // Who is currently on the channel?
    Hashtable args = new Hashtable();
    args.put("channel", channel);
    pubnub.here_now(args);

```

	public void hereNowCallback(String channel, Object message) {
        stringItem.setLabel("HereNow");
        stringItem.setText("HereNow on channel:" + channel + "\n" + message.toString());
    }
	
-------------------------------------------------------------------------------
Java: (presence)
-------------------------------------------------------------------------------
	
	To join a subscriber list on a channel. Callback events can be, Join - Shows availability on a channel or Leave - Disconnected to channel means removed from the list of subscribers.
		
	_pubnub.presence(Channel);
	
	//Callback
	 public void presenceCallback(String channel, Object message) {
        stringItem.setLabel("Presence");
        stringItem.setText("channel:" + channel + "\n" + message.toString());
    }
    
    
    
-------------------------------------------------------------------------------
Java: (Detailed History)
-------------------------------------------------------------------------------
    Load Previously Published Messages in Detail.
    
      Hashtable args = new Hashtable();
                args.put("channel", Channel);
                args.put("count", 2+"");
      _pubnub.detailedHistory(args);
    
    //Callback
     public void detailedHistoryCallback(String channel, Object message) {
         stringItem.setLabel("DetailedHistory");
        stringItem.setText("channel:" + channel + "\n" + message);
    }
    
    