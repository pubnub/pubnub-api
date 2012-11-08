package pubnub.unit_test;

import static org.junit.Assert.*;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;

import pubnub.api.Callback;
import pubnub.api.Pubnub;

public class PubnubUnitTest {

	private static boolean deliveryStatus = false;
	private Pubnub pubnub = new Pubnub(
			"demo",
			"demo",
			"",
			"",
			true
	);
	private String channel = "hello_world";
	private int limit = 1;
	
	@Test
	public void testPublishHashMapOfStringObject() {
		pubnub.CIPHER_KEY = "enigma";
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
			System.out.println("PASS: TestPublish");
		} catch (JSONException e) {
			fail("FAIL: TestPublish");
		}		
	}

	@Test
	public void testSubscribeHashMapOfStringObject() {
		pubnub.CIPHER_KEY = "";
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
                deliveryStatus = true;
                // Continue Listening?
                return false;
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
        args.put("callback", new Receiver());

        deliveryStatus = false;
        // Listen for Messages (Subscribe)
        pubnub.subscribe(args);
        JSONObject json = new JSONObject();
        try {
			json.put("text", "hi");
		} catch (JSONException e) {
			e.printStackTrace();
		}
        pubnub.publish(channel, json);
        while(!deliveryStatus);
        assertTrue(deliveryStatus);
        System.out.println("PASS: TestSubscribe");
	}

	@Test
	public void testPresenceHashMapOfStringObject() {
		pubnub.CIPHER_KEY = "";
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
                deliveryStatus = true;
                // Continue Listening?
                return false;
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

        deliveryStatus = false;
        // Listen for Messages (Presence)
        pubnub.presence(args);
        while(!deliveryStatus);
        assertTrue(deliveryStatus);
        System.out.println("PASS: TestPresence");
    }

	@Test
	public void testHere_now() {
		pubnub.CIPHER_KEY = "";
		// Get Here Now
		JSONArray response = pubnub.here_now(channel);
		
		try {
			assertNotNull(response);
			System.out.println("PASS: TestHere_Now");
		} catch (Exception e) {
			fail("FAIL: TestHere_Now");
		}
	}

	@Test
	public void testUnencryptedHistoryHashMapOfStringObject() {
		// Context setup
		pubnub.CIPHER_KEY = "";
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
		
		// Test begins
		args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("limit", limit);
		
		// Get History
		response = pubnub.history(args);
		
		try {
			assertNotNull(response);
			System.out.println("PASS: TestUnencryptedHistory");
		} catch (Exception e) {
			fail("FAIL: TestUnencryptedHistory");
		}
	}
	
	@Test
	public void testEncryptedHistoryHashMapOfStringObject() {
		// Context setup
		pubnub.CIPHER_KEY = "enigma";
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
		
		// Test begins
		args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("limit", limit);
		
		// Get History
		response = pubnub.history(args);
		
		try {
			assertNotNull(response);
			System.out.println("PASS: TestEncryptedHistory");
		} catch (Exception e) {
			fail("FAIL: TestEncryptedHistory");
		}
	}

	@Test
	public void testUnencryptedDetailedHistory()
	{
		// Context setup for Detailed History
		pubnub.CIPHER_KEY = "";
        int total_msg = 10;
        long starttime = (long) pubnub.time();
        HashMap<Long, String> inputs = new HashMap<Long, String>();
        for (int i = 0; i < total_msg / 2; i++)
        {
            String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long midtime = (long) pubnub.time();
        for (int i = total_msg / 2; i < total_msg; i++)
        {
        	String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long endtime = (long)pubnub.time();
		
        // Get History
     	JSONArray response = pubnub.detailedHistory(channel, total_msg);
     		
     	// Print Response from PubNub JSONP REST Service
     	System.out.println(response);
     		
     	try {
     		assertNotNull(response);
     		System.out.println("PASS: TestUnencryptedDetailedHistory");
     	} catch (Exception e) {
     		fail("FAIL: TestUnencryptedDetailedHistory");
     	}
	}
	
	@Test
	public void testEncryptedDetailedHistory()
	{
		// Context setup for Detailed History
		pubnub.CIPHER_KEY = "enigma";
        int total_msg = 10;
        long starttime = (long) pubnub.time();
        HashMap<Long, String> inputs = new HashMap<Long, String>();
        for (int i = 0; i < total_msg / 2; i++)
        {
            String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long midtime = (long) pubnub.time();
        for (int i = total_msg / 2; i < total_msg; i++)
        {
        	String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long endtime = (long)pubnub.time();
		
        // Get History
     	JSONArray response = pubnub.detailedHistory(channel, total_msg);
     		
     	// Print Response from PubNub JSONP REST Service
     	System.out.println(response);
     		
     	try {
     		assertNotNull(response);
     		System.out.println("PASS: TestEncryptedDetailedHistory");
     	} catch (Exception e) {
     		fail("FAIL: TestEncryptedDetailedHistory");
     	}
	}
	
	@Test
	public void testUnencryptedDetailedHistoryParams()
	{
		// Context setup for Detailed History
		pubnub.CIPHER_KEY = "";
        int total_msg = 10;
        long starttime = (long) pubnub.time();
        HashMap<Long, String> inputs = new HashMap<Long, String>();
        for (int i = 0; i < total_msg / 2; i++)
        {
            String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long midtime = (long) pubnub.time();
        for (int i = total_msg / 2; i < total_msg; i++)
        {
        	String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long endtime = (long)pubnub.time();
		
        // Get History
        JSONArray response;
        System.out.println("DetailedHistory with start & end");
        response = pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true);
        System.out.println(response);
        try {
     		assertNotNull(response);
     	} catch (Exception e) {
     		fail("FAIL: TestUnencryptedDetailedHistoryParams");
     	}
        
        System.out.println("DetailedHistory with start & reverse = true");
        response = pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true);
        System.out.println(response);
        try {
     		assertNotNull(response);
     	} catch (Exception e) {
     		fail("FAIL: TestUnencryptedDetailedHistoryParams");
     	}
        
        System.out.println("DetailedHistory with start & reverse = false");
        response = pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false);
        System.out.println(response);
        try {
     		assertNotNull(response);
     		System.out.println("PASS: TestUnencryptedDetailedHistoryParams");
     	} catch (Exception e) {
     		fail("FAIL: TestUnencryptedDetailedHistoryParams");
     	}
    }
	
	@Test
	public void testEncryptedDetailedHistoryParams()
	{
		// Context setup for Detailed History
		pubnub.CIPHER_KEY = "enigma";
        int total_msg = 10;
        long starttime = (long) pubnub.time();
        HashMap<Long, String> inputs = new HashMap<Long, String>();
        for (int i = 0; i < total_msg / 2; i++)
        {
            String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long midtime = (long) pubnub.time();
        for (int i = total_msg / 2; i < total_msg; i++)
        {
        	String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
    			json.put("text", msg);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            pubnub.publish(channel, json);
            long t = (long) pubnub.time();
            inputs.put(t, msg);
            System.out.println("Message # " + Integer.toString(i) + " published");
        }

        long endtime = (long)pubnub.time();
		
        // Get History
        JSONArray response;
        System.out.println("DetailedHistory with start & end");
        response = pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true);
        System.out.println(response);
        try {
     		assertNotNull(response);
     	} catch (Exception e) {
     		fail("FAIL: TestEncryptedDetailedHistoryParams");
     	}
        
        System.out.println("DetailedHistory with start & reverse = true");
        response = pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true);
        System.out.println(response);
        try {
     		assertNotNull(response);
     	} catch (Exception e) {
     		fail("FAIL: TestEncryptedDetailedHistoryParams");
     	}
        
        System.out.println("DetailedHistory with start & reverse = false");
        response = pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false);
        System.out.println(response);
        try {
     		assertNotNull(response);
     		System.out.println("PASS: TestEncryptedDetailedHistoryParams");
     	} catch (Exception e) {
     		fail("FAIL: TestEncryptedDetailedHistoryParams");
     	}
	}
	
	@Test
	public void testTime() {
		assertNotNull(pubnub.time());
	}

	@Test
	public void testUuid() {
		assertNotNull(Pubnub.uuid());
	}
}
