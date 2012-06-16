package examples;

import java.util.HashMap;
import org.json.JSONArray;
import org.json.JSONObject;
import pubnub.Pubnub;

public class PublishExample {

    @SuppressWarnings("static-access")
    public static void main(String[] params) {

        String pub_key = "demo", sub_key = "demo";
        String secret_key = "demo", cipher_key = "demo";
        String channel = "hello_world";    // "c2dmalt"; "androidsample"; 

        int publish_messages_count = 1;

        Pubnub pubnub = new Pubnub(pub_key, sub_key, secret_key, cipher_key, true);
        int count = 0;
        while (true) {
            if (count < publish_messages_count) {
                count++;

                // Create JSON Message
                JSONObject message = new JSONObject();
                try {
                    message.put("some_val", "Hello World! --> ɂ顶@#$%^&*()!"+ count);
                    /*
                     * message.put( "title", "Android PubNub"); message.put(
                     * "text", "This is a push to all users! woot!");
                     * message.put( "url", "http://www.pubnub.com");
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

                // Pause
                try {
                    Thread.currentThread().sleep(100);
                } catch (Exception ex) {
                }

            } else {
                break;
            }
        }
    }
}
