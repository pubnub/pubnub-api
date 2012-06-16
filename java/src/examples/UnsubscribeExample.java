package examples;

import java.util.HashMap;
import java.util.Iterator;
import org.json.JSONArray;
import org.json.JSONObject;
import pubnub.Callback;
import pubnub.Pubnub;

public class UnsubscribeExample {

    public static void main(String[] params) {

    	String pub_key = "demo", sub_key = "demo";
        String secret_key = "demo", cipher_key = "demo";
        final String channel = "hello_world";
    	final Pubnub pubnub = new Pubnub(pub_key, sub_key, secret_key, cipher_key, true);

    	// Callback Interface when a Message is Received
        class Receiver implements Callback {

            public boolean execute(Object message) {

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

                // Unsubscribe/disconnect
                HashMap<String, Object> args = new HashMap<String, Object>(1);
            	args.put("channel", channel);
            	pubnub.unsubscribe(args);
                return true;
            }
        }

        // Callback Interface when a channel is connected
        class ConnectCallback implements Callback {

			@Override
			public boolean execute(Object message) {
				System.out.println(message.toString());
				
				String msg = "Hello World!!!";
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);
                args.put("message", msg);
                pubnub.publish(args);

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
        args.put("callback", new Receiver());					// callback to get response
        args.put("connect_cb", new ConnectCallback());			// callback to get connect event
        args.put("disconnect_cb", new DisconnectCallback());	// callback to get disconnect event
        args.put("reconnect_cb", new ReconnectCallback());		// callback to get reconnect event
        args.put("error_cb", new ErrorCallback());				// callback to get error event

        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
    }
}
