package src.pubnub.example;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;
import pubnub.api.Pubnub;
import pubnub.api.Callback;

public class PubnubExample {

	/**
	 * @param params
	 */
	public static void main(String[] params) {
		
		System.out.println("\nRunning publish()");
		PublishExample();
		
		System.out.println("\nRunning history()");
		HistoryExample();
		
		System.out.println("\nRunning timestamp()");
		TimestampExample();
		
		System.out.println("\nRunning here_now()");
		HereNowExample();
				
		System.out.println("\nRunning detailedHistory()");
		DetailedHistoryExample();
		
//		System.out.println("\nRunning presence()");
//		PresenceExample();
		
		System.out.println("\nRunning subscribe()");
		SubscribeExample();

	}
	
	private static void PublishExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = "enigma"; // (Cipher key is optional)
		String channel = "hello_world";
		
		int publish_message_count = 1;
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		int count = 0;
		while (true) {
			if (count >= publish_message_count) break;
			count ++;
			
			// Create JSON Message
			JSONObject message = new JSONObject();
			try {
				message.put("text", "Hello World!" + count);
				/*
				 * message.put("title", "Java Client PubNub";
				 * message.put("some_val", "This is a push to all users! Fighting!"
				 * message.put("url", "http://www.pubnub.com"
				 */
			} catch (org.json.JSONException jsonError) {
			}
			
			// Publish
			HashMap<String, Object> args = new HashMap<String, Object>(2);
			args.put("channel", channel);
			args.put("message", message);
			JSONArray response = null;
			response = pubnub.publish(args);
			System.out.println(response);
			
			args = new HashMap<String, Object>(2);
			args.put("channel", channel);
			args.put("message", "Hello World");
			response = pubnub.publish(args);
			System.out.println(response);
			
			JSONArray array = new JSONArray();
			array.put("Sunday");
			array.put("Monday");
			array.put("Tuesday");
			array.put("Wednesday");
			array.put("Thursday");
			array.put("Friday");
			array.put("Saturday");
			
			args = new HashMap<String, Object>(2);
			args.put("channel", channel);
			args.put("message", array);
			
			response = pubnub.publish(args);
			System.out.println(response);
		}
	}
	
	private static void HistoryExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = "enigma"; // (Cipher key is optional)
		String channel = "hello_world";
		int limit = 1;
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("limit", limit);
		
		// Get History
		JSONArray response = pubnub.history(args);
		
		// Print Response from PubNub JSONP REST Service
		System.out.println(response);
		
		try {
			if (response != null) {
				for (int i = 0; i < response.length(); i ++) {
					JSONObject jsono = response.optJSONObject(i);
					if (jsono != null) {
						@SuppressWarnings("rawtypes")
						Iterator keys = jsono.keys();
						while (keys.hasNext()) {
							System.out.println(jsono.get(keys.next().toString()) + " ");
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private static void DetailedHistoryExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = "enigma"; // (Cipher key is optional)
		String channel = "hello_world";
		int    count = 1;
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
		// Get History
		JSONArray response = pubnub.detailedHistory(channel, count);
		
		// Print Response from PubNub JSONP REST Service
		System.out.println(response);
		
		try {
			if (response != null) {
				for (int i = 0; i < response.length(); i ++) {
					JSONObject jsono = response.optJSONObject(i);
					if (jsono != null) {
						@SuppressWarnings("rawtypes")
						Iterator keys = jsono.keys();
						while (keys.hasNext()) {
							System.out.println(jsono.get(keys.next().toString()) + " ");
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private static void TimestampExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = ""; // (Cipher key is optional)
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
		// Print Server Time
		System.out.println("Time: " + Double.toString(pubnub.time()));
	}
	
	private static void SubscribeExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = ""; // (Cipher key is optional)
		String channel = "hello_world";
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
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
				System.out.println("Waiting for a message from publisher ...");
			}

			@Override
			public void reconnectCallback(String channel) {
				System.out.println("Reconnected to channel :" + channel);
			}

			@Override
			public void disconnectCallback(String channel) {
				System.out.println("Disconnected to channel :" + channel);
			}

			@Override
			public boolean presenceCallback(String channel, Object message) {
				return false;
			}
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel);
        args.put("callback", new Receiver());					// callback to get response

        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
	}
	
	private static void PresenceExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = ""; // (Cipher key is optional)
		String channel = "hello_world";
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
		// Callback Interface when a Message is Received
        class Receiver implements Callback {

        	public boolean presenceCallback(String channel, Object message) {

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
				System.out.println("Waiting for subscribe or unsubscribe message ...");
			}

			@Override
			public void reconnectCallback(String channel) {
				System.out.println("Reconnected to channel :" + channel);
			}

			@Override
			public void disconnectCallback(String channel) {
				System.out.println("Disconnected to channel :" + channel);
			}

			@Override
			public boolean subscribeCallback(String channel, Object message) {
				return false;
			}
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel + "-pnpres");
        args.put("callback", new Receiver());					// callback to get response

        // Listen for Messages (Presence)
        pubnub.presence(args);
	}
	
	private static void HereNowExample() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = ""; // (Cipher key is optional)
		String channel = "hello_world";
		
		Pubnub pubnub = new Pubnub(
				publish_key,
				subscribe_key,
				secret_key,
				cipher_key,
				true
		);
		
		// Get Here Now
		JSONArray response = pubnub.here_now(channel);
		
		// Print Response from PubNub JSONP REST Service
		System.out.println(response);
		
		try {
			if (response != null) {
				for (int i = 0; i < response.length(); i ++) {
					JSONObject jsono = response.optJSONObject(i);
					if (jsono != null) {
						@SuppressWarnings("rawtypes")
						Iterator keys = jsono.keys();
						while (keys.hasNext()) {
							System.out.println(jsono.get(keys.next().toString()) + " ");
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
