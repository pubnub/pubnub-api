package examples;

import java.util.HashMap;
import java.util.Iterator;
import org.json.JSONArray;
import org.json.JSONObject;
import pubnub.Callback;
import pubnub.Pubnub;

public class SubscribeExample {

    public static void main(String[] params) {

        String pub_key = "demo", sub_key = "demo";
        String secret_key = "demo", cipher_key = "";
        String channel = "hello_world";

        Pubnub pubnub = new Pubnub(pub_key, sub_key, secret_key, cipher_key,
                true);//(Cipher key is Optional)

        // Callback Interface when a Message is Received
        class Receiver implements Callback {

        	public boolean subscribeCallback(String channel, Object message) {

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
                // Continue Listening?
              return true;
            }

			@Override
			public void errorCallback(String channel, Object message) {
				System.err.println("Channel:" + channel + "-" + message.toString());
				
			}

			@Override
			public void connectCallback(String channel) {
				System.out.println("Connected to channel :" + channel);

			}

			@Override
			public void reconnectCallback(String channel) {
				System.out.println("Reconnected to channel :" + channel);
			}

			@Override
			public void disconnectCallback(String channel) {
				System.out.println("Disconnected to channel :" + channel);
			}
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel);
        args.put("callback", new Receiver());					// callback to get response

        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
    }
}
