import org.json.*;
import pubnub.Pubnub;
import pubnub.Callback;

class PubnubTest {
    public static void main(String args[]) {
        PubnubTest.test_time();
        PubnubTest.test_publish();
        PubnubTest.test_history();
        PubnubTest.test_subscribe();
    }

    public static void test_time() {
        // Publish Test
        System.out.println("\nTESTING TIME:");

        // Create Pubnub Object
        Pubnub pubnub = new Pubnub( "demo", "demo", "", false );

        System.out.println(pubnub.time());
    }
    public static void test_publish() {
        // Publish Test
        System.out.println("\nTESTING PUBLISH:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo", "", false );
        String channel = "java_test_channel";

        // Create JSON Message
        JSONObject message = new JSONObject();
        try { message.put( "some_val", "Hello World! --> ɂ顶@#$%^&*()!" ); }
        catch (org.json.JSONException jsonError) {}

        // Publish Message
        JSONArray info = pubnub.publish( channel, message );

        // Print Response from PubNub JSONP REST Service
        System.out.println(info);
    }

    public static void test_history() {
        // History Test
        System.out.println("\nTESTING HISTORY:");

        // Create Pubnub Object
        Pubnub pubnub  = new Pubnub( "demo", "demo", "", false );
        String channel = "java_test_channel";
        int    limit   = 1;

        // Get History
        JSONArray response = pubnub.history( channel, limit );

        // Print Response from PubNub JSONP REST Service
        System.out.println(response);
        System.out.println(response.optJSONObject(0).optString("some_val"));
    }

    public static void test_subscribe() {
        // Subscribe Test
        System.out.println("\nTESTING SUBSCRIBE:");

        Pubnub pubnub  = new Pubnub( "demo", "demo", "", false );
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


