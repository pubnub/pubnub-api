package com.pubnub.api;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.net.URLEncoder;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Future;
import java.util.zip.GZIPInputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.Mac;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.ning.http.client.AsyncCompletionHandler;
import com.ning.http.client.AsyncHttpClient;
import com.ning.http.client.AsyncHttpClientConfig;
import com.ning.http.client.AsyncHttpClientConfig.Builder;
import com.ning.http.client.PerRequestConfig;
import com.ning.http.client.Request;
import com.ning.http.client.RequestBuilder;
import com.ning.http.client.Response;


/**
 * @author Pubnub
 *
 */
@SuppressWarnings("deprecation")
class PubnubHttpRequest {
    private Request request;
    private String[] errorsMessages;
    public PubnubHttpRequest(Request request, String[] errorsMessages){
        this.errorsMessages = errorsMessages;
        this.request = request;
    }
    public String[] errorMessages(){
        return this.errorsMessages;
    }
    public Request request(){
        return this.request;
    }
}


/**
 * Pubnub object facilitates querying channels for messages and listening on channels for presence/message events
 * @author Pubnub
 * 
 */

public class Pubnub {
    private String ORIGIN = "pubsub.pubnub.com";
    private String PUBLISH_KEY = "";
    private String SUBSCRIBE_KEY = "";
    private String SECRET_KEY = "";
    private String CIPHER_KEY = "";
    private boolean SSL = false;
    private String sessionUUID = "";
    private String parameters = "";
    private AsyncHttpClient ahc = null;
    private RequestBuilder rb = null;
    private int PUBNUB_WEBREQUEST_CALLBACK_INTERVAL = 310000;
    private int PUBNUB_NETWORK_CHECK_RETRIES = 50;
    private int PUBNUB_WEBREQUEST_RETRY_INTERVAL = 10000;
    private int PUBNUB_FAST_WEBREQUEST_TIMEOUT = 5000;
    private int PUBNUB_DEFAULT_CONN_TIMEOUT = 10000;
    
    /** Sets wait time for Presence/Subscribe API
     * @param interval Time interval in milliseconds for which the API's like Presence and Subscribe will block
     */
    public void setWebRequestCallbackInterval(int interval){
        this.PUBNUB_WEBREQUEST_CALLBACK_INTERVAL = interval;
        this.init(this.PUBLISH_KEY, this.SUBSCRIBE_KEY, this.SECRET_KEY, this.CIPHER_KEY, this.SSL);
    }
    /**
     *  Sets number of retries to be made for network availability check
     * @param count No of times attempt will be made to check network availability
     */
    public void setNetworkCheckRetriesCount(int count) {
        this.PUBNUB_NETWORK_CHECK_RETRIES = count;
    }
    /**
     *  Sets time interval between consecutive network availability checks
     * @param interval Time interval in milliseconds between each attempt for network connectivity check
     */
    public void setWebRequestRetryInterval(int interval) {
        this.PUBNUB_WEBREQUEST_RETRY_INTERVAL = interval;;
    }
    /**
     *  Sets timeout values for publish, history, detailedHistory, time, here_now
     * @param timeout timeout value in milliseconds for api's publish, history, here_now, detailedHistory, time
     */
    public void setFastWebRequestTimeout(int timeout) {
        this.PUBNUB_FAST_WEBREQUEST_TIMEOUT = timeout;
    }
    /** Sets the timeout value for TCP connections made by API to Pubnub Servers
     * @param timeout timeout value in milliseconds for tcp connection attempt.
     */
    public void setConnectionTimeout(int timeout) {
        this.PUBNUB_DEFAULT_CONN_TIMEOUT = timeout;
        this.init(this.PUBLISH_KEY, this.SUBSCRIBE_KEY, this.SECRET_KEY, this.CIPHER_KEY, this.SSL);
    }
    
    
    /** 
     * Returns Time interval in milliseconds for which the API's like Presence and Subscribe will block
     * @return Time interval in milliseconds for which the API's like Presence and Subscribe will block 
     */
    public int getWebRequestCallbackInterval(){
        return this.PUBNUB_WEBREQUEST_CALLBACK_INTERVAL;
    }
    /** 
     * Returns No of times attempt will be made to check network availability
     * @return No of times attempt will be made to check network availability 
     */    
    public int getNetworkCheckRetriesCount() {
        return this.PUBNUB_NETWORK_CHECK_RETRIES;
    }
    /** 
     * Returns time interval in milliseconds between each attempt for network connectivity check
     * @return Time interval in milliseconds between each attempt for network connectivity check 
     */
    public int getWebRequestRetryInterval() {
        return this.PUBNUB_WEBREQUEST_RETRY_INTERVAL;
    }
    /** 
     * Returns timeout value in milliseconds for api's publish, history, here_now, detailedHistory, uuid, time
     * @return timeout value in milliseconds for api's publish, history, here_now, detailedHistory, uuid, time
     */    
    public int getFastWebRequestTimeout() {
        return this.PUBNUB_FAST_WEBREQUEST_TIMEOUT;
    }
    /** 
     * Returns the timeout value for TCP connections made by api
     * @return the timeout value for TCP connections made by api 
     */    
    public int getConnectionTimeout() {
        return this.PUBNUB_DEFAULT_CONN_TIMEOUT;
    }

