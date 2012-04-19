package examples;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.Pubnub;

public class HistoryExample {

	@SuppressWarnings("unchecked")
	public static void main(String[] params) {
		
		String pub_key = "demo", sub_key = "demo";
		String secret_key = "demo",  cipher_key = "demo";
		String channel = "hello_world";
		int limit = 4;
		
		Pubnub pubnub  = new Pubnub( pub_key, sub_key, secret_key, cipher_key, true );
		
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("limit", limit);
        
        // Get History
        JSONArray response = pubnub.history( args );

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);
        
        try {
        	if(response != null){
		        for (int i = 0; i < response.length(); i++) {
					 JSONObject jsono = response.optJSONObject(i);
					 if(jsono != null){
						 Iterator keys = jsono.keys();
						 while (keys.hasNext()) {
							 System.out.print(jsono.get( keys.next().toString() ) +" ");
						 }
					 }
					 System.out.println();
				}
        	}
        } catch (Exception e) {
        	e.printStackTrace();
        }
	}
}
