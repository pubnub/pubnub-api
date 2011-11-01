package com.fbt;

import org.json.*;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

import java.net.URL;
import java.net.URLConnection;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * PubNub 3.0 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package pubnub
 */
public class Pubnub {
    private String ORIGIN        = "pubsub.pubnub.com";
    private int    LIMIT         = 1800;
    private String PUBLISH_KEY   = "";
    private String SUBSCRIBE_KEY = "";
    private String SECRET_KEY    = "";
    private boolean SSL          = false;

    /**
     * PubNub 3.0
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     * @param boolean SSL Enabled.
     */
    public Pubnub(
        String publish_key,
        String subscribe_key,
        String secret_key,
        boolean ssl_on
    ) {
        this.init( publish_key, subscribe_key, secret_key, ssl_on );
    }

    /**
     * PubNub 2.0 Compatibility
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     */
    public Pubnub(
        String publish_key,
        String subscribe_key
    ) {
        this.init( publish_key, subscribe_key, "", false );
    }

    /**
     * PubNub 3.0 without SSL
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     */
    public Pubnub(
        String publish_key,
        String subscribe_key,
        String secret_key
    ) {
        this.init( publish_key, subscribe_key, secret_key, false );
    }

    /**
     * Init
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     * @param boolean SSL Enabled.
     */
    public void init(
        String publish_key,
        String subscribe_key,
        String secret_key,
        boolean ssl_on
    ) {
        this.PUBLISH_KEY   = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY    = secret_key;
        this.SSL           = ssl_on;

        // SSL On?
        if (this.SSL) {
            this.ORIGIN = "https://" + this.ORIGIN;
        }
        else {
            this.ORIGIN = "http://" + this.ORIGIN;
        }
    }

    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param String channel name.
     * @param JSONObject message.
     * @return boolean false on fail.
     */
    public JSONArray publish( String channel, JSONObject message ) {
        // Generate String to Sign
        String signature = "0";
        if (this.SECRET_KEY.length() > 0) {
            StringBuilder string_to_sign = new StringBuilder();
            string_to_sign
                .append(this.PUBLISH_KEY)
                .append('/')
                .append(this.SUBSCRIBE_KEY)
                .append('/')
                .append(this.SECRET_KEY)
                .append('/')
                .append(channel)
                .append('/')
                .append(message.toString());

            // Sign Message
            signature = md5(string_to_sign.toString());
        }

        // Build URL
        List<String> url = new ArrayList<String>();
        url.add("publish");
        url.add(this.PUBLISH_KEY);
        url.add(this.SUBSCRIBE_KEY);
        url.add(signature);
        url.add(channel);
        url.add("0");
        url.add(message.toString());

        // Return JSONArray
        return _request(url);
    }

    /**
     * Subscribe
     *
     * This function is BLOCKING.
     * Listen for a message on a channel.
     *
     * @param String channel name.
     * @param Callback function callback.
     */
    public void subscribe( String channel, Callback callback ) {
        this._subscribe( channel, callback, "0" );
    }

    /**
     * Subscribe - Private Interface
     *
     * Patch provided by petereddy on GitHub
     *
     * @param String channel name.
     * @param Callback function callback.
     * @param String timetoken.
     */
    private void _subscribe(
        String   channel,
        Callback callback,
        String   timetoken
    ) {
        while (true) {
            try {
                // Build URL
                List<String> url = java.util.Arrays.asList(
                    "subscribe", this.SUBSCRIBE_KEY, channel, "0", timetoken
                );

                // Wait for Message
                JSONArray response = _request(url);
                JSONArray messages = response.optJSONArray(0);

                // Update TimeToken
                if (response.optString(1).length() > 0)
                    timetoken = response.optString(1);

                // Run user Callback and Reconnect if user permits. If
                // there's a timeout then messages.length() == 0.
                for ( int i = 0; messages.length() > i; i++ ) {
                    JSONObject message = messages.optJSONObject(i);
                    if (!callback.execute(message)) return;
                }
            }
            catch (Exception e) {
                try { Thread.sleep(1000); }
                catch(InterruptedException ie) {}
            }
        }
    }


