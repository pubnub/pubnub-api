

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONObject;

import src.pubnub.Callback;
import src.pubnub.Pubnub;

public class Client {
    public static void main(String [] params) {
    	Pubnub pn  = new Pubnub( "demo", "demo", "demo", "demo", true );
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
    @SuppressWarnings("unchecked")
	@Override
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
        return true;
    }
}
