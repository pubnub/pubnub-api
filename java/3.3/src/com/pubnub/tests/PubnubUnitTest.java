package com.pubnub.tests;

import static java.lang.System.*;
import static org.junit.Assert.*;

import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Ignore;
import org.junit.Test;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

class Receiver implements Callback {

    public boolean successCallback(String channel, Object message) {

        assertNull(message);
        try {
            if (message instanceof JSONObject) {
                JSONObject obj = (JSONObject) message;
                @SuppressWarnings("rawtypes")
                Iterator keys = obj.keys();
                while (keys.hasNext()) {
                    out.print(obj.get(keys.next().toString()) + " ");
                }
                out.println();
            } else if (message instanceof String) {
                String obj = (String) message;
                out.print(obj + " ");
                out.println();
            } else if (message instanceof JSONArray) {
                JSONArray obj = (JSONArray) message;
                out.print(obj.toString() + " ");
                out.println();
            }
        } catch (Exception e) {
            fail();
        }

        // false, do not continue to subscribe
        return false;
    }

    public void errorCallback(String channel, Object message) {
        System.err.println("Channel:" + channel + "-" + message.toString());

    }

    public void connectCallback(String channel) {
        out.println("Connected to channel :" + channel);
    }

    public void reconnectCallback(String channel) {
        out.println("Reconnected to channel :" + channel);
    }

    public void disconnectCallback(String channel) {
        out.println("Disconnected to channel :" + channel);
    }

}

