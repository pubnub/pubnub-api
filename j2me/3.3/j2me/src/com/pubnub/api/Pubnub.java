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
    //private Vector subscriptions;
    private Vector _connection;

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

    public static String[] split(String str, String delim) {
        StringBuffer token = new StringBuffer();
        Vector tokens = new Vector();


        char[] chars = str.toCharArray();

        for (int i = 0; i < chars.length; i++) {
            if (delim.indexOf(chars[i]) != -1) {
                if (token.length() > 0) {
                    tokens.addElement(token.toString());
                    token.setLength(0);
                }
            } else {
                token.append(chars[i]);
            }
        }

        if (token.length() > 0) {
            tokens.addElement(token.toString());
        }

        // convert the vector into an array
        String[] splitArray = new String[tokens.size()];
        for (int i = 0; i < splitArray.length; i++) {
            splitArray[i] = (String) tokens.elementAt(i);
        }
        return splitArray;
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
        if (UUID == null) {
            UUID = uuid();
        }
        _connection = new Vector();


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
        Hashtable args = new Hashtable(2);
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
     * @param HashMap <String, Object> containing channel name, message.
     * @return JSONArray.
     */
    public void publish(Hashtable args) {

        String channel = (String) args.get("channel");
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
            public void handleResponse(String channel, String response) {
                JSONArray jsarr;
                try {
                    jsarr = new JSONArray(response);
                } catch (JSONException e) {
                    handleError(channel, response);
                    return;
                }
                callback.successCallback(channel, jsarr);
            }

            public void handleError(String channel, String response) {
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

        if (args.get("channel") == null || args.get("channel").equals("")) {
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

        if (channels == null) {
            channels = new Hashtable();
        }

        for (int i = 0; i < channelList.length; i++) {
            String channel = channelList[i];

            Channel channelObj = (Channel) channels.get(channel);

            if (channelObj == null) {
                Channel ch = new Channel();
                ch.name = channel;
                ch.connected = true;
                ch.callback = callback;
                channels.put(ch.name, ch);
            } else if (channelObj.connected) {
                JSONArray jsono = new JSONArray();
                try {
                    jsono.put("Already Connected.");
                } catch (Exception jsone) {
                }
                return;
            }
        }

        class Connect {

            public Connect(Callback cb) {
                this.cb = cb;
            }

            public void _connect() {
                String channelString = PubnubUtil.joinString(channelList, ",");

                if (channelString == null) {
                    return;
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
                        for (int i = 0; i < channelList; i++){
                            
                        }
                        
                    }
                });

                _request(req);
            }
        }
        new Connect(callback)._connect();
    }

    
    
    
    
    /**
     * Time
     *
     * Timestamp from PubNub Cloud.
     *
     * @return long timestamp.
     */
    public long time() {
        try {
            Vector url = new Vector();

            url.addElement("time");
            url.addElement("0");

            String res = getViaHttpsConnection(getURL(url));
            JSONArray response = new JSONArray(res);
            try {

                return Long.parseLong(response.get(0).toString());
            } catch (JSONException ex) {
                ex.printStackTrace();
            }
        } catch (Exception ex) {
            //ex.printStackTrace();
        }
        return 0;
    }

    public void hereNow(String channel, final Callback callback) throws PubnubException {

        if (callback == null) {
            throw new PubnubException("Callback is Null");
        }

        if (channel == null || channel.equals("")) {
            callback.errorCallback(null, "Missing Channel");
            return;
        }

        String[] urlComponents = {
            "v2", "presence", "sub_key", this.SUBSCRIBE_KEY,
            "channel", channel
        };

        Request req = new Request(urlComponents, channel, new ResponseHandler() {
            public void handleResponse(String channel, String response) {
                JSONArray jsarr;
                try {
                    jsarr = new JSONArray(response);
                } catch (JSONException e) {
                    handleError(response, channel);
                    return;
                }
                callback.successCallback(channel, jsarr);
            }

            public void handleError(String channel, String response) {
                JSONArray jsarr = null;
                jsarr.put("0").put("Error: Failed JSON HTTP Request");
                callback.errorCallback(channel, jsarr);
            }
        });
        _request(req);
    }

    public void presence(String channel, Callback callback) throws PubnubException {

        if (callback == null) {
            throw new PubnubException("Callback is Null");
        }

        if (channel == null || channel.equals("")) {
            callback.errorCallback(null, "Missing Channel");
            return;
        }

        Hashtable args = new Hashtable(6);
        args.put("channel", channel + "-pnpres");
        args.put("callback", callback);

        subscribe(args);
    }

    /**
     * UUID
     *
     * 32 digit UUID generation at client side.
     *
     * @return String uuid.
     */
    public String uuid() {
        String valueBeforeMD5;
        String valueAfterMD5;
        SecureRandom mySecureRand = new SecureRandom();
        String s_id = System.getProperty("microedition.platform");
        StringBuffer sbValueBeforeMD5 = new StringBuffer();
        try {
            long time = System.currentTimeMillis();
            long rand = 0;
            rand = mySecureRand.nextLong();
            sbValueBeforeMD5.append(s_id);
            sbValueBeforeMD5.append(":");
            sbValueBeforeMD5.append(Long.toString(time));
            sbValueBeforeMD5.append(":");
            sbValueBeforeMD5.append(Long.toString(rand));
            valueBeforeMD5 = sbValueBeforeMD5.toString();
            byte[] array = PubnubCrypto.md5(valueBeforeMD5);
            StringBuffer sb = new StringBuffer();
            for (int j = 0; j < array.length; ++j) {
                int b = array[j] & 0xFF;
                if (b < 0x10) {
                    sb.append('0');
                }
                sb.append(Integer.toHexString(b));
            }
            valueAfterMD5 = sb.toString();
            String raw = valueAfterMD5.toUpperCase();
            sb = new StringBuffer();
            sb.append(raw.substring(0, 8));
            sb.append("-");
            sb.append(raw.substring(8, 12));
            sb.append("-");
            sb.append(raw.substring(12, 16));
            sb.append("-");
            sb.append(raw.substring(16, 20));
            sb.append("-");
            sb.append(raw.substring(20));
            return sb.toString();
        } catch (Exception e) {
            System.out.println("Error:" + e);
        }
        return null;
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
    public void history(String channel, int limit, Callback callback) {
        Hashtable args = new Hashtable(2);
        args.put("channel", channel);
        args.put("limit", new Integer(limit));
        args.put("callback", callback);
        history(args);
    }

    /**
     * History
     *
     * Load history from a channel.
     *
     * @param HashMap <String, Object> containing channel name, limit history
     * count response.
     * @return JSONArray of history.
     */
    public void history(Hashtable args) {

        String channel = (String) args.get("channel");
        Integer limit = (Integer) args.get("limit");
        final Callback callback = (Callback) args.get("callback");

        String[] urlComponents = {"history", this.SUBSCRIBE_KEY, channel,
            "0", limit.toString()};

        Request req = new Request(urlComponents, channel, new ResponseHandler() {
            public void handleResponse(String channel, String response) {
                JSONArray jsarr;
                try {
                    jsarr = new JSONArray(response);
                } catch (JSONException e) {
                    handleError(response, channel);
                    return;
                }
                callback.successCallback(channel, jsarr);
            }

            public void handleError(String channel, String response) {
                JSONArray jsarr = null;
                jsarr.put("0").put("Error: Failed JSON HTTP Request");
                callback.errorCallback(channel, jsarr);
            }
        });

        _request(req);
    }

    /**
     * Detailed History
     *
     * Load Detailed history from a channel.
     *
     * @param HashMap <String, Object> containing channel name, with optional:
     * 'start', 'end', 'reverse', 'count'.
     * @return JSONArray of history.
     */
    public void detailedHistory(Hashtable args) {
        String channel = (String) args.get("channel");
        final Callback callback = (Callback) args.get("callback");
        if (channel == null || channel.equals("")) {
            System.out.println("Missing Channel");
            return;
        }
        Hashtable params = new Hashtable();
        int count = 100;

        if (args.get("count") != null) {
            count = Integer.parseInt(args.get("count").toString());
        }
        params.put("count", String.valueOf(count));


        if (args.get("reverse") != null) {
            params.put("reverse", String.valueOf(args.get("reverse")));
        }

        if (args.get("start") != null) {
            params.put("start", String.valueOf(args.get("start")));
        }
        if (args.get("end") != null) {
            params.put("end", String.valueOf(args.get("end")));
        }


        String[] urlComponents = {"v2", "history", "sub-key", this.SUBSCRIBE_KEY,
            "channel", channel};

        Request req = new Request(urlComponents, params, channel, new ResponseHandler() {
            public void handleResponse(String channel, String response) {
                JSONArray jsarr;
                try {
                    jsarr = new JSONArray(response);
                } catch (JSONException e) {
                    handleError(response, channel);
                    return;
                }
                callback.successCallback(channel, jsarr);
            }

            public void handleError(String channel, String response) {
                JSONArray jsarr = null;
                jsarr.put("0").put("Error: Failed JSON HTTP Request");
                callback.errorCallback(channel, jsarr);
            }
        });

        _request(req);
    }

    /**
     * Unsubscribe
     *
     * Unsubscribe/Disconnect to channel.
     *
     * @param HashMap <String, Object> containing channel name.
     */
    public void unsubscribe(Hashtable args) {
        String channel = (String) args.get("channel");
        Channel ch;

        for (int i = 0; i < subscriptions.size(); i++) {
            it = (ChannelStatus) subscriptions.elementAt(i);
            if (it.channel.equals(channel) && it.connected) {
                it.connected = false;
                //   it.first = false;
                break;
            }
        }


        for (int i = 0; i < _connection.size(); i++) {
            HttpCallback cb = (HttpCallback) _connection.elementAt(i);
            if (cb.getChannel().equals(channel)) {
                HttpConnection con = cb.getConnection();
                if (con != null) {
                    //con.close();
                    cb.cancelRequest(cb);
                    _connection.removeElement(cb);
                }
            }
        }
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

    public final String getViaHttpsConnection(String url)
            throws IOException, ServiceProviderException {
        HttpConnection c = null;
        InputStream dis = null;
        OutputStream os = null;
        int rc;
        String respBody = ""; // return empty string on bad things
        try {
            if (SSL) {
                c = (HttpsConnection) Connector.open(url, Connector.READ_WRITE,
                        false);
            } else {
                c = (HttpConnection) Connector.open(url, Connector.READ_WRITE,
                        false);
            }
            c.setRequestMethod(HttpConnection.GET);
            c.setRequestProperty("V", "3.3");
            c.setRequestProperty("User-Agent", "Java");
            c.setRequestProperty("Accept-Encoding", "gzip");
            rc = c.getResponseCode();
            int len = c.getHeaderFieldInt("Content-Length", 0);
            dis = c.openInputStream();

            byte[] data = null;
            ByteArrayOutputStream tmp = new ByteArrayOutputStream();
            int ch;
            while ((ch = dis.read()) != -1) {
                tmp.write(ch);
            }
            data = tmp.toByteArray();
            respBody = new String(data, "UTF-8");

        } catch (ClassCastException e) {
            throw new IllegalArgumentException("Not an HTTP URL");
        } finally {
            if (dis != null) {
                dis.close();
            }
            if (c != null) {
                c.close();
            }
        }
        if (rc != HttpConnection.HTTP_OK) {
            throw new ServiceProviderException(
                    "HTTP response code: " + rc, rc, respBody);
        }
        return respBody;
    }
}