    private Request getRequest(List<String> url_components) {
        return getRequest(url_components, 0);
    }
        
    @SuppressWarnings({ "deprecation"})
    private Request getRequest(List<String> url_components, int requestTimeout) {
        StringBuilder url = new StringBuilder();
        Iterator<String> url_iterator = url_components.iterator();
        String request_for = url_components.get(0);
        String request_type = url_components.get(1);

        url.append(this.ORIGIN);

        // Generate URL with UTF-8 Encoding
        while (url_iterator.hasNext()) {
            String url_bit = (String) url_iterator.next();
            url.append("/").append(_encodeURIcomponent(url_bit));
        }
        if (request_for.equals("subscribe") || request_for.equals("presence"))
            url.append("?uuid=").append(this.sessionUUID);

        if (request_for.equals("v2") && request_type.equals("history"))
            url.append(parameters);
        
        rb = new RequestBuilder("GET");
        
        rb.addHeader("V", "3.3");
        rb.addHeader("User-Agent", "Java");
        rb.addHeader("Accept-Encoding", "gzip");
        rb.setUrl(url.toString());
        
        if (requestTimeout > 0) {
               PerRequestConfig prc = new PerRequestConfig();
               prc.setRequestTimeoutInMs(requestTimeout);
               rb.setPerRequestConfig(prc);
         }
        return rb.build();
    }
    
    protected void finalize() {
        if (ahc != null)
            ahc.close();
    }

    public String sessionUUID() {
        return sessionUUID;
    }

    private class ChannelStatus {
        String channel;
        boolean connected, first;
    }

    private HashMap<String, ChannelStatus> subscriptions;

    /**
     * 
     * Constructor for Pubnub Class
     * 
     * @param publish_key Publish Key
     * @param subscribe_key Subscribe Key
     * @param secret_key Secret Key
     * @param cipher_key Cipher Key
     * @param ssl_on SSL enabled ?
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            String cipher_key, boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
    }

    /**
     * 
     * Constructor for Pubnub Class
     * 
     * @param publish_key Publish Key
     * @param subscribe_key Subscribe Key
     * @param secret_key Secret Key
     * @param ssl_on SSL enabled ?
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, "", ssl_on);
    }

    /**
     * 
     * Constructor for Pubnub Class
     * 
     * @param publish_key Publish Key
     * @param subscribe_key Subscribe Key
     */
    public Pubnub(String publish_key, String subscribe_key) {
        this.init(publish_key, subscribe_key, "", "", false);
    }

    /**
     * 
     * Constructor for Pubnub Class
     * 
     * @param publish_key Publish Key
     * @param subscribe_key Subscribe Key
     * @param secret_key Secret Key
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key) {
        this.init(publish_key, subscribe_key, secret_key, "", false);
    }

    /**

     * Initialize PubNub Object State.
     * 
     * @param publish_key
     * @param subscribe_key
     * @param secret_key
     * @param cipher_key
     * @param ssl_onn
     */
    private void init(String publish_key, String subscribe_key,
            String secret_key, String cipher_key, boolean ssl_on) {
        this.PUBLISH_KEY = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY = secret_key;
        this.CIPHER_KEY = cipher_key;
        this.SSL = ssl_on;

        if (this.sessionUUID.equals(""))
            sessionUUID = UUID.randomUUID().toString();
        // SSL On?
        if (this.SSL) {
            this.ORIGIN = "https://" + this.ORIGIN;
        } else {
            this.ORIGIN = "http://" + this.ORIGIN;
        }
        Builder cb = new AsyncHttpClientConfig.Builder();
        cb.setRequestTimeoutInMs(PUBNUB_WEBREQUEST_CALLBACK_INTERVAL);
        cb.setConnectionTimeoutInMs(PUBNUB_DEFAULT_CONN_TIMEOUT);
        ahc = new AsyncHttpClient(cb.build());
    }

    /**
     * getResponseByUrl
     * 
     * Get response by url.
     * 
     * @param phr PubnubHttpRequest 
     * @param decrypt Decryption enabled ?
     */
    private JSONArray getResponseByUrl(PubnubHttpRequest phr, boolean decrypt) {
        return _getResponseByUrl(phr, decrypt, -1);
    }

    /**
     * Get response by url.
     * 
     * @param phr PubnubHttpRequest
     * @param index
     * 
     */
    private JSONArray getResponseByUrl(PubnubHttpRequest phr, int index) {
        return _getResponseByUrl(phr, true, index);
    }

    /**
     * Get response by url.
     * @param phr PubnubHttpRequest
     */
    private JSONArray getResponseByUrl(PubnubHttpRequest phr) {
        return _getResponseByUrl(phr, true, -1);
    }

