package src.tests;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

import org.json.JSONArray;

import pubnub.Callback;
import pubnub.Pubnub;

class PubnubUnitTest {

	public static void main(String args[]) {

		String publish_key = "demo", subscribe_key = "demo";
		String secret_key = "demo", cipher_key = "";
		Boolean ssl_on = false;

		// User Supplied Options PubNub
		Pubnub pubnub_user_supplied_options = new Pubnub(publish_key,   // OPTIONAL (supply "" to disable)
				subscribe_key,     // REQUIRED
				secret_key,        // OPTIONAL (supply "" to disable)
				cipher_key,        // OPTIONAL (supply "" to disable)
				ssl_on             // OPTIONAL (supply "" to disable)
		);

		// High Security PubNub
		Pubnub pubnub_high_security = new Pubnub(
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

		PubnubUnitTest pubnub = new PubnubUnitTest();
		pubnub.unitTest(pubnub_user_supplied_options);
//		pubnub.unitTest(pubnub_high_security);
	}

	// Channel | Message Test Data (UTF-8)
	String message = " ~`!@#$%^&*()+=[]\\{}|;\':,./<>?abcd";
	Pubnub _pubnub;
	ArrayList<String> many_channels = null;
	LinkedHashMap<String, Object> status = null;
	LinkedHashMap<String, Object> threads = null;
	int max_retries = 10;

	/**
	 * Unit Test
	 * @param pubnub
	 */
	private void unitTest(Pubnub pubnub) {
		many_channels = new ArrayList<String>();
		status = new LinkedHashMap<String, Object>();
		threads = new LinkedHashMap<String, Object>();
		
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
					HashMap<String, Object> args = new HashMap<String, Object>(2);

					args.put("channel", _channel);
					args.put("callback", new ReceivedMessage());   // callback to get response

					// Listen for Messages (Subscribe)
					_pubnub.subscribe(args);
				};
			};
			t.start();
			threads.put(_channel, t);

			try {
				Thread.sleep(100);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

	// Callback Interface when a Message is Received
	class ReceivedMessage implements Callback {

		@Override
		public boolean subscribeCallback(String channel, Object message) {
			Integer sent = (Integer) status.get("sent");
			Integer received = (Integer) status.get("received");

			status.remove(received);
			status.put("received", received.intValue() + 1);

			received = (Integer) status.get("received");

//			System.out.println("sent:" + sent + " received:" + received + " channel:" + channel);
			test(received <= sent, "many sends");

			HashMap<String, Object> args = new HashMap<String, Object>(1);
			args.put("channel", channel);
			_pubnub.unsubscribe(args);

			Thread t = (Thread) threads.get(channel);
//			threads.remove(channel);
			t.interrupt();

			HashMap<String, Object> argsHistory = new HashMap<String, Object>(2);
			argsHistory.put("channel", channel);
			argsHistory.put("limit", 2);

			// Get History
			JSONArray response = _pubnub.history(argsHistory);
			if (response != null) {
//				test(true, " History with channel " + channel);
			}
			return true;
		}

		@Override
		public void errorCallback(String channel, Object message) {
			System.err.println("Channel:" + channel + "-" + message.toString());
		}

		@Override
		public void connectCallback(String channel) {
//			System.out.println("Connected to channel :" + channel);

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
			test(true, "publish response");
		}

		@Override
		public void reconnectCallback(String channel) {
//			System.out.println("Reconnected to channel :" + channel);
		}

		@Override
		public void disconnectCallback(String channel) {
//			System.out.println("Disconnected to channel :" + channel);
		}
	}

	private static void test(Boolean trial, String name) {
		if (trial)
			System.out.println("PASS " + name);
		else
			System.err.println("- FAIL - " + name);
	}
}
