package com.pubnub.examples;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.pubnub.api.Pubnub;
import com.pubnub.api.Callback;
import com.pubnub.api.PubnubException;

class Receiver implements Callback {

    public boolean successCallback(String channel, Object message) {

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
        // Continue Listening?
        return true;
    }

    public void errorCallback(String channel, Object message) {
        System.err.println("Channel:" + channel + "-"
                + message.toString());

    }

    public void connectCallback(String channel) {
        System.out.println("Connected to channel :" + channel);
        System.out.println("Waiting for message ...");
    }

    public void reconnectCallback(String channel) {
        System.out.println("Reconnected to channel :" + channel);
    }

    public void disconnectCallback(String channel) {
        System.out.println("Disconnected to channel :" + channel);
    }

}

public class PubnubExample {
    static String publish_key = "demo";
    static String subscribe_key = "demo";
    static String secret_key = "demo";
    static String cipher_key = ""; // (Cipher key is optional)
    static String channel = "hello_world";
    static Pubnub pubnub = null;

    /**
     * @param params
     */
    public static void main(String[] params) {

        pubnub = new Pubnub(publish_key, subscribe_key, secret_key,
                cipher_key, true);
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

//        System.out.println("\nRunning presence()");
//        PresenceExample();

        System.out.println("\nRunning subscribe()");
        SubscribeExample();

    }

    private static void PublishExample() {

        int publish_message_count = 1;

        int count = 0;
        while (true) {
            if (count >= publish_message_count)
                break;
            count++;

            // Create JSON Message
            JSONObject message = new JSONObject();
            try {
                message.put("text", "Hello World!" + count);
                /*
                 * message.put("title", "Java Client PubNub";
                 * message.put("some_val",
                 * "This is a push to all users! Fighting!" message.put("url",
                 * "http://www.pubnub.com"
                 */
            } catch (org.json.JSONException jsonError) {
            }

            // Publish
            HashMap<String, Object> args = new HashMap<String, Object>(2);
            args.put("channel", channel);
            args.put("message", message);
            JSONArray response = null;
            response = pubnub.publish(channel, message);
            System.out.println(response);

            try {
                response = pubnub.publish(channel, new JSONObject("{'data' : 'Hello World'}"));
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            System.out.println(response);

            JSONArray array = new JSONArray();
            array.put("Sunday");
            array.put("Monday");
            array.put("Tuesday");
            array.put("Wednesday");
            array.put("Thursday");
            array.put("Friday");
            array.put("Saturday");

            response = pubnub.publish(channel, new JSONObject(array));
            System.out.println(response);
        }
    }

    private static void HistoryExample() {
        int limit = 1;

        // Get History
        JSONArray response = pubnub.history(channel, limit);

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);

        try {
            if (response != null) {
                for (int i = 0; i < response.length(); i++) {
                    JSONObject jsono = response.optJSONObject(i);
                    if (jsono != null) {
                        @SuppressWarnings("rawtypes")
                        Iterator keys = jsono.keys();
                        while (keys.hasNext()) {
                            System.out.println(jsono
                                    .get(keys.next().toString()) + " ");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void DetailedHistoryExample() {
        int count = 1;


        // Get History
        JSONArray response = pubnub.detailedHistory(channel, count, false);

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);

        try {
            if (response != null) {
                for (int i = 0; i < response.length(); i++) {
                    JSONObject jsono = response.optJSONObject(i);
                    if (jsono != null) {
                        @SuppressWarnings("rawtypes")
                        Iterator keys = jsono.keys();
                        while (keys.hasNext()) {
                            System.out.println(jsono
                                    .get(keys.next().toString()) + " ");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void TimestampExample() {

        // Print Server Time
        System.out.println("Time: " + Double.toString(pubnub.time()));
    }

    private static void SubscribeExample() {

        // Listen for Messages (Subscribe)
        try {
            pubnub.subscribe(channel, new Receiver());
        } catch (PubnubException e) {
            e.printStackTrace();
            return;
        }
    }

    private static void PresenceExample() {

        // Listen for Messages (Presence)
        try {
            pubnub.presence(channel, new Receiver());
        } catch (PubnubException e) {
            e.printStackTrace();
            return;
        }
    }

    private static void HereNowExample() {

        // Get Here Now
        JSONArray response = pubnub.here_now(channel);

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);

        try {
            if (response != null) {
                for (int i = 0; i < response.length(); i++) {
                    JSONObject jsono = response.optJSONObject(i);
                    if (jsono != null) {
                        @SuppressWarnings("rawtypes")
                        Iterator keys = jsono.keys();
                        while (keys.hasNext()) {
                            System.out.println(jsono
                                    .get(keys.next().toString()) + " ");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
