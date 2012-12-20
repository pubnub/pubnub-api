package com.pubnub.api;

import java.io.*;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.ShortBufferException;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import javax.microedition.io.HttpsConnection;
import org.bouncycastle.crypto.DataLengthException;
import org.bouncycastle.crypto.InvalidCipherTextException;
import org.bouncycastle.util.SecureRandom;
import org.json.me.JSONArray;
import org.json.me.JSONException;
import org.json.me.JSONObject;
import com.pubnub.crypto.PubnubCrypto;
import com.pubnub.util.AsyncHttpManager;
import com.pubnub.util.HttpCallback;
import java.util.*;


public class Pubnub {

    private String ORIGIN = "pubsub.pubnub.com";
    private String PUBLISH_KEY = "";
    private String SUBSCRIBE_KEY = "";
    private String SECRET_KEY = "";
    private String CIPHER_KEY = "";
    private boolean SSL = false;
    private String current_timetoken = "0";
    private String UUID = null;
    private Hashtable _headers;
    private Hashtable channels;

    private class Channel {

        String name;
        boolean connected, disconnected;
        int subscribed = 1;
        Callback callback;
    }

    private String uuid() {
        return "abcd-efgh-jikl-mnop";
    }

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
    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            String cipher_key, boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
    }

    /**
     * PubNub 3.0 with SSL
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     * @param String Secret Key.
     * @param boolean SSL Enabled.
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, "", ssl_on);
    }

    /**
     * PubNub 2.0 without Secret Key and SSL
     *
     * Prepare PubNub Class State.
     *
     * @param String Publish Key.
     * @param String Subscribe Key.
     */
    public Pubnub(String publish_key, String subscribe_key) {
        this.init(publish_key, subscribe_key, "", "", false);
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
    public Pubnub(String publish_key, String subscribe_key, String secret_key) {
        this.init(publish_key, subscribe_key, secret_key, "", false);
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
    private void init(String publish_key, String subscribe_key,
            String secret_key, String cipher_key, boolean ssl_on) {
        this.PUBLISH_KEY = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY = secret_key;
        this.CIPHER_KEY = cipher_key;
        this.SSL = ssl_on;

        // SSL On?
        if (this.SSL) {
            this.ORIGIN = "https://" + this.ORIGIN;
        } else {
            this.ORIGIN = "http://" + this.ORIGIN;
        }
        
        if (UUID == null) UUID = uuid();
        
        if (channels == null) channels = new Hashtable();
            
            

        _headers = new Hashtable();
        _headers.put("V", "3.3");
        _headers.put("User-Agent", "J2ME");
        _headers.put("Accept-Encoding", "gzip");
        _headers.put("Connection", "close");
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
    public void publish(String channel, JSONObject message, Callback callback) {
        Hashtable args = new Hashtable();
        args.put("channel", channel);
        args.put("message", message);
        args.put("callback", callback);
        publish(args);
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
    public void publish(Hashtable args, Callback callback) {
        args.put("callback", callback);
        publish(args);
    }

    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param HashMap <String, Object> containing channel name, message.
     * @return JSONArray.
     */
    public void publish(Hashtable args) {

        final String channel = (String) args.get("channel");
        Object message = args.get("message");
        final Callback callback = (Callback) args.get("callback");

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
                    e.printStackTrace();
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
            System.out.println();
        }

        // Generate String to Sign
        String signature = "0";

        if (this.SECRET_KEY.length() > 0) {
            StringBuffer string_to_sign = new StringBuffer();
            string_to_sign.append(this.PUBLISH_KEY).append('/').append(this.SUBSCRIBE_KEY).append('/').append(this.SECRET_KEY).append('/').append(channel).append('/').append(message.toString());

            // Sign Message
            signature = PubnubCrypto.getHMacSHA256(this.SECRET_KEY,
                    string_to_sign.toString());
        }   


        String[] urlComponents = {"publish", this.PUBLISH_KEY,
            this.SUBSCRIBE_KEY, signature, channel,
            "0", message.toString()};

        Request req = new Request(urlComponents, channel, new ResponseHandler() {
            public void handleResponse(String response) {
                JSONArray jsarr;
                try {
                    jsarr = new JSONArray(response);
                } catch (JSONException e) {
                    handleError(response);
                    return;
                }
                callback.successCallback(channel, jsarr);
            }

            public void handleError(String response) {
                JSONArray jsarr = null;
                jsarr.put("0").put("Error: Failed JSON HTTP Request");
                callback.errorCallback(channel, jsarr);
            }
        });

        _request(req);
    }

    private boolean inputsValid(Hashtable args) throws PubnubException {
        Callback callback;
        if ((callback = (Callback) args.get("callback")) == null) {
            throw new PubnubException("Invalid Callback");
        }

        if (args.get("channels") == null || args.get("channels").equals("")) {
            callback.errorCallback(null, "Invalid Channel.");
            return false;
        }
        return true;
    }

    /**
     * Subscribe
     *
     * Listen for a message on a channel.
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback.
     */
    public void subscribe(Hashtable args, Callback callback) throws PubnubException {


        args.put("timetoken", "0");
        args.put("callback", callback);
        
        if (!inputsValid(args)) {
            return;
        }

        _subscribe(args);
    }

    
    /**
     * Subscribe
     *
     * Listen for a message on a channel.
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback.
     */
    public void subscribe(Hashtable args) throws PubnubException {

        if (!inputsValid(args)) {
            return;
        }

        args.put("timetoken", "0");
        _subscribe(args);
    }

    /**
     * Subscribe
     *
     * Listen for a message on a channel.
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback.
     */
    public void subscribe(String[] channelsArr, Callback callback) throws PubnubException {

        Hashtable args = new Hashtable();

        args.put("channels", channelsArr);
        args.put("callback", callback);
        subscribe(args);
    }

    private void callErrorCallbacks(String[] channelList, String[] messages) {
        for (int i = 0; i < channelList.length; i++) {
            Callback cb = ((Channel) channels.get(channelList[i])).callback;
            cb.errorCallback(channelList[i], messages[i]);
        }
    }

    private void callErrorCallbacks(String[] channelList, String message) {
        for (int i = 0; i < channelList.length; i++) {
            Callback cb = ((Channel) channels.get(channelList[i])).callback;
            cb.errorCallback(channelList[i], message);
        }
    }
    
    /**
     * Subscribe - Private Interface
     *
     * Patch provided by petereddy on GitHub
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback, timetoken.
     */
    private void _subscribe(Hashtable args) {

        final String[] channelList = (String[]) args.get("channels");
        final Callback callback = (Callback) args.get("callback");
        final String timetoken = (String) args.get("timetoken");

        /*
         * Scan through the channels array.
         * If a channel does not exist in hashtable
         * create a new entry with default values.
         * If already exists and connected, then return
         * 
         */
        
        for (int i = 0; i < channelList.length; i++) {
            String channel = channelList[i];

            Channel channelObj = (Channel) channels.get(channel);

            if (channelObj == null) {
                Channel ch = new Channel();
                ch.name = channel;
                ch.connected = false;
                ch.callback = callback;
                channels.put(ch.name, ch);
            } else if (channelObj.connected) {

                return;
            }
        }

        class Connect {

            public void _connect(String timetoken) {
                String channelString = PubnubUtil.joinString(channelList, ",");

                if (channelString == null) {
                    callErrorCallbacks(channelList,"Parsing Error");
                }

                String[] urlComponents = {
                    Pubnub.this.ORIGIN,
                    "subscribe", Pubnub.this.SUBSCRIBE_KEY,
                    channelString, "0",
                    timetoken
                };

                Hashtable params = new Hashtable();
                params.put("uuid", uuid());



                Request req = new Request(urlComponents, params, channelList, new ResponseHandler() {
                    public void handleResponse(String response) {
                        
                        /*
                         * Iterate over all the channels and call connect
                         * callback for channels which were in disconnected
                         * state. Nothing to do for channels already connected
                         * 
                         */ 
                        Enumeration ch = Pubnub.this.channels.elements();
                        while (ch.hasMoreElements()){
                            Channel _channel = (Channel)ch.nextElement();
                            if (_channel.connected == false) {
                                _channel.connected = true;
                                _channel.callback.connectCallback(_channel.name);
                            }    
                        }
                        
                        /*
                         * Check if response has channel names. A JSON response with
                         * more than 2 items means the response contains the channel
                         * names as well. The channel names are in a comma delimted
                         * string. Call success callback on all he channels passing
                         * the corresponding response message.
                         * 
                         */
                        
                        JSONArray jsa;
                        try {
                            jsa = new JSONArray(response);
                            JSONArray messages = new JSONArray(jsa.get(0).toString());
                            
                            if (jsa.length() > 2) {
                                /*
                                 * Response has multiple channels
                                 */
                                
                                String[] _channels = PubnubUtil.splitString(jsa.getString(2), ",");
                                
                                
                                for (int i = 0; i < _channels.length; i++) {
                                    callback.successCallback(_channels[i], messages.get(i));
                                }

                                
                            } else {
                                /*
                                 * Response for single channel
                                 * Callback on single channel
                                 */
                                for (int i = 0; i < messages.length(); i++) {
                                    callback.successCallback(channelList[0], messages.get(i));
                                }
                                
                            }
                           _connect((String)messages.get(1)); 
                        } catch (JSONException e) {
                        }
                        
                    }

                    public void handleError(String response) {
                        /*
                         * Iterate over all the channels and call disconnect
                         * callback for channels which were in connected
                         * state. Nothing to do for channels already connected
                         * 
                         */ 
                        Enumeration ch = Pubnub.this.channels.elements();
                        while (ch.hasMoreElements()){
                            Channel _channel = (Channel)ch.nextElement();
                            if (_channel.connected == true) {
                                _channel.connected = false;
                                _channel.callback.disconnectCallback(_channel.name);
                            }    
                        }
                        
                        /*
                         * Call error callback on all channels where we tried to connect
                         */
                        callErrorCallbacks(channelList,"Error Occurred");
                        try {
                            Thread.sleep(10000);
                        } catch (InterruptedException e) {
                            //TODO Handle exception
                        }
                        _connect("0");
                        
                    }
                });

                _request(req);
            }
        }
        new Connect()._connect(timetoken);
    }





    /**
     * Request URL
     *
     * @param List <String> request of url directories.
     * @return JSONArray from JSON response.
     */
    private void _request(final Request req) {

        HttpCallback callback = new HttpCallback(req.getUrl(), _headers) {
            public void OnComplete(HttpConnection hc, int statusCode, String response) throws IOException {
                req.responseHandler.handleResponse(response);
            }

            public void errorCall(HttpConnection conn, int statusCode, String response) throws IOException {

                req.responseHandler.handleError(response);

            }
        };
        AsyncHttpManager.getInstance().queue(callback);
    }

   
}
