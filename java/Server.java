import org.json.*;
import pubnub.Pubnub;
import pubnub.Callback;

public class Server {
    public static void main(String [] args) {
        Pubnub pn = new Pubnub( "demo", "demo", "", false );
        int count = 0;

        while (true) {
            count++;
            System.out.print("sending message: " + count);
            JSONObject message = new JSONObject();
            try { message.put(
                "some_val",
                "Hello World! --> " + Integer.toString(count)
            ); }
            catch (org.json.JSONException jsonError) {
                System.out.println(jsonError);
            }

            JSONArray info = pn.publish( "hello_world", message );
            System.out.println(", info: " + info);
            try { Thread.currentThread().sleep(1000); }
            catch ( Exception ex ) {}
        }
    }
}
