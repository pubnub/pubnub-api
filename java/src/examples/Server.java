package examples;


import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.Pubnub;

public class Server {
    @SuppressWarnings("static-access")
	public static void main(String [] params) {
    	Pubnub pn  = new Pubnub( "demo", "demo", "demo", "", true ); //(Cipher key is Optional)
        int count = 0;

        while (true) {
        	count++;
        	
            System.out.print("sending message: " + count);
            JSONObject message = new JSONObject();
            try { 
            	message.put( "some_val", "Hello World! --> ɂ顶@#$%^&*()!" + Integer.toString(count) ); 
            }
            catch (org.json.JSONException jsonError) {
                System.out.println(jsonError);
            }

            HashMap<String, Object> args = new HashMap<String, Object>(2);
            args.put("channel", "hello_world");
            args.put("message", message);
            
            JSONArray info = pn.publish( args );
            System.out.println(", info: " + info);
            try { Thread.currentThread().sleep(1000); }
            catch ( Exception ex ) {}
            
            
        }
    }
}
