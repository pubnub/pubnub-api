import org.json.*;
import pubnub.Pubnub;
import pubnub.Callback;

class PubnubTest {
    public static void main(String args[]) {
        PubnubTest.test_publish();
        PubnubTest.test_history();
        PubnubTest.test_subscribe();
    }

    public static void test_publish() {
        // Publish Test
        System.out.println("\nTESTING PUBLISH:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo" );
        String channel = "java_test_channel";

        // Create JSON Message
        JSONObject message = new JSONObject();
        try { message.put( "some_val", "Hello World!" ); }
        catch (org.json.JSONException jsonError) {}

        // Publish Message
        JSONObject response = pubnub.publish( channel, message );

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);

        System.out.println(response.optString("status"));
        System.out.println(response.optString("message"));
    }

    public static void test_history() {
        // History Test
        System.out.println("\nTESTING HISTORY:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo" );
        String channel = "java_test_channel";
        int    limit   = 10;

        // Publish Message
        JSONArray response = pubnub.history( channel, limit );

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);
        System.out.println(response.optJSONObject(0).optString("some_val"));
    }

    public static void test_subscribe() {
        // Subscribe Test
        System.out.println("\nTESTING SUBSCRIBE:");

        Pubnub pubnub  = new Pubnub( "demo", "demo" );
        String channel = "java_test_channel";

        // Callback Interface when a Message is Received
        class Receiver implements Callback {
            public boolean execute(JSONObject message) {

                // Print Received Message
                System.out.println(message);

                // Continue Listening?
                return true;
            }
        }

        // Create a new Message Receiver
        Receiver message_receiver = new Receiver();

        // Listen for Messages (Subscribe)
        pubnub.subscribe( channel, message_receiver );
    }
}


