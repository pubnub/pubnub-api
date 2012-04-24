package com.fbt;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;
import java.util.zip.GZIPInputStream;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import pubnub.PubnubCrypto;
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
    private String CIPHER_KEY    = "";
    private boolean SSL          = false;
    
    /**
     * Added constructor to share cipher_key
     * With cipher_key (plaintext)
     * 
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     * @param String Cipher Key.
     * @param boolean SSL Enabled.
     */
	public Pubnub(
        String publish_key,
        String subscribe_key,
        String secret_key,
        String cipher_key,
        boolean ssl_on
    ) {
        this.init( publish_key, subscribe_key, secret_key, cipher_key, ssl_on );
    }
    
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
        this.init( publish_key, subscribe_key, secret_key, "", ssl_on );
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
        this.init( publish_key, subscribe_key, "", "", false );
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
        this.init( publish_key, subscribe_key, secret_key, "", false );
    }

    /**
     * Init
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     * @param String Cipher Key.
     * @param boolean SSL Enabled.
     */
    public void init(
        String publish_key,
        String subscribe_key,
        String secret_key,
        String cipher_key,
        boolean ssl_on
    ) {
        this.PUBLISH_KEY   = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY    = secret_key;
    	this.CIPHER_KEY	= cipher_key;
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
     * @return JSONArray.
     */
    public JSONArray publish( String channel, JSONObject message ) {
    	HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("message", message);
		return publish( args );
    }
    
    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param HashMap<String, Object> containing channel name, message.
     * @return JSONArray.
     */
    public JSONArray publish( HashMap<String, Object> args ) {

    	String channel = (String) args.get("channel");
    	JSONObject message = (JSONObject) args.get("message");

    	// Generate String to Sign
        String signature = "0";
        
    	if(this.CIPHER_KEY.length() > 0){
    		// Encrypt Message
    		PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
    		message = pc.encrypt(message);
    	}
        
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
            signature = PubnubCrypto.getHMacSHA256(this.SECRET_KEY, string_to_sign.toString());
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
     * Listen for a message on a channel.
     *
     * @param String channel name.
     * @param Callback function callback.
     */
    public void subscribe( String channel, Callback callback ) {
    	HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("callback", callback);
		subscribe( args );
    }
    /**
     * Subscribe
     *
     * Listen for a message on a channel.
     *
     * @param HashMap<String, Object> containing channel name, function callback.
     */
    public void subscribe( HashMap<String, Object> args ) {
    	args.put("timetoken", "0");
        this._subscribe( args );
    }

    /**
     * Subscribe - Private Interface
     *
     * Patch provided by petereddy on GitHub
     *
     * @param HashMap<String, Object> containing channel name, function callback, timetoken.
     */
    private void _subscribe( HashMap<String, Object> args ) {
    	
    	String   channel = (String) args.get("channel");
        Callback callback = (Callback) args.get("callback");
        String   timetoken = (String) args.get("timetoken");
    	
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
                    if(this.CIPHER_KEY.length() > 0){
                    	// Decrypt Message
                    	PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                    	message = pc.decrypt(message);
                    }
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
    	HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("limit", limit);
        return history( args );
    }
    
    /**
     * History
     *
     * Load history from a channel.
     *
     * @param HashMap<String, Object> containing channel name, limit history count response.
     * @return JSONArray of history.
     */
    public JSONArray history( HashMap<String, Object> args ) {
        
    	String channel = (String) args.get("channel");
    	int limit = Integer.parseInt(args.get("limit").toString());
    	
    	List<String> url = new ArrayList<String>();

        url.add("history");
        url.add(this.SUBSCRIBE_KEY);
        url.add(channel);
        url.add("0");
        url.add(Integer.toString(limit));

        if (this.CIPHER_KEY.length() > 0) {
	        // Decrpyt Messages
        	PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
	        return pc.decryptJSONArray(_request(url));
        } else {
        	return _request(url);
        }
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
     * UUID
     *
     * 32 digit UUID generation at client side.
     *
     * @return String uuid.
     */
    public static String uuid() {
    	UUID uuid = UUID.randomUUID();
        return uuid.toString();
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
        Iterator<String> url_iterator = url_components.iterator();

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
            PubnubHttpRequest request = new PubnubHttpRequest(url.toString());
            FutureTask<String> task = new FutureTask<String>(request);
            Thread t = new Thread(task);
            t.start();
            try
            {
               json = task.get();
            }
            catch (Exception e)
            {
            	JSONArray jsono = new JSONArray();

                try { jsono.put("Failed to Concurrent HTTP Request."); }
                catch (Exception jsone) {}

                e.printStackTrace();
                System.out.println(e);

                return jsono;
            }
            
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

	private class PubnubHttpRequest implements Callable<String> {

		String url;
		
		public PubnubHttpRequest(String url){
			this.url = url;
		}
		
		@Override
		public String call() throws Exception {
			// Prepare request
			String     line    = "", json = "";
			HttpClient httpclient = new DefaultHttpClient();
			HttpUriRequest request = new HttpGet(url);
			request.setHeader("V", "3.1");
			request.setHeader("User-Agent", "Android");
			request.setHeader("Accept-Encoding", "gzip");

			// Execute request
			HttpResponse response;
			response = httpclient.execute(request);

	        HttpEntity entity = response.getEntity();
	        if (entity != null) {
	        	
	        	// A Simple JSON Response Read
	        	InputStream instream = entity.getContent();
	            BufferedReader reader = null;
	            
	        	// Gzip decoding
	        	Header contentEncoding = response.getFirstHeader("Content-Encoding");
	        	if (contentEncoding != null && contentEncoding.getValue().equalsIgnoreCase("gzip")) {
	        		reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(instream)));
	        	} else {
	        		reader = new BufferedReader(new InputStreamReader(instream));
	        	}
                
                // Read JSON Message
                while ((line = reader.readLine()) != null) { json += line; }
                reader.close();
	        }

			return json;
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
}