    /*
     * Get response by url.
     * 
     * @param phr PubnubHttpRequest 
     * @param decrypt Decryption enabled ?
     * @param index
     */
    private JSONArray _getResponseByUrl(PubnubHttpRequest phr, boolean decrypt,
            int index) {
        JSONArray response = _request(phr);

        if (this.CIPHER_KEY.length() > 0 && decrypt) {
            // Decrypt Messages
            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
            if (index < 0)
                return pc.decryptJSONArray(response);
            else {
                try {
                    response.put(index, pc
                            .decryptJSONArray((JSONArray) response.get(index)));
                } catch (JSONException e) {
                    return null;
                }
                return response;
            }
        } else {
            return response;
        }
    }

    /**
     * Send a message to a channel.
     * 
     * @param channel Channel name
     * @param message JSONObject to be published
     * @return JSONArray of response
     */
    public JSONArray publish(String channel, JSONObject message) {
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", message);
        return publish(args, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    
    /**
     * Send a message to a channel.
     * 
     * @param channel Channel name
     * @param message JSONObject of message to be published
     * @param requestTimeout timeout value in milliseconds for this request
     * @return JSONArray of response
     */
    public JSONArray publish(String channel, JSONObject message, int requestTimeout) {
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", message);
        return publish(args, requestTimeout);
    }

    /**
     * Send a message to a channel.
     * 
     * @param args HashMap of <String, Object> containing channel name, message.
     * @param requestTimeout timeout value in milliseconds for this request
     * @return JSONArray of response
     */
    private JSONArray publish(HashMap<String, Object> args, int requestTimeout) {

        String channel = (String) args.get("channel");
        Object message = args.get("message");
        String[] errorMessages = {"0", "Error: Failed JSONP HTTP Request" };

        if (message instanceof JSONObject) {
            JSONObject obj = (JSONObject) message;
            if (this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                message = pc.encrypt(obj);
            } else {
                message = obj;
            }
        } else if (message instanceof String) {
            String obj = (String) message;
            if (this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                try {
                    message = pc.encrypt(obj);
                } catch (Exception e) {
                    return new JSONArray().put(1).put(
                    "Message Encryption Error");
                }
            } else {
                message = obj;
            }
            message = "\"" + message + "\"";

        } else if (message instanceof JSONArray) {
            JSONArray obj = (JSONArray) message;

            if (this.CIPHER_KEY.length() > 0) {
                // Encrypt Message
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                message = pc.encryptJSONArray(obj);
            } else {
                message = obj;
            }
        }

        // Generate String to Sign
        String signature = "0";

        if (this.SECRET_KEY.length() > 0) {
            StringBuilder string_to_sign = new StringBuilder();
            string_to_sign.append(this.PUBLISH_KEY).append('/')
            .append(this.SUBSCRIBE_KEY).append('/')
            .append(this.SECRET_KEY).append('/').append(channel)
            .append('/').append(message.toString());

            // Sign Message
            signature = PubnubCrypto.getHMacSHA256(this.SECRET_KEY,
                    string_to_sign.toString());
        }

        // Build URL
        String[] urlargs = { "publish", this.PUBLISH_KEY, this.SUBSCRIBE_KEY,
                signature, channel, "0", message.toString() };
    
        return _request( new PubnubHttpRequest(getRequest( Arrays.asList(urlargs), requestTimeout), errorMessages));
    }

    /**
     * 
     * Listen for a message on a channel.
     * 
     * @param channel Channel name for subscribing
     * @param callback Callback
     * @exception PubnubException Throws PubnubException if Callback is null
     */
    public void subscribe(String channel, Callback callback)
    throws PubnubException {
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("callback", callback);
        subscribe(args);
    }

    /**
     * 
     * Listen for a message on a channel.
     * 
     * @param args HashMap <String, Object> containing channel name, function callback.
     * @exception PubnubException Throws PubnubException if Callback is missing
     */
    private void subscribe(HashMap<String, Object> args) throws PubnubException {
        args.put("timetoken", "0");
        this._subscribe(args);
    }

    /**
     * Subscribe - Private Interface
     * 
     * Patch provided by petereddy on GitHub
     * 
     * @param args HashMap
     *            <String, Object> containing channel name, function callback,
     *            timetoken.
     */
    private void _subscribe(HashMap<String, Object> args)
    throws PubnubException {

        String[] errorMessages = {"0", "0"}; 
        String channel = (String) args.get("channel");
        String timetoken = (String) args.get("timetoken");
        Callback callback;

        // Validate Arguments
        if (args.get("callback") != null) {
            callback = (Callback) args.get("callback");
        } else {
            throw new PubnubException("Invalid Callback");
        }

        if (channel == null || channel.equals("")) {
            callback.errorCallback(channel, "Invalid Channel.");
            return;
        }

        // Ensure Single Connection
        if (subscriptions != null && subscriptions.size() > 0) {
            if (subscriptions.get(channel) == null) {
                ChannelStatus cs = new ChannelStatus();
                cs.channel = channel;
                cs.connected = true;
                subscriptions.put(cs.channel, cs);
            } else {
                callback.errorCallback(channel, "Already Connected");
                return;
            }
        } else {
            // New Channel
            ChannelStatus cs = new ChannelStatus();
            cs.channel = channel;
            cs.connected = true;
            subscriptions = new HashMap<String, Pubnub.ChannelStatus>();
            subscriptions.put(cs.channel, cs);
        }

        while (true) {
            try {
                // Build URL
                List<String> url = java.util.Arrays.asList("subscribe",
                        this.SUBSCRIBE_KEY, channel, "0", timetoken);

                // Stop Connection?
                boolean is_disconnect = false;

                if (subscriptions.get(channel) != null
                        && !subscriptions.get(channel).connected) {
                    subscriptions.remove(channel);
                    callback.disconnectCallback(channel);
                    is_disconnect = true;
                }
                if (is_disconnect)
                    return;

                // Wait for Message
                JSONArray response = _request(new PubnubHttpRequest(getRequest(url), errorMessages));
                // Stop Connection?

                if (subscriptions.get(channel) != null
                        && !subscriptions.get(channel).connected) {
                    subscriptions.remove(channel);
                    callback.disconnectCallback(channel);
                    is_disconnect = true;
                }

                if (is_disconnect)
                    return;

                // Problem?
                if (response == null || response.optInt(1) == 0) {
                    ChannelStatus it = null;
                    if ((it = subscriptions.get(channel)) != null) {
                        if (it.connected && it.first) {
                            subscriptions.remove(it.channel);
                            callback.disconnectCallback(channel);
                        } else {
                            subscriptions.remove(it.channel);
                            callback.errorCallback(channel,
                            "Lost Network Connection");
                        }
                    }
                    // Ensure Connected (Call Time Function)
                    boolean is_reconnected = false;
                    int retries = 0;
                    while (true && retries < PUBNUB_NETWORK_CHECK_RETRIES) {
                        double time_token = this.time();
                        retries++;
                        if (time_token == 0.0) {
                            Thread.sleep(PUBNUB_WEBREQUEST_RETRY_INTERVAL);
                        } else {
                            // Reconnect Callback
                            callback.reconnectCallback(channel);
                            // this._subscribe(args);
                            is_reconnected = true;
                            break;
                        }
                    }
                    if (is_reconnected) {
                        continue;
                    } else {
                        HashMap<String, Object> args1 = new HashMap<String, Object>(1);
                        args.put("channel", channel);
                        this.unsubscribe(args1);
                        callback.errorCallback(channel,
                                " Unsubscribed after " + String.valueOf(PUBNUB_NETWORK_CHECK_RETRIES) + "failed retries");
                        return;
                    }
                } else {
                    ChannelStatus it = null;
                    if ((it = subscriptions.get(channel)) != null) {
                        // Connect Callback
                        if (!it.first) {
                            it.first = true;
                            callback.connectCallback(channel);
                        }
                    }
                }
                JSONArray messages = response.optJSONArray(0);

                // Update TimeToken
                if (response.optString(1).length() > 0)
                    timetoken = response.optString(1);

                for (int i = 0; messages.length() > i; i++) {
                    JSONObject message = messages.optJSONObject(i);
                    if (message != null) {

                        if (this.CIPHER_KEY.length() > 0) {
                            // Decrypt Message
                            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                            message = pc.decrypt(message);
                        }
                        if (callback != null) {
                            if (!callback.successCallback(channel, message))
                                return;
                        }
                    } else {

                        JSONArray arr = messages.optJSONArray(i);
                        if (arr != null) {
                            if (this.CIPHER_KEY.length() > 0) {
                                PubnubCrypto pc = new PubnubCrypto(
                                        this.CIPHER_KEY);
                                arr = pc.decryptJSONArray(arr);
                                ;
                            }
                            if (callback != null)
                                if (!callback.successCallback(channel, arr))
                                    return;
                        } else {
                            String msgs = messages.getString(0);
                            if (this.CIPHER_KEY.length() > 0) {
                                PubnubCrypto pc = new PubnubCrypto(
                                        this.CIPHER_KEY);
                                msgs = pc.decrypt(msgs);
                            }
                            if (callback != null)
                                if (!callback.successCallback(channel, msgs))
                                    return;
                        }
                    }
                }
            } catch (Exception e) {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                }
            }
        }
    }

    /**
     * 
     * Listen for presence of subscribers on a channel
     * 
     * @param channel Name of the channel on which to listen for join/leave i.e. presence events
     * @param callback Callback 
     * @exception PubnubException Throws PubnubException if Callback is null
     */
    public void presence(String channel, Callback callback)
    throws PubnubException {
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel + "-pnpres");
        args.put("callback", callback);
        subscribe(args);
    }

    
    /**
     * Read presence information from a channel
     * @param channel
     * @return JSONArray of uuid's currently subscribing to a channel
     */
    public JSONArray here_now(String channel) {
        return here_now(channel, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read presence information from a channel
     * 
     * @param channel Channel name
     * @param requestTimeout timeout in milliseconds for this request
     * @return Array of uuid's currently subscribing to a channel
     */
    public JSONArray here_now(String channel, int requestTimeout) {
        String[] errorMessages = {};
        String[] urlargs = { "v2", "presence", "sub_key", this.SUBSCRIBE_KEY,
                "channel", channel };

        return getResponseByUrl( new PubnubHttpRequest(getRequest(Arrays.asList(urlargs), requestTimeout), errorMessages)  , false);
    }

    /**
     * 
     * Read history from a channel.
     * 
     * @param channel Channel Name
     * @param limit Upper limit on number of messages in response
     * @param requestTimeout timeout in milliseconds for this request
     * @return JSONArray of message history on a channel.
     */
    public JSONArray history(String channel, int limit, int requestTimeout) {
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("limit", limit);
        return history(args,requestTimeout);
    }
    /**
     * 
     * Read history from a channel.
     * 
     * @param channel Channel Name
     * @param limit Upper limit on number of messages in response.
     * @return JSONArray of message history on a channel.
     */
    public JSONArray history(String channel, int limit) {
        return history(channel, limit, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }

    /**
     * 
     * Read history from a channel.
     * 
     * @param args HashMap of <String, Object> containing channel name, limit history count
     * @param requestTimeout timeout in milliseconds for this request
     * @return JSONArray of history.
     */
    private JSONArray history(HashMap<String, Object> args, int requestTimeout) {

        String channel = (String) args.get("channel");
        String[] errorMessages = {"0", "Error: Failed JSONP HTTP Request" };
        int limit = Integer.parseInt(args.get("limit").toString());

        String[] urlargs = { "history", this.SUBSCRIBE_KEY, channel, "0",
                Integer.toString(limit) };

        return getResponseByUrl(new PubnubHttpRequest(getRequest(Arrays.asList(urlargs), requestTimeout), errorMessages));
    }

    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param end End time
     * @param count Upper limit on number of messages to be returned
     * @param reverse True if messages need to be in reverse order
     * @param requestTimeout Timeout value in milliseconds for this request
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, long end,
            int count, Boolean reverse, int requestTimeout) {
        String[] errorMessages = {"0", "Error: Failed JSONP HTTP Request" };
        parameters = "";
        if (count == -1)
            count = 100;

        parameters = "?count=" + count;
        parameters = parameters + "&" + "reverse=" + reverse.toString().toLowerCase();

        if (start != -1)
            parameters = parameters + "&" + "start="
            + Long.toString(start).toLowerCase();
        if (end != -1)
            parameters = parameters + "&" + "end="
            + Long.toString(end).toLowerCase();

        String[] urlargs = { "v2", "history", "sub-key", this.SUBSCRIBE_KEY,
                "channel", channel };

        return getResponseByUrl(new PubnubHttpRequest(getRequest(Arrays.asList(urlargs), requestTimeout), errorMessages), 0);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param end End time
     * @param count Upper limit on number of messages to be returned
     * @param reverse True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, long end,
            int count, Boolean reverse) {
        return detailedHistory(channel, start, end, count, reverse, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param reverse True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, boolean reverse) {
        return detailedHistory(channel, start, -1, -1, reverse, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param reverse True if messages need to be in reverse order
     * @param requestTimeout Timeout value in milliseconds for this request
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, boolean reverse, int requestTimeout) {
        return detailedHistory(channel, start, -1, -1, reverse, requestTimeout);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param end End time
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, long end) {
        return detailedHistory(channel, start, end, -1, false, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    
    public JSONArray detailedHistory(String channel, long start, long end, int requestTime) {
        return detailedHistory(channel, start, end, -1, false, requestTime);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param end End time
     * @param reverse True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, long end,
            boolean reverse) {
        return detailedHistory(channel, start, end, -1, reverse, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param start Start time 
     * @param end End time
     * @param reverse True if messages need to be in reverse order
     * @param requestTimeout Timeout value in milliseconds for this request
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, long start, long end,
            boolean reverse, int requestTimeout) {
        return detailedHistory(channel, start, end, -1, reverse, requestTimeout);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param count Upper limit on number of messages to be returned
     * @param reverse True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, int count, boolean reverse) {
        return detailedHistory(channel, -1, -1, count, reverse, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param count Upper limit on number of messages to be returned
     * @param reverse True if messages need to be in reverse order
     * @param requestTimeout Timeout value in milliseconds for this request
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, int count, boolean reverse, int requestTimeout) {
        return detailedHistory(channel, -1, -1, count, reverse, requestTimeout);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param reverse True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public JSONArray detailedHistory(String channel, boolean reverse) {
        return detailedHistory(channel, -1, -1, -1, reverse, PUBNUB_FAST_WEBREQUEST_TIMEOUT);
    }
    /**
     * 
     * Read DetailedHistory for a channel.
     * @param channel Channel name for which detailed history is required
     * @param reverse True if messages need to be in reverse order
     * @param requestTimeout Timeout value in milliseconds for this request
     * @return JSONArray of detailed history.
     */    
    public JSONArray detailedHistory(String channel, boolean reverse, int requestTimeout) {
        return detailedHistory(channel, -1, -1, -1, reverse, requestTimeout);
    }

    /**
     * Read current time from PubNub Cloud.
     * 
     * @return current timestamp.
     */
    public double time() {
        List<String> url = new ArrayList<String>();
        String[] errorMessages = {"0"};
        url.add("time");
        url.add("0");

        JSONArray response = _request( new PubnubHttpRequest(getRequest(url,PUBNUB_FAST_WEBREQUEST_TIMEOUT), errorMessages));

        return response.optDouble(0);
    }

    /**
     * Get 32 digit UUID generation at client side.
     * 
     * @return uuid.
     */
    public static String uuid() {
        UUID uuid = UUID.randomUUID();
        return uuid.toString();
    }

    /**
     * Unsubscribe/Disconnect from channel.
     * 
     * @param args HashMap of <String, Object> containing channel name.
     */
    public void unsubscribe(HashMap<String, Object> args) {
        String channel = (String) args.get("channel");
        ChannelStatus it = null;
        if ((it = subscriptions.get(channel)) != null && it.connected == true) {
            it.connected = false;
            it.first = false;
        }
    }
    

    /**
     * @param List
     *            <String> request of url directories.
     * @param int request timeout in milliseconds
     * @return JSONArray from JSON response.
     */
    private JSONArray _request(PubnubHttpRequest phr) {
        String json = "";
 
        try {
            // Execute Request
            Future<String> f = ahc.executeRequest(phr.request(),
                    new AsyncCompletionHandler<String>() {

                @Override
                public String onCompleted(Response r) throws Exception {

                    String ce = r.getHeader("Content-Encoding");
                    InputStream resulting_is = null;
                    InputStream is = r.getResponseBodyAsStream();

                    if (ce != null && ce.equalsIgnoreCase("gzip")) {
                        // Decoding using 'gzip'

                        try {
                            resulting_is = new GZIPInputStream(is);
                        } catch (IOException e) {
                            resulting_is = is;
                        } catch (Exception e) {
                            resulting_is = is;
                        }
                    } else {
                        // Default (encoding is null OR 'identity')
                        resulting_is = is;
                    }

                    String line = "", json = "";
                    BufferedReader reader = new BufferedReader(
                            new InputStreamReader(resulting_is, "UTF8"));

                    // Read JSON Message
                    while ((line = reader.readLine()) != null) {
                        json += line;
                    }

                    reader.close();
                    return json;
                }
            });
            json = f.get();

        }
        catch (ConnectException e) {
            return new JSONArray().put("0").put("0").put("Network Connect Error");
        }
        catch (SocketTimeoutException e) {
            return new JSONArray().put("0").put("1").put("Network Connect Error");
        }
        catch (Exception e) {
            // Response If Failed JSONP HTTP Request.
            JSONArray jsono = new JSONArray();
            for (String s: phr.errorMessages()) {
                jsono.put(s);
            }
            return jsono;
        }

        // Parse JSON String
        if (json.contains("uuids")) {
            return new JSONArray().put(json);
        }
        try {
            return new JSONArray(json);
        } catch (JSONException e) {
            return new JSONArray().put("Error: Failed JSON Parsing.");
        }
    }

    private String _encodeURIcomponent(String s) {
        StringBuilder o = new StringBuilder();
        for (Character ch : s.toCharArray()) {
            if (isUnsafe(ch)) {
                o.append('%');
                o.append(toHex(ch / 16));
                o.append(toHex(ch % 16));
            } else
                o.append(encodeToUTF8(ch.toString()));
        }
        return o.toString();
    }

    private char toHex(int ch) {
        return (char) (ch < 10 ? '0' + ch : 'A' + ch - 10);
    }

    private boolean isUnsafe(char ch) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".indexOf(ch) >= 0;
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

class Base64Encoder {

    // Mapping table from 6-bit nibbles to Base64 characters.
    private static char[] map1 = new char[64];
    static {
        int i = 0;
        for (char c = 'A'; c <= 'Z'; c++)
            map1[i++] = c;
        for (char c = 'a'; c <= 'z'; c++)
            map1[i++] = c;
        for (char c = '0'; c <= '9'; c++)
            map1[i++] = c;
        map1[i++] = '+';
        map1[i++] = '/';
    }

    // Mapping table from Base64 characters to 6-bit nibbles.
    private static byte[] map2 = new byte[128];
    static {
        for (int i = 0; i < map2.length; i++)
            map2[i] = -1;
        for (int i = 0; i < 64; i++)
            map2[map1[i]] = (byte) i;
    }

    /**
     * Encodes a string into Base64 format. No blanks or line breaks are
     * inserted.
     * 
     * @param s
     *            a String to be encoded.
     * @return A String with the Base64 encoded data.
     */
    public static String encodeString(String s) {
        return new String(encode(s.getBytes()));
    }

    /**
     * Encodes a byte array into Base64 format. No blanks or line breaks are
     * inserted.
     * 
     * @param in
     *            an array containing the data bytes to be encoded.
     * @return A character array with the Base64 encoded data.
     */
    public static char[] encode(byte[] in) {
        return encode(in, in.length);
    }

    /**
     * Encodes a byte array into Base64 format. No blanks or line breaks are
     * inserted.
     * 
     * @param in
     *            an array containing the data bytes to be encoded.
     * @param iLen
     *            number of bytes to process in <code>in</code>.
     * @return A character array with the Base64 encoded data.
     */
    public static char[] encode(byte[] in, int iLen) {
        int oDataLen = (iLen * 4 + 2) / 3; // output length without padding
        int oLen = ((iLen + 2) / 3) * 4; // output length including padding
        char[] out = new char[oLen];
        int ip = 0;
        int op = 0;
        while (ip < iLen) {
            int i0 = in[ip++] & 0xff;
            int i1 = ip < iLen ? in[ip++] & 0xff : 0;
            int i2 = ip < iLen ? in[ip++] & 0xff : 0;
            int o0 = i0 >>> 2;
            int o1 = ((i0 & 3) << 4) | (i1 >>> 4);
            int o2 = ((i1 & 0xf) << 2) | (i2 >>> 6);
            int o3 = i2 & 0x3F;
            out[op++] = map1[o0];
            out[op++] = map1[o1];
            out[op] = op < oDataLen ? map1[o2] : '=';
            op++;
            out[op] = op < oDataLen ? map1[o3] : '=';
            op++;
        }
        return out;
    }

    /**
     * Decodes a string from Base64 format.
     * 
     * @param s
     *            a Base64 String to be decoded.
     * @return A String containing the decoded data.
     * @throws IllegalArgumentException
     *             if the input is not valid Base64 encoded data.
     */
    public static String decodeString(String s) {
        return new String(decode(s));
    }

    /**
     * Decodes a byte array from Base64 format.
     * 
     * @param s
     *            a Base64 String to be decoded.
     * @return An array containing the decoded data bytes.
     * @throws IllegalArgumentException
     *             if the input is not valid Base64 encoded data.
     */
    public static byte[] decode(String s) {
        return decode(s.toCharArray());
    }

    /**
     * Decodes a byte array from Base64 format. No blanks or line breaks are
     * allowed within the Base64 encoded data.
     * 
     * @param in
     *            a character array containing the Base64 encoded data.
     * @return An array containing the decoded data bytes.
     * @throws IllegalArgumentException
     *             if the input is not valid Base64 encoded data.
     */
    public static byte[] decode(char[] in) {
        int iLen = in.length;
        if (iLen % 4 != 0)
            throw new IllegalArgumentException(
            "Length of Base64 encoded input string is not a multiple of 4.");
        while (iLen > 0 && in[iLen - 1] == '=')
            iLen--;
        int oLen = (iLen * 3) / 4;
        byte[] out = new byte[oLen];
        int ip = 0;
        int op = 0;
        while (ip < iLen) {
            int i0 = in[ip++];
            int i1 = in[ip++];
            int i2 = ip < iLen ? in[ip++] : 'A';
            int i3 = ip < iLen ? in[ip++] : 'A';
            if (i0 > 127 || i1 > 127 || i2 > 127 || i3 > 127)
                throw new IllegalArgumentException(
                "Illegal character in Base64 encoded data.");
            int b0 = map2[i0];
            int b1 = map2[i1];
            int b2 = map2[i2];
            int b3 = map2[i3];
            if (b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0)
                throw new IllegalArgumentException(
                "Illegal character in Base64 encoded data.");
            int o0 = (b0 << 2) | (b1 >>> 4);
            int o1 = ((b1 & 0xf) << 4) | (b2 >>> 2);
            int o2 = ((b2 & 3) << 6) | b3;
            out[op++] = (byte) o0;
            if (op < oLen)
                out[op++] = (byte) o1;
            if (op < oLen)
                out[op++] = (byte) o2;
        }
        return out;
    }

    /**
     * This class is not instantiate.
     */
    private Base64Encoder() {
    }
}

/**
 * PubNub 3.2 Cryptography
 * 
 */

class PubnubCrypto {

    private final String CIPHER_KEY;

    public PubnubCrypto(String CIPHER_KEY) {
        this.CIPHER_KEY = CIPHER_KEY;
    }

    /**
     * Encrypt
     * 
     * @param JSONObject
     *            Message to encrypt
     * @return JSONObject as Encrypted message
     */
    @SuppressWarnings("unchecked")
    public JSONObject encrypt(JSONObject message) {
        try {
            JSONObject message_encrypted = new JSONObject();
            Iterator<String> it = message.keys();

            while (it.hasNext()) {
                String key = it.next();
                String val = message.getString(key);
                message_encrypted.put(key, encrypt(val));
            }
            return message_encrypted;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Decrypt
     * 
     * @param JSONObject
     *            Encrypted message
     * @return JSONObject Message decrypted
     */
    @SuppressWarnings("unchecked")
    public JSONObject decrypt(JSONObject message_encrypted) {
        try {
            JSONObject message_decrypted = new JSONObject();
            Iterator<String> it = message_encrypted.keys();

            while (it.hasNext()) {
                String key = it.next();
                String encrypted_str = message_encrypted.getString(key);
                String decrypted_str = decrypt(encrypted_str);
                message_decrypted.put(key, decrypted_str);
            }
            return message_decrypted;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Encrypt JSONArray
     * 
     * @param JSONArray
     *            - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray encryptJSONArray(JSONArray jsona_arry) {
        try {
            JSONArray jsona_decrypted = new JSONArray();

            for (int i = 0; i < jsona_arry.length(); i++) {
                Object o = jsona_arry.get(i);
                if (o != null) {
                    if (o instanceof JSONObject) {
                        jsona_decrypted.put(i, encrypt((JSONObject) o));
                    } else if (o instanceof JSONArray) {
                        jsona_decrypted.put(i, encryptJSONArray((JSONArray) o));
                    } else if (o instanceof String) {
                        jsona_decrypted.put(i, encrypt(o.toString()));
                    }
                }
            }

            return jsona_decrypted;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Decrypt JSONArray
     * 
     * @param JSONArray
     *            - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray decryptJSONArray(JSONArray jsona_encrypted) {
        try {
            JSONArray jsona_decrypted = new JSONArray();

            for (int i = 0; i < jsona_encrypted.length(); i++) {
                Object o = jsona_encrypted.get(i);
                if (o != null) {
                    if (o instanceof JSONObject) {
                        jsona_decrypted.put(i, decrypt((JSONObject) o));
                    } else if (o instanceof JSONArray) {
                        jsona_decrypted.put(i, decryptJSONArray((JSONArray) o));
                    } else if (o instanceof String) {
                        jsona_decrypted.put(i, decrypt(o.toString()));
                    }
                }
            }

            return jsona_decrypted;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Encrypt
     * 
     * @param String
     *            plain text to encrypt
     * @return String cipher text
     * @throws Exception
     */
    public String encrypt(String plain_text) throws Exception {
        byte[] out = transform(true, plain_text.getBytes());
        return new String(Base64Encoder.encode(out));
    }

    /**
     * Decrypt
     * 
     * @param String
     *            cipherText
     * @return String
     * @throws Exception
     */
    public String decrypt(String cipher_text) throws Exception {
        byte[] out = transform(false, Base64Encoder.decode(cipher_text));
        return new String(out).trim();
    }

    /**
     * AES Encryption
     * 
     * @param boolean encrypt_or_decrypt ENCRYPT/DECRYPT mode
     * @param ByteArray
     *            input_bytes
     * @return ByteArray
     * @throws Exception
     */
    private byte[] transform(boolean encrypt_or_decrypt, byte[] input_bytes)
    throws Exception {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] iv_bytes = "0123456789012345".getBytes();
        byte[] key_bytes = md5(this.CIPHER_KEY);

        SecretKeySpec key = new SecretKeySpec(key_bytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv_bytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

        if (encrypt_or_decrypt) {
            cipher.init(Cipher.ENCRYPT_MODE, key, ivSpec);
            ByteArrayInputStream b_in = new ByteArrayInputStream(input_bytes);
            CipherInputStream c_in = new CipherInputStream(b_in, cipher);
            int ch;
            while ((ch = c_in.read()) >= 0) {
                output.write(ch);
            }
            c_in.close();
        } else {
            cipher.init(Cipher.DECRYPT_MODE, key, ivSpec);
            CipherOutputStream c_out = new CipherOutputStream(output, cipher);
            c_out.write(input_bytes);
            c_out.close();
        }
        return output.toByteArray();
    }

    /**
     * Sign Message
     * 
     * @param String
     *            input
     * @return String as HashText
     */
    public static String getHMacSHA256(String secret_key, String input) {
        try {
            Key KEY = new SecretKeySpec(input.getBytes("UTF-8"), "HmacSHA256");
            Mac sha256_HMAC = Mac.getInstance("HMACSHA256");

            sha256_HMAC.init(KEY);
            byte[] mac_data = sha256_HMAC.doFinal(secret_key.getBytes());

            BigInteger number = new BigInteger(1, mac_data);
            String hashtext = number.toString(16);

            return hashtext;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Get MD5
     * 
     * @param string
     * @return
     */
    public static byte[] md5(String string) {
        byte[] hash;

        try {
            hash = MessageDigest.getInstance("MD5").digest(
                    string.getBytes("UTF-8"));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 should be supported!", e);
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("UTF-8 should be supported!", e);
        }

        StringBuilder hex = new StringBuilder(hash.length * 2);
        for (byte b : hash) {
            if ((b & 0xFF) < 0x10)
                hex.append("0");
            hex.append(Integer.toHexString(b & 0xFF));
        }
        return hexStringToByteArray(hex.toString());
    }

    public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character
                    .digit(s.charAt(i + 1), 16));
        }
        return data;
    }

}
