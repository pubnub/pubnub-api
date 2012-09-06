package pubnub.unit_test;

import static org.junit.Assert.*;

import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;

import pubnub.api.Callback;
import pubnub.api.Pubnub;

public class PubnubUnitTest {

	private CountDownLatch lock = new CountDownLatch(1);
	
	@Test
	public void testPublishHashMapOfStringObject() {
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
		
		JSONObject message = new JSONObject();
		try {
			message.put("text", "Hello World!");
		} catch (org.json.JSONException jsonError) {
			jsonError.printStackTrace();
		}
		
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("message", message);
		JSONArray response = null;
		response = pubnub.publish(args);
		
		try {
			assertFalse(response.get(2).toString().equals("0"));
		} catch (JSONException e) {
			fail("Failed to publish message through a channel.");
		}		
	}

	@Test
	public void testSubscribeHashMapOfStringObject() {
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

        	public boolean message_received = false;
        	
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
                message_received = true;
                lock.countDown();
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

			@Override
			public boolean presenceCallback(String channel, Object message) {
				return false;
			}
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel);
        Receiver recv = new Receiver();
        args.put("callback", recv);					// callback to get response

        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
        try {
            lock.await(5000, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        assertTrue(recv.message_received);
	}

	@Test
	public void testPresenceHashMapOfStringObject() {
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
        	
        	public boolean message_received = false;
        	
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
                message_received = true;
                lock.countDown();
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

			@Override
			public boolean subscribeCallback(String channel, Object message) {
				return false;
			}
        }

        HashMap<String, Object> args = new HashMap<String, Object>(6);
        args.put("channel", channel + "-pnpres");
        Receiver recv = new Receiver();
        args.put("callback", recv);					// callback to get response

        // Listen for Messages (Presence)
        pubnub.presence(args);
        try {
            lock.await(5000, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        assertTrue(recv.message_received);
    }

	@Test
	public void testHere_now() {
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
		
		try {
			assertNotNull(response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Test
	public void testHistoryHashMapOfStringObject() {
		String publish_key = "demo";
		String subscribe_key = "demo";
		String secret_key = "demo";
		String cipher_key = ""; // (Cipher key is optional)
		String channel = "hello_world";
		int limit = 4;
		
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
		
		try {
			assertNotNull(response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Test
	public void testTime() {
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
		
		assertNotNull(pubnub.time());
	}

	@Test
	public void testUuid() {
		assertNotNull(Pubnub.uuid());
	}
}