public class PubnubUnitTest {
    static String publish_key = "demo";
    static String subscribe_key = "demo";
    static String secret_key = "demo";
    static String cipher_key = "enigma"; // (Cipher key is optional)
    static String channel = "hello_world";
    static Pubnub pubnub = null;
    @Test
    public void testPublishHashMapOfStringObject() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, cipher_key,
                true);

        try {
            JSONArray response = pubnub.publish(channel, new JSONObject(
            "{ 'text': 'Hello World!'}"));
            assertTrue(response.get(0).toString().equals("1"));
        } catch (JSONException e) {
            fail("FAIL: TestPublish");
        }
    }

    @Test
    public void testSubscribeHashMapOfStringObject() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, "", true);

        // Callback Interface when a Message is Received
        class SubscribeReceiver extends Receiver {
            public void connectCallback(String channel) {
                try {
                    pubnub.publish(channel, new JSONObject().put("text", "hi"));
                } catch (JSONException e) {
                    fail("FAIL: TestSubscribe, publish");
                }
            }

            public boolean successCallback(String channel, Object message) {
                assertNotNull(message);

                JSONObject obj = (JSONObject) message;
                try {
                    assertTrue(obj.get("text").equals("hi"));
                } catch (JSONException e) {
                    fail("FAIL: TestSubscribe, Success Callback");
                }

                // false, do not continue to subscribe
                return false;
            }
        }
        // Listen for Messages (Subscribe)
        try {
            pubnub.subscribe(channel, new SubscribeReceiver());
        } catch (PubnubException e) {
            fail("FAIL: TestSubscribe, PubnubException");
            return;
        }
        return;
    }

 
    /**
     * 
     */
    @Ignore
    public void testPresenceHashMapOfStringObject() {

        Pubnub pubnub_p = new Pubnub(publish_key, subscribe_key, secret_key,"", true); 
        final Pubnub pubnub_s = new Pubnub(publish_key,subscribe_key, secret_key, "", true);

        class SubscribeReceiver extends Receiver {
            @Override 
            public void connectCallback(String channel) {
            }
            @Override 
            public boolean successCallback(String channel, Object     message) { 
                return false; 
            } 
        }


        // Callback Interface when a Message is Received
        class PresenceReceiver extends Receiver {
            @Override 
            public void connectCallback(String channel) { 
                try {
                    pubnub_s.subscribe(PubnubUnitTest.channel, new SubscribeReceiver());
                } catch (PubnubException e) { 
                    fail("TestPresence : PubnubException");
                    return; 
                }
            }

            @Override 
            public boolean successCallback(String channel, Object message) { 
                assertNull(message);
                JSONArray jsona = (JSONArray) message; JSONArray jsona0 = null; 
                try {
                    jsona0 = (JSONArray) jsona.get(0); 
                } catch (JSONException e1) {
                    fail("FAIL: TestPresence, publish"); return false; 
                }
                if (jsona0.length() == 0 ) {

                }

                // false, do not continue to subscribe 
                try {
                    pubnub_s.publish(channel, new JSONObject("{'text': 'hi'}")); 
                } catch (JSONException e) { 
                    fail("FAIL: TestPresence, publish"); 
                } 
                return false; 

            } 

        }

        // Listen for Messages (Presence) 
        try { 
            pubnub_p.presence(channel, new PresenceReceiver()); 
        } catch (PubnubException e) {
            fail("TestPresence : PubnubException"); 
            return; 
        }
    }

    @Test
    public void testHere_now() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, "", true);
        // Get Here Now
        class SubscribeReceiver extends Receiver {
            @Override
            public void connectCallback(String channel) {
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException e) {
                    fail("InterruptedException");
                }
                JSONArray response = pubnub.here_now(channel);
                try {
                    boolean uuidfound = false;
                    JSONArray uuidslist = (JSONArray) new JSONObject(response
                            .get(0).toString()).get("uuids");
                    for (int i = 0; i < uuidslist.length(); i++) {
                        if (uuidslist.getString(i).equals(pubnub.sessionUUID())) {
                            uuidfound = true;
                            break;
                        }
                    }
                    assertTrue(uuidfound);
                } catch (JSONException e1) {
                    fail("JSONException");
                }
                assertNotNull(response);
                try {
                    pubnub.publish(channel, new JSONObject().put("text", "hi"));
                } catch (JSONException e) {
                    fail("JSONException");
                }
            }

            @Override
            public boolean successCallback(String channel, Object message) {
                return false;
            }
        }
        try {
            pubnub.subscribe(channel, new SubscribeReceiver());
        } catch (PubnubException e) {
            fail("PubnubException");
        }
    }

    private void testHistoryHashMapOfStringObject(Pubnub pubnub) {

        // fresh channel required. Existing unencrypted messages published to
        // channel cause errors in decryption
        String channel = PubnubUnitTest.channel + '-' + pubnub.sessionUUID();
        JSONObject message = new JSONObject();
        try {
            message.put("text", "Hello World!");
        } catch (JSONException e) {
            fail("FAIL: TestEncryptedHistory, JSON Exception");
        }
        JSONArray response = null;
        for (int i = 0; i < 5; i++) {
            response = pubnub.publish(channel, message);
        }
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            fail("InterruptedException");
        }

        // Get History
        response = pubnub.history(channel, 1);
        assertTrue(response.length() == 1);

        // Get History
        response = pubnub.history(channel, 5);
        assertTrue(response.length() == 5);

    }

    @Test
    public void testUnencryptedHistoryHashMapOfStringObject() {
        // Context setup
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, "", true);
        testHistoryHashMapOfStringObject(pubnub);
    }

    @Test
    public void testEncryptedHistoryHashMapOfStringObject() {
        // Context setup
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, cipher_key,
                true);
        testHistoryHashMapOfStringObject(pubnub);
    }

    private void publishForDetailedHistory(String channel, int number,
            int offset, String[] inputs) {
        for (int i = 0 + offset; i < number + offset; i++) {
            String msg = Integer.toString(i);
            JSONObject json = new JSONObject();
            try {
                json.put("text", msg);
            } catch (JSONException e) {
                fail("FAIL: JSON Exception in publishForDetailedHistory");
            }
            pubnub.publish(channel, json);
            if (inputs != null)
                inputs[i] = msg;
        }

    }

    public void testDetailedHistory(Pubnub pubnub) {
        int total_msg = 6;
        String[] inputs = new String[total_msg];

        // fresh channel required. Existing unencrypted messages published to
        // channel cause errors in decryption
        String channel = PubnubUnitTest.channel + '-' + pubnub.sessionUUID();

        long starttime = (long) pubnub.time();
        publishForDetailedHistory(channel, total_msg / 2, 0, inputs);
        long midtime = (long) pubnub.time();
        publishForDetailedHistory(channel, total_msg / 2, total_msg / 2, inputs);
        long endtime = (long) pubnub.time();
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e1) {
            e1.printStackTrace();
        }
        
        JSONArray response = null;

        response = pubnub.detailedHistory(channel, starttime, endtime);
        try {
            assertTrue(response != null && ((JSONArray) response.get(0)).length() == total_msg);
        } catch (JSONException e) {
            fail("JSONException");
        }

        response = pubnub.detailedHistory(channel, starttime, midtime,
                total_msg, true);
        try {
            assertTrue(response != null && ((JSONArray) response.get(0)).length() == total_msg/2);
        } catch (JSONException e) {
            fail("JSONException");
        }

        response = pubnub.detailedHistory(channel,(int)1, false);
        try {
            assertTrue(response != null && 
                    Integer.parseInt((String)((JSONObject)((JSONArray) response.get(0)).get(0)).get("text")) == total_msg -1);
        } catch (JSONException e) {
            fail("JSONException");
        }

        response = pubnub.detailedHistory(channel,(int)1, true);
        try {
            assertTrue(response != null && 
                    Integer.parseInt((String)((JSONObject)((JSONArray) response.get(0)).get(0)).get("text")) == 0);
        } catch (JSONException e) {
            fail("JSONException");
        }
    }

    @Test
    public void testUnencryptedDetailedHistory() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, "", true);
        testDetailedHistory(pubnub);
    }

    @Test
    public void testEncryptedDetailedHistory() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, cipher_key,
                true);
        testDetailedHistory(pubnub);
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
