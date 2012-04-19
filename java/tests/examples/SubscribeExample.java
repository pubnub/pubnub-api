package examples;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONObject;

import pubnub.Callback;
import pubnub.Pubnub;

public class SubscribeExample {

	public static void main(String[] params) {
		
		String pub_key = "demo", sub_key = "demo";
		String secret_key = "demo",  cipher_key = "demo";
		String channel = "hello_world";
		
		Pubnub pubnub  = new Pubnub( pub_key, sub_key, secret_key, cipher_key, true );
		
		// Callback Interface when a Message is Received
		class Receiver implements Callback {
		    @SuppressWarnings("unchecked")
			public boolean execute(JSONObject message) {

		        // Print Received Message
		        //System.out.println(message);
		    	try {
					Iterator keys = message.keys();
					while (keys.hasNext()) {
						System.out.print(message.get( keys.next().toString() ) +" ");
					}
					System.out.println();
		    	} catch (Exception e) {
		    		e.printStackTrace();
		    	}
		        
		        // Continue Listening?
		        return true;
		    }
		}

		// Create a new Message Receiver
		Receiver message_receiver = new Receiver();

		System.out.println("Subscribed to channel --> "+channel);
		
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("callback", message_receiver);
		
		// Listen for Messages (Subscribe)
		pubnub.subscribe( args );
	}
}
