package examples;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.Callback;
import pubnub.Pubnub;

class PubnubTest {
    public static void main(String args[]) {
    	//PubnubTest.test_uuid();
       	//PubnubTest.test_time();
    	//PubnubTest.test_history();
    	//PubnubTest.test_publish();
        PubnubTest.test_subscribe();
    }
    
    public static void test_uuid() {
        // UUID Test
        System.out.println("\nTESTING UUID:");
        System.out.println(Pubnub.uuid());
    }
    public static void test_time() {
        // Time Test
        System.out.println("\nTESTING TIME:");

        // Create Pubnub Object
        Pubnub pubnub = new Pubnub( "demo", "demo", "demo", "demo", true );

        System.out.println(pubnub.time());
    }
    public static void test_publish() {
        // Publish Test
        System.out.println("\nTESTING PUBLISH:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo", "demo", "demo", true );
        String channel = "hello_world";

        // Create JSON Message
        JSONObject message = new JSONObject();
        try { 
        	message.put( "some_val", "Hello World! --> ɂ顶@#$%^&*()!" ); 
        }
        catch (org.json.JSONException jsonError) {}

        // Publish Message
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", message);
        JSONArray info = pubnub.publish( args );

        // Print Response from PubNub JSONP REST Service
        System.out.println(info);
    }

    public static void test_subscribe() {
        // Subscribe Test
        System.out.println("\nTESTING SUBSCRIBE:");

        Pubnub pubnub  = new Pubnub( "demo", "demo", "demo", "demo", true );
        String channel = "hello_world";

        // Callback Interface when a Message is Received
        class Receiver implements Callback {
            @SuppressWarnings("unchecked")
			public boolean execute(Object message) {

            	try {
		    		if(message instanceof JSONObject)
		    		{
		    			JSONObject obj=(JSONObject)message;
		    			Iterator keys = obj.keys();
		    			while (keys.hasNext()) {
		    				System.out.print(obj.get( keys.next().toString() ) +" ");
		    			}
		    			System.out.println();
		    		}else if(message instanceof String )
		    		{
		    			String obj=(String)message;
		    			System.out.print( obj  +" ");
		    			System.out.println();
		    		}else if(message instanceof JSONArray)
		    		{
		    			JSONArray obj=(JSONArray)message;
		    			
		    			
		    			System.out.print(obj.toString()  +" ");
		    			System.out.println();
		    		
		    		}
		    	} catch (Exception e) {
		    		e.printStackTrace();
		    	}

                // Continue Listening?
                return true;
            }
        }

        // Create a new Message Receiver
        Receiver message_receiver = new Receiver();

        // Listen for Messages (Subscribe)
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("callback", message_receiver);
        pubnub.subscribe( args );
    }
    
    public static void test_history() {
        // History Test
        System.out.println("\nTESTING HISTORY:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo", "demo", "demo", true );

        // Get History
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", "hello_world");
        args.put("limit", 1);
        JSONArray response = pubnub.history( args );

        // Print Response from PubNub JSONP REST Service
        //System.out.println(response);
        System.out.println(response.optJSONObject(0).optString("some_val"));
    }
}
