import org.json.*;
import pubnub.Pubnub;
import pubnub.Callback;

public class Client {
    public static void main(String [] args) {
        Pubnub pn = new Pubnub( "demo", "demo", "", false );
        Receiver rcv = new Receiver();
        System.out.println("Subscribed to 'hello_world' Channel ");
        pn.subscribe( "hello_world", rcv );
        System.out.println("done");
    }
}

class Receiver implements Callback {
    @Override
    public boolean execute(JSONObject message) {
        System.out.println(message);
        return true;
    }
}
