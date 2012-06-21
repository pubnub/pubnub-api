package examples;


import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.Callback;
import pubnub.Pubnub;

public class Client {
    public static void main(String [] params) {
    	Pubnub pn  = new Pubnub( "demo", "demo", "demo", "", true );// (Cipher key is Optional)
        Receiver rcv = new Receiver();
        System.out.println("Subscribed to 'hello_world' Channel ");
        
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", "hello_world");
        args.put("callback", rcv);
        pn.subscribe( args );
        System.out.println("done");
    }
}

class Receiver implements Callback {
	@Override
    public boolean execute(Object message) {
    	// Print Received Message
        //System.out.println(message);
    	try {
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
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
        return true;
    }
}
