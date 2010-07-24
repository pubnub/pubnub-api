package pubnub;
import org.json.*;
import java.util.HashMap;
import java.util.Iterator;
import java.net.URL;
import java.net.URLEncoder;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Pubnub {
    private static String ORIGIN        = "http://pubnub-prod.appspot.com";
    private static int    LIMIT         = 1700;
    private static int    UNIQUE        = 1;
    private static String PUBLISH_KEY   = "";
    private static String SUBSCRIBE_KEY = "";

    public Pubnub( String publish_key, String subscribe_key ) {
        Pubnub.PUBLISH_KEY   = publish_key;
        Pubnub.SUBSCRIBE_KEY = subscribe_key;
    }

    public JSONObject publish( String channel, JSONObject message ) {
        HashMap<String,String> params = new HashMap<String,String>();
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;

        // Prepare HTTP GET Params
        params.put( "publish_key", Pubnub.PUBLISH_KEY );
        params.put( "channel", channel );
        params.put( "message", message.toString() );

        return this._request( Pubnub.ORIGIN + "/pubnub-publish", params );
    }

    public void subscribe( String channel, Callback callback ) {
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;
        this._subscribe( channel, callback, "0", "" );
    }

    private void _subscribe(
        String   channel,
        Callback callback,
        String   timetoken,
        String   server
    ) {
        boolean keep_listening = true;

        // Find a PubNub Server
        if (server.length() == 0) {
            HashMap<String,String> sub_params = new HashMap<String,String>();

            sub_params.put( "channel", channel );

            JSONObject resp_for_server = this._request(
                Pubnub.ORIGIN + "/pubnub-subscribe",
                sub_params
            );

            server = resp_for_server.optString("server");
        }

        try {
            HashMap<String,String> conn_params = new HashMap<String,String>();

            // Prepare HTTP GET Params
            conn_params.put( "channel", channel );
            conn_params.put( "timetoken", timetoken );

            // Listen for a Message
            JSONObject response = this._request(
                "http://" + server + "/",
                conn_params
            );

            // Capture Messages
            JSONArray messages = response.optJSONArray("messages");

            // Test for Message
            if (messages.length() == 0) {
                this._subscribe( channel, callback, timetoken, "" );
                return;
            }

            // Was it a Timeout
            if (messages.optString( 0, "n" ).equals("xdr.timeout")) {
                timetoken = response.optString("timetoken");
                this._subscribe( channel, callback, timetoken, server );
                return;
            }

            // Run user Callback and Reconnect if user permits.
            for ( int i = 0; messages.length() > i; i++ ) {
                JSONObject message = messages.optJSONObject(i);
                keep_listening = keep_listening && callback.execute(message);
            }

            // Keep listening if Okay.
            if (keep_listening) {
                timetoken = response.optString("timetoken");
                this._subscribe( channel, callback, timetoken, server );
                return;
            }
        }
        catch (Exception e) {
            this._subscribe( channel, callback, timetoken, "" );
            return;
        }
    }

    public JSONArray history( String channel, int limit ) {
        HashMap<String,String> params = new HashMap<String,String>();
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;

        // Prepare HTTP GET Params
        params.put( "channel", channel );
        params.put( "limit", Integer.toString(limit) );

        JSONObject response = this._request(
            Pubnub.ORIGIN + "/pubnub-history",
            params
        );

        return response.optJSONArray("messages");
    }

    public JSONObject _request( String url, HashMap<String,String> args ) {
        // Add Unique Param
        args.put( "unique", Integer.toString(Pubnub.UNIQUE) );

        String   json         = "";
        Iterator arg_iterator = args.keySet().iterator();

        url += "?";
        while (arg_iterator.hasNext()) {
            try {
                String key = (String)arg_iterator.next();
                url += URLEncoder.encode( key, "UTF-8" ) + "=" +
                       URLEncoder.encode( args.get(key), "UTF-8" ) + "&";
            }
            catch(java.io.UnsupportedEncodingException e) {
                e.printStackTrace();
                JSONObject jsono = new JSONObject();
                try { jsono.put( "message", "Failed UTF-8 Encoding URL." ); }
                catch (org.json.JSONException jsone) {}
                return jsono;
            }
        }
        url = url.substring( 0, url.length() -1 );

        // Fail if string too long
        if (url.length() > Pubnub.LIMIT) {
            JSONObject jsono = new JSONObject();
                try { jsono.put( "message", "Message Too Long." ); }
                catch (org.json.JSONException jsone) {}
            return jsono;
        }

        try {
            URL            request = new URL(url);
            String         line    = "";
            String         jsonp   = "";
            BufferedReader reader  = new BufferedReader(
                new InputStreamReader(request.openStream())
            );

            // Read JSONP Message
            while ((line = reader.readLine()) != null) { jsonp += line; }
            reader.close();

            // Remove JSONP Wrapper
            json = jsonp.substring( 10, jsonp.length() - 1 );
            // System.out.println(jsonp);

        } catch (Exception e) {
            JSONObject jsono = new JSONObject();

            try { jsono.put( "message", "Failed JSONP HTTP Request." ); }
            catch (org.json.JSONException jsone) {}

            e.printStackTrace();
            System.out.println(e);

            return jsono;
        }

        // System.out.println(json);

        // Parse JSON String
        try { return new JSONObject(json); }
        catch (org.json.JSONException jsone) {}

        return new JSONObject();
    }
}

