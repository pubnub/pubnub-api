package test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.Callback;
import pubnub.Pubnub;

class PubnubTest {
	public static void main(String args[]) {
		// PubnubTest.test_uuid();
		// PubnubTest.test_time();
		// PubnubTest.test_history();
		// PubnubTest.test_publish();
		// PubnubTest.test_subscribe();
		// UnitTestAll(pubnub_user_supplied_options);
		UnitTestAll(pubnub_high_security);
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
		Pubnub pubnub = new Pubnub("demo", "demo", "demo", "", true);// (Cipher
																		// key
																		// is
																		// Optional)

		System.out.println("Time:::" + pubnub.time());
	}

	public static void test_publish() {
		// Publish Test
		System.out.println("\nTESTING PUBLISH:");

		// Create Pubnub Object
		Pubnub pubnub = new Pubnub("demo", "demo", "demo", "", true);// (Cipher
																		// key
																		// is
																		// Optional)
		String channel = "hello_world";

		// Create JSON Message
		JSONObject message = new JSONObject();
		try {
			message.put("some_val", "Hello World! --> É‚é¡¶@#$%^&*()!");
		} catch (org.json.JSONException jsonError) {
		}

		// Publish Message
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("message", message);
		JSONArray info = pubnub.publish(args);

		// Print Response from PubNub JSONP REST Service
		System.out.println(info);
	}