    /**
     * History
     *
     * Load history from a channel.
     *
     * @param String channel name.
     * @param int limit history count response.
     * @return JSONArray of history.
     */
    public JSONArray history( String channel, int limit ) {
        List<String> url = new ArrayList<String>();

        url.add("history");
        url.add(this.SUBSCRIBE_KEY);
        url.add(channel);
        url.add("0");
        url.add(Integer.toString(limit));

        return _request(url);
    }

    /**
     * Time
     *
     * Timestamp from PubNub Cloud.
     *
     * @return double timestamp.
     */
    public double time() {
        List<String> url = new ArrayList<String>();

        url.add("time");
        url.add("0");

        JSONArray response = _request(url);
        return response.optDouble(0);
    }

    /**
     * Request URL
     *
     * @param List<String> request of url directories.
     * @return JSONArray from JSON response.
     */
    private JSONArray _request(List<String> url_components) {
        String   json         = "";
        StringBuilder url     = new StringBuilder();
        Iterator url_iterator = url_components.iterator();

        url.append(this.ORIGIN);

        // Generate URL with UTF-8 Encoding
        while (url_iterator.hasNext()) {
            try {
                String url_bit = (String) url_iterator.next();
                url.append("/").append(_encodeURIcomponent(url_bit));
            }
            catch(Exception e) {
                e.printStackTrace();
                JSONArray jsono = new JSONArray();
                try { jsono.put("Failed UTF-8 Encoding URL."); }
                catch (Exception jsone) {}
                return jsono;
            }
        }

        // Fail if string too long
        if (url.length() > this.LIMIT) {
            JSONArray jsono = new JSONArray();
                try { 
                    jsono.put(0); 
                    jsono.put("Message Too Long."); 
                }
                catch (Exception jsone) {}
            return jsono;
        }

        try {
            URL            request = new URL(url.toString());
            URLConnection  conn    = request.openConnection();
            String         line    = "";

            conn.setConnectTimeout(200000);
            conn.setReadTimeout(200000);

            BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream())
            );

            // Read JSON Message
            while ((line = reader.readLine()) != null) { json += line; }
            reader.close();

        } catch (Exception e) {

            JSONArray jsono = new JSONArray();

            try { jsono.put("Failed JSONP HTTP Request."); }
            catch (Exception jsone) {}

            e.printStackTrace();
            System.out.println(e);

            return jsono;
        }

        // Parse JSON String
        try { return new JSONArray(json); }
        catch (Exception e) {
            JSONArray jsono = new JSONArray();

            try { jsono.put("Failed JSON Parsing."); }
            catch (Exception jsone) {}

            e.printStackTrace();
            System.out.println(e);

            // Return Failure to Parse
            return jsono;
        }
    }

    private String _encodeURIcomponent(String s) {
        StringBuilder o = new StringBuilder();
        for (char ch : s.toCharArray()) {
            if (isUnsafe(ch)) {
                o.append('%');
                o.append(toHex(ch / 16));
                o.append(toHex(ch % 16));
            }
            else o.append(ch);
        }
        return o.toString();
    }

    private char toHex(int ch) {
        return (char)(ch < 10 ? '0' + ch : 'A' + ch - 10);
    }

    private boolean isUnsafe(char ch) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".indexOf(ch) >= 0;
    }

    private String md5(String input) {
        try {
            MessageDigest md            = MessageDigest.getInstance("MD5");
            byte[]        messageDigest = md.digest(input.getBytes());
            BigInteger    number        = new BigInteger(1, messageDigest);
            String        hashtext      = number.toString(16);

            while (hashtext.length() < 32) hashtext = "0" + hashtext;

            return hashtext;
        }
        catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}

