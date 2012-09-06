package src.tests;

import pubnub.Pubnub;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class URLEncodeTest {

    public static void main(String args[]) throws JSONException {
        Pubnub pubnub = new Pubnub("demo", "demo");
        JSONObject obj = new JSONObject("{\"foo\":\"bar\",\"lang\":\"עברית\"}");
        JSONArray result = pubnub.publish("json_bug", obj);
        System.out.println(result);

        if ( result.get(0).equals(1) )
            System.out.println("Passed.");
        else
            System.out.println("Failed.");
    }
}