	public static void test_subscribe() {
		// Subscribe Test
		System.out.println("\nTESTING SUBSCRIBE:");

		Pubnub pubnub = new Pubnub("demo", "demo", "demo", "", true);// (Cipher
																		// key
																		// is
																		// Optional)
		String channel = "hello_world";

		// Callback Interface when a Message is Received
		class Receiver implements Callback {

			
			@Override
			public boolean subscribeCallback(String channel, Object message) {
				try {
					if (message instanceof JSONObject) {
						JSONObject obj = (JSONObject) message;
						@SuppressWarnings("rawtypes")
						Iterator keys = obj.keys();
						while (keys.hasNext()) {
							System.out.print(obj.get(keys.next().toString())
									+ " ");
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

		// Create a new Message Receiver
		Receiver message_receiver = new Receiver();

		// Listen for Messages (Subscribe)
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("callback", message_receiver);
		pubnub.subscribe(args);
	}

	public static void test_history() {
		// History Test
		System.out.println("\nTESTING HISTORY:");

		// Create Pubnub Object
		Pubnub pubnub = new Pubnub("demo", "demo", "demo", "", true);// (Cipher
																		// key
																		// is
																		// Optional)

		// Get History
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", "hello_world");
		args.put("limit", 1);
		JSONArray response = pubnub.history(args);

		// Print Response from PubNub JSONP REST Service
		// System.out.println(response);
		System.out.println(response.optJSONObject(0).optString("some_val"));
	}

	// -----------------------------------------------------------------------
	// unit-test-all
	// -----------------------------------------------------------------------

	static String publish_key = "demo", subscribe_key = "demo";
	static String secret_key = "demo", cipher_key = "";
	static Boolean ssl_on = false;

	// -----------------------------------------------------------------------
	// Command Line Options Supplied PubNub
	// -----------------------------------------------------------------------

	static Pubnub pubnub_user_supplied_options = new Pubnub(publish_key, // OPTIONAL (supply None to disable)
			subscribe_key, // REQUIRED
			secret_key, // OPTIONAL (supply None to disable)
			cipher_key, // OPTIONAL (supply None to disable)
			ssl_on // OPTIONAL (supply None to disable)
	);

	// -----------------------------------------------------------------------
	// High Security PubNub
	// -----------------------------------------------------------------------
	static Pubnub pubnub_high_security = new Pubnub(
	// Publish Key
			"pub-c-a30c030e-9f9c-408d-be89-d70b336ca7a0",

			// Subscribe Key
			"sub-c-387c90f3-c018-11e1-98c9-a5220e0555fd",

			// Secret Key
			"sec-c-MTliNDE0NTAtYjY4Ni00MDRkLTllYTItNDhiZGE0N2JlYzBl",

			// Cipher Key
			"YWxzamRmbVjFaa05HVnGFqZHM3NXRBS73jxmhVMkjiwVVXV1d5UrXR1JLSkZFRr"
					+ "WVd4emFtUm1iR0TFpUZvbiBoYXMgYmVlbxWkhNaF3uUi8kM0YkJTEVlZYVFjBYi"
					+ "jFkWFIxSkxTa1pGUjd874hjklaTFpUwRVuIFNob3VsZCB5UwRkxUR1J6YVhlQWa"
					+ "V1ZkNGVH32mDkdho3pqtRnRVbTFpUjBaeGUgYXNrZWQtZFoKjda40ZWlyYWl1eX"
					+ "U4RkNtdmNub2l1dHE2TTA1jd84jkdJTbFJXYkZwWlZtRnKkWVrSRhhWbFpZVmFz"
					+ "c2RkZmTFpUpGa1dGSXhTa3hUYTFwR1Vpkm9yIGluZm9ybWFNfdsWQdSiiYXNWVX"
					+ "RSblJWYlRGcFVqQmFlRmRyYUU0MFpXbHlZV2wxZVhVNFJrTnR51YjJsMWRIRTJU"
					+ "W91ciBpbmZvcm1hdGliBzdWJtaXR0ZWQb3UZSBhIHJlc3BvbnNlLCB3ZWxsIHJl"
					+ "VEExWdHVybiB0am0aW9uIb24gYXMgd2UgcG9zc2libHkgY2FuLuhcFe24ldWVns"
					+ "dSaTFpU3hVUjFKNllWaFdhRmxZUWpCaQo34gcmVxdWlGFzIHNveqQl83snBfVl3",

			// 2048bit SSL ON - ENABLED TRUE
			false);

	// -----------------------------------------------------------------------
	// Channel | Message Test Data (UTF-8)
	// -----------------------------------------------------------------------
	String message = " ~`â¦â§!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
	static Pubnub _pubnub;
	static ArrayList<String> many_channels = new ArrayList<String>();

	static HashMap<String, Object> status = new HashMap<String, Object>(3);

	static HashMap<String, Object> threads = new HashMap<String, Object>(4);

	static int max_retries = 10;

	// -----------------------------------------------------------------------
	// Unit Test Function
	// -----------------------------------------------------------------------
	static void test(Boolean trial, String name) {
		if (trial)
			System.out.println("PASS " + name);
		else
			System.err.println("- FAIL - " + name);
	}

	static void UnitTestAll(Pubnub pubnub) {
		_pubnub = pubnub;
		for (int i = 0; i < max_retries; i++) {
			many_channels.add("channel_" + i);
		}

		status.put("sent", 0);
		status.put("received", 0);
		status.put("connections", 0);

		for (final String _channel : many_channels) {
			Thread t = new Thread() {
				public void run() {

					HashMap<String, Object> args = new HashMap<String, Object>(
							6);
					args.put("channel", _channel);
					args.put("callback", new ReceivedMessage()); // callback to get response

					// Listen for Messages (Subscribe)
					_pubnub.subscribe(args);

				};

			};
			t.start();
			threads.put(_channel, t);

			try {
				Thread.sleep(2000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

	// Callback Interface when a Message is Received
	static class ReceivedMessage implements Callback {

		@Override
		public boolean subscribeCallback(String channel, Object message) {
			Integer sent = (Integer) status.get("sent");
			Integer received = (Integer) status.get("received");
			System.out.println("sent:" + sent + " received:" + received
					+ " channel:" + channel);
			test(received <= sent, "many sends");
			status.remove(received);
			status.put("received", received.intValue() + 1);
			HashMap<String, Object> args = new HashMap<String, Object>(1);
			args.put("channel", channel);
			_pubnub.unsubscribe(args);
			Thread t = (Thread) threads.get(channel);
			t.interrupt();

			HashMap<String, Object> argsHistory = new HashMap<String, Object>(2);
			argsHistory.put("channel", channel);
			argsHistory.put("limit", 2);

			// Get History
			JSONArray response = _pubnub.history(argsHistory);
			if (response != null) {
				test(true, " History with channel " + channel);
			}
			return true;
		}

		@Override
		public void errorCallback(String channel, Object message) {
			System.err.println("Channel:" + channel + "-" + message.toString());
		}

		@Override
		public void connectCallback(String channel) {
			System.out.println("Connected to channel :" + channel);

			Integer connections = (Integer) status.get("connections");
			status.remove(connections);
			status.put("connections", connections.intValue() + 1);

			JSONArray array = new JSONArray();
			array.put("Sunday");
			array.put("Monday");
			array.put("Tuesday");
			array.put("Wednesday");
			array.put("Thursday");
			array.put("Friday");
			array.put("Saturday");

			HashMap<String, Object> args = new HashMap<String, Object>(2);
			args.put("channel", channel);
			args.put("message", array);

			JSONArray response = _pubnub.publish(args);
			Integer sent = (Integer) status.get("sent");
			status.remove(sent);
			status.put("sent", sent.intValue() + 1);

			test(true, "publish complete");
			test(true, "publish responce" + response);
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

}
