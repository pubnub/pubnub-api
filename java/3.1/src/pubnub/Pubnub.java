package pubnub;

import com.ning.http.client.*;
import com.ning.http.client.AsyncHttpClientConfig.Builder;
import org.json.JSONArray;
import org.json.JSONObject;
import pubnub.crypto.PubnubCrypto;

import java.io.*;
import java.net.URLEncoder;
import java.util.*;
import java.util.concurrent.Future;
import java.util.zip.GZIPInputStream;

/**
 * PubNub 3.1 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package pubnub
 */
public class Pubnub {
    private String ORIGIN        = "pubsub.pubnub.com";
    private String PUBLISH_KEY   = "";
    private String SUBSCRIBE_KEY = "";
    private String SECRET_KEY    = "";
    private String CIPHER_KEY    = "";
    private boolean SSL          = false;
    private class ChannelStatus {
        String channel; 
        boolean connected, first;
    }
    private List<ChannelStatus> subscriptions;

    /**
     * PubNub 3.1 with Cipher Key
     *
     * Prepare PubNub State.
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
        this.CIPHER_KEY    = cipher_key;
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
        Object message= args.get("message");
        
        if(message instanceof JSONObject) {
            JSONObject obj=(JSONObject)message;
            if(this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                message = pc.encrypt(obj);
            } else {
            	message=obj;
            }
            //System.out.println();
        } else if(message instanceof String) {
            String obj=(String)message;
            if(this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                try {
                    message = pc.encrypt(obj);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                message=obj;
            }
            message="\""+message+"\"";
            
        }else if(message instanceof JSONArray) {
            JSONArray obj=(JSONArray)message;
            
            if(this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                message = pc.encryptJSONArray(obj);
            } else {
            	message=obj;
            }
            System.out.println();
        }

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
        String timetoken = (String) args.get("timetoken");
        Callback callback;

        // Validate Arguments
        if (args.get("callback") != null) {
            callback = (Callback) args.get("callback");
        } else {
            System.out.println("Invalid Callback.");
            return;
        }

        if (channel == null || channel.equals("")) {
        	callback.errorCallback(channel,"Invalid Channel.");
            return;
        }

        // Ensure Single Connection
        if (subscriptions != null && subscriptions.size() > 0) {
            boolean channel_exist = false;
            for (ChannelStatus it : subscriptions) {
                if(it.channel.equals(channel)) {
                    channel_exist = true;
                    break;
                }
            }
            if (!channel_exist) {
                ChannelStatus cs = new ChannelStatus();
                cs.channel = channel;
                cs.connected = true;
                subscriptions.add(cs);
            } else {
            	callback.errorCallback(channel,"Already Connected");
                return;
            }
        } else {
            // New Channel
            ChannelStatus cs = new ChannelStatus();
            cs.channel = channel;
            cs.connected = true;
            subscriptions = new ArrayList<Pubnub.ChannelStatus>();
            subscriptions.add(cs);
        }

        while (true) {
            try {
                // Build URL
                List<String> url = java.util.Arrays.asList(
                        "subscribe", this.SUBSCRIBE_KEY, channel, "0", timetoken
                        );

                // Stop Connection?
                boolean is_disconnect = false;
                for (ChannelStatus it : subscriptions) {
                    if (it.channel.equals(channel)) {
                        if(!it.connected) {
                        	subscriptions.remove(it);
                            callback.disconnectCallback(channel);
                            is_disconnect = true;
                            break;
                        }
                    }
                }
                if (is_disconnect)
                    return;

                // Wait for Message
                JSONArray response = _request(url);

                // Stop Connection?
                for (ChannelStatus it : subscriptions) {
                    if (it.channel.equals(channel)) {
                        if (!it.connected) {
                        	subscriptions.remove(it);
                        	callback.disconnectCallback(channel);
                            is_disconnect = true;
                            break;
                        }
                    }
                }

                if (is_disconnect)
                    return;

                // Problem?
                if (response == null || response.optInt(1) == 0) {
                	for (ChannelStatus it : subscriptions) {
                        if (it.channel.equals(channel)) {
                        	 if(it.connected && it.first){
                                 subscriptions.remove(it);
                                 callback.disconnectCallback(channel);
                             }else{
                                 subscriptions.remove(it);
                                 callback.errorCallback(channel,"Lost Network Connection");
                             }
                        }
                       
                    }
                    // Ensure Connected (Call Time Function)
                	boolean is_reconnected = false;
                    while(true) {
                    	double time_token = this.time();
                    	if (time_token == 0.0) {
                          
                            Thread.sleep(5000);
                        } else {
                        	  // Reconnect Callback
                        	 callback.reconnectCallback(channel);
                        	//this._subscribe(args);
                        	is_reconnected = true;
                        	break;
                        }
                    }
                    if(is_reconnected) {
                    	continue;
                    }
                } else {
                	for (ChannelStatus it : subscriptions) {
                        if (it.channel.equals(channel)) {
                            // Connect Callback
                            if (!it.first) {
                                it.first = true;
                                callback.connectCallback(channel);
                             
                                break;
                            }
                        }
                    }
                }

                JSONArray messages = response.optJSONArray(0);

                // Update TimeToken
                if (response.optString(1).length() > 0)
                    timetoken = response.optString(1);

                for ( int i = 0; messages.length() > i; i++ ) {
                    JSONObject message = messages.optJSONObject(i);
                    if(message != null) {

                        if(this.CIPHER_KEY.length() > 0){
                            // Decrypt Message
                            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                            message = pc.decrypt(message);
                        }
                        if(callback !=null)
                            callback.subscribeCallback(channel, message);
                    } else {

                        JSONArray arr = messages.optJSONArray(i);
                        if(arr != null) {
                            if(this.CIPHER_KEY.length() > 0) {
                                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                                arr=pc.decryptJSONArray(arr); ;
                            }
                            if(callback !=null)
                                callback.subscribeCallback(channel,arr);
                        } else {
                            String msgs=messages.getString(0);
                            if(this.CIPHER_KEY.length() > 0) {
                                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                                msgs=pc.decrypt(msgs); 
                            }
                            if(callback !=null)
                                callback.subscribeCallback(channel,msgs);
                        }
                    }
                }
            } catch (Exception e) {
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

        JSONArray response = _request(url);
        
        if (this.CIPHER_KEY.length() > 0) {
            // Decrpyt Messages
            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
            return pc.decryptJSONArray(response);
        } else {
            return response;
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
     * Unsubscribe
     *
     * Unsubscribe/Disconnect to channel.
     *
     * @param HashMap<String, Object> containing channel name.
     */
    public void unsubscribe( HashMap<String, Object> args ) {
        String channel = (String) args.get("channel");
        for (ChannelStatus it : subscriptions) {
            if(it.channel.equals(channel) && it.connected) {
                it.connected = false;
                it.first = false;
                break;
            }
        }
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
        String request_for = url_components.get(0);
        
        url.append(this.ORIGIN);

        // Generate URL with UTF-8 Encoding
        while (url_iterator.hasNext()) {
            try {
                String url_bit = (String) url_iterator.next();
                url.append("/").append(_encodeURIcomponent(url_bit));
            }
            catch(Exception e) {
                //e.printStackTrace();
                JSONArray jsono = new JSONArray();
                try { jsono.put("Failed UTF-8 Encoding URL."); }
                catch (Exception jsone) {}
                return jsono;
            }
        }
        
        AsyncHttpClient ahc = null;
        try {
            // Prepare Asynchronous HTTP Request
            Builder cb = new AsyncHttpClientConfig.Builder();
            cb.setRequestTimeoutInMs(310000);
            AsyncHttpClientConfig config = cb.build();
            ahc = new AsyncHttpClient(config);
            RequestBuilder rb = new RequestBuilder("GET");
            rb.setUrl(url.toString());
            rb.addHeader("V", "3.1");
            rb.addHeader("User-Agent", "Java");
            rb.addHeader("Accept-Encoding", "gzip");
            Request request = rb.build();

            //Execute Request
            Future<String> f = ahc.executeRequest(request, new AsyncCompletionHandler<String>() {

                @Override
                public String onCompleted(Response r) throws Exception {

                    String ce = r.getHeader("Content-Encoding");
                    InputStream resulting_is = null;
                    InputStream is = r.getResponseBodyAsStream();

                    if (ce != null && ce.equalsIgnoreCase("gzip")) {
                        // Decoding using 'gzip'
                    	
                        try {
							resulting_is = new GZIPInputStream(is);
						}catch (IOException e) {
							  resulting_is = is;
						}
                        catch (Exception e) {
                        	  resulting_is = is;
						}
                    }
                    else {
                        // Default (encoding is null OR 'identity')
                        resulting_is = is;
                    }

                    String line = "", json = "";
                    BufferedReader reader = new BufferedReader(new InputStreamReader(resulting_is));

                    // Read JSON Message
                    while ((line = reader.readLine()) != null) { json += line; }

                    reader.close();

                    return json;
                }
            });
            json = f.get();
            ahc.close();

        } catch (Exception e) {

        	// Response If Failed JSONP HTTP Request. 
            JSONArray jsono = new JSONArray();
            try {
            	if(request_for != null) {
            		if(request_for.equals("time")) {
            			jsono.put("0");
            		} else if(request_for.equals("history")) {
            			jsono.put("Error: Failed JSONP HTTP Request.");
            		} else if(request_for.equals("publish")) {
            			jsono.put("0");
            			jsono.put("Error: Failed JSONP HTTP Request.");
            		} else if(request_for.equals("subscribe")) {
            			jsono.put("0");
            			jsono.put("0");
            		} 
            	}
            }
            catch (Exception jsone) {}

            if(ahc != null) {
                ahc.close();
            }
            return jsono;
        }

        // Parse JSON String
        try { return new JSONArray(json); }
        catch (Exception e) {
            JSONArray jsono = new JSONArray();

            try { jsono.put("Error: Failed JSON Parsing."); }
            catch (Exception jsone) {}

            // Return Failure to Parse
            return jsono;
        }
    }
    
    private String _encodeURIcomponent(String s) {
        StringBuilder o = new StringBuilder();
        for (Character ch : s.toCharArray()) {
            if (isUnsafe(ch)) {
                o.append('%');
                o.append(toHex(ch / 16));
                o.append(toHex(ch % 16));
            }
            else o.append(encodeToUTF8(ch.toString()));
        }
        return o.toString();
    }

    private char toHex(int ch) {
        return (char)(ch < 10 ? '0' + ch : 'A' + ch - 10);
    }

    private boolean isUnsafe(char ch) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?ɂ顶".indexOf(ch) >= 0;
    }

    private String encodeToUTF8(String s) {
        try {
            String enc = URLEncoder.encode(s, "UTF-8").replace("+", "%20");
            return enc;
        } catch (UnsupportedEncodingException e) {

        }
        return s;
    }

}
