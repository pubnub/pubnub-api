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
    private Hashtable subscriptions;

    private class ChannelStatus {

        String channel;
        boolean connected, first;
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

    /**
     * Subscribe
     *
     * Listen for a message on a channel.
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback.
     */
    public void subscribe(Hashtable args) throws PubnubException {
        Callback callback = null;
        // Validate Arguments
        if ((callback = (Callback) args.get("callback")) == null) {
            throw new PubnubException("Invalid Callback");
        }

        if (args.get("channel") == null || args.get("channel").equals("")) {
            callback.errorCallback(null, "Invalid Channel.");
            return;
        }

        args.put("timetoken", "0");
        args.put("callback", callback);
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
    public void subscribe(Hashtable args, Callback callback) throws PubnubException {

        // Validate Arguments
        if (callback == null) {
            throw new PubnubException("Invalid Callback");
        }

        if (args.get("channel") == null || args.get("channel").equals("")) {
            callback.errorCallback(null, "Channel Null");
            return;
        }

        args.put("timetoken", "0");
        args.put("callback", callback);
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
    public void subscribe(Hashtable args, String channel, Callback callback) throws PubnubException {

        // Validate Arguments
        if (callback == null) {
            throw new PubnubException("Invalid Callback");
        }

        if (channel == null || channel.equals("")) {
            callback.errorCallback(null, "Channel Null");
            return;
        }

        args.put("timetoken", "0");
        args.put("callback", callback);
        _subscribe(args);
    }

    /**
     * Subscribe - Private Interface
     *
     *
     * @param HashMap <String, Object> containing channel name, function
     * callback, timetoken.
     */
    private void _subscribe(Hashtable args) throws PubnubException {

        String[] errorMessages = {"0", "0"};
        String channel = (String) args.get("channel");
        String timetoken = (String) args.get("timetoken");
        final Callback callback;

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
            subscriptions = new Hashtable();
            subscriptions.put(cs.channel, cs);
        }
        while (true) {
            try {
                // Build URL
                String[] url = {"subscribe",
                        this.SUBSCRIBE_KEY, channel, "0", timetoken};
                Hashtable params = new Hashtable();
                params.put("uuid",uuid());

                // Stop Connection?
                boolean is_disconnect = false;

                if (subscriptions.get(channel) != null
                        && !subscriptions.get(channel).connected) {
                    subscriptions.remove(channel);
                    callback.disconnectCallback(channel);
                    is_disconnect = true;
                }
                if (is_disconnect) {
                    return;
                }
                Request req = new Request(url, params,new ResponseHandler(){
                    public void handleResponse(String channel, String response) {
                        
                        try {
                            JSONArray responseJsarr = new JSONArray(response);
                        } catch (JSONException e) {
                            callback.errorCallback(channel, "Response invalid json");
                        }
                        
                        if (subscriptions.get(channel) != null
                            && !subscriptions.get(channel).connected) {
                                subscriptions.remove(channel);
                                callback.disconnectCallback(channel);
                            is_disconnect = true;
                            }

                        if (is_disconnect) {
                            return;
                        }

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
                if (response.optString(1).length() > 0) {
                    timetoken = response.optString(1);
                }

                for (int i = 0; messages.length() > i; i++) {
                    JSONObject message = messages.optJSONObject(i);
                    if (message != null) {

                        if (this.CIPHER_KEY.length() > 0) {
                            // Decrypt Message
                            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                            message = pc.decrypt(message);
                        }
                        if (callback != null) {
                            if (!callback.successCallback(channel, message)) {
                                return;
                            }
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
                            if (callback != null) {
                                if (!callback.successCallback(channel, arr)) {
                                    return;
                                }
                            }
                        } else {
                            String msgs = messages.getString(0);
                            if (this.CIPHER_KEY.length() > 0) {
                                PubnubCrypto pc = new PubnubCrypto(
                                        this.CIPHER_KEY);
                                msgs = pc.decrypt(msgs);
                            }
                            if (callback != null) {
                                if (!callback.successCallback(channel, msgs)) {
                                    return;
                                }
                            }
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
        ChannelStatus it;
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

    private String getURL(Vector url_components) {
        StringBuffer url = new StringBuffer();
        Enumeration url_iterator = url_components.elements();
        url.append(this.ORIGIN);

        // Generate URL with UTF-8 Encoding
        while (url_iterator.hasMoreElements()) {
            try {
                String url_bit = (String) url_iterator.nextElement();
                // url.append("/").append(_encodeURIcomponent(url_bit));
                if (url_bit.startsWith("?")) {
                    url.append(url_bit);
                } else {
                    url.append("/").append(encode(url_bit, "UTF-8"));
                }
            } catch (Exception e) {
                JSONArray jsono = new JSONArray();
                try {
                    jsono.put("Failed UTF-8 Encoding URL.");
                } catch (Exception jsone) {
                }
                //  return jsono;
                if (_callback != null) {
                    _callback.errorCallback("No Channel Neme", jsono);
                }
            }
        }
        return url.toString();
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
                req.responseHandler.handleResponse(req.getChannel(), response);
            }

            public void errorCall(HttpConnection conn, int statusCode, String response) throws IOException {
                req.responseHandler.handleError(req.getChannel(), response);
            }
        };

        AsyncHttpManager.getInstance().queue(callback);
    }

    private char toHex(int ch) {
        return (char) (ch < 10 ? '0' + ch : 'A' + ch - 10);
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

            if ("gzip".equals(c.getEncoding())) {
                dis = new GZIPInputStream(dis);
            }

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

    public String encode(String s, String enc)
            throws UnsupportedEncodingException {

        boolean needToChange = false;
        boolean wroteUnencodedChar = false;
        int maxBytesPerChar = 10; // rather arbitrary limit, but safe for now
        StringBuffer out = new StringBuffer(s.length());
        ByteArrayOutputStream buf = new ByteArrayOutputStream(maxBytesPerChar);
        OutputStreamWriter writer = new OutputStreamWriter(buf, enc);
        for (int i = 0; i < s.length(); i++) {
            int c = (int) s.charAt(i);
            if (dontNeedEncoding(c)) {
                if (c == ' ') {
                    out.append('%');
                    out.append(toHex(c / 16));
                    out.append(toHex(c % 16));

                    needToChange = true;
                } else {
                    out.append((char) c);
                    wroteUnencodedChar = true;
                }
            } else {
                // convert to external encoding before hex conversion
                try {
                    if (wroteUnencodedChar) { // Fix for 4407610
                        writer = new OutputStreamWriter(buf, enc);
                        wroteUnencodedChar = false;
                    }
                    writer.write(c);
                    /*
                     * If this character represents the start of a Unicode
                     * surrogate pair, then pass in two characters. It's not
                     * clear what should be done if a bytes reserved in the
                     * surrogate pairs range occurs outside of a legal surrogate
                     * pair. For now, just treat it as if it were any other
                     * character.
                     */
                    if (c >= 0xD800 && c <= 0xDBFF) {
                        /*
                         * System.out.println(Integer.toHexString(c) + " is high
                         * surrogate");
                         */
                        if ((i + 1) < s.length()) {
                            int d = (int) s.charAt(i + 1);
                            /*
                             * System.out.println("\tExamining " +
                             * Integer.toHexString(d));
                             */
                            if (d >= 0xDC00 && d <= 0xDFFF) {
                                /*
                                 * System.out.println("\t" +
                                 * Integer.toHexString(d) + " is low
                                 * surrogate");
                                 */
                                writer.write(d);
                                i++;
                            }
                        }
                    }
                    writer.flush();
                } catch (IOException e) {
                    buf.reset();
                    continue;
                }
                byte[] ba = buf.toByteArray();
                for (int j = 0; j < ba.length; j++) {
                    out.append('%');
                    char ch = CCharacter.forDigit((ba[j] >> 4) & 0xF, 16);
                    // converting to use uppercase letter as part of
                    // the hex value if ch is a letter.
                    //            if (Character.isLetter(ch)) {
                    //            ch -= caseDiff;
                    //            }
                    out.append(ch);
                    ch = CCharacter.forDigit(ba[j] & 0xF, 16);
                    //            if (Character.isLetter(ch)) {
                    //            ch -= caseDiff;
                    //            }
                    out.append(ch);
                }
                buf.reset();
                needToChange = true;
            }
        }

        return (needToChange ? out.toString() : s);
    }

    static class CCharacter {

        public static char forDigit(int digit, int radix) {
            if ((digit >= radix) || (digit < 0)) {
                return '\0';
            }
            if ((radix < Character.MIN_RADIX) || (radix > Character.MAX_RADIX)) {
                return '\0';
            }
            if (digit < 10) {
                return (char) ('0' + digit);
            }
            return (char) ('a' - 10 + digit);
        }
    }

    public static boolean dontNeedEncoding(int ch) {
        int len = _dontNeedEncoding.length();
        boolean en = false;
        for (int i = 0; i < len; i++) {
            if (_dontNeedEncoding.charAt(i) == ch) {
                en = true;
                break;
            }
        }
        return en;
    }
    //private static final int caseDiff = ('a' - 'A');
    private static String _dontNeedEncoding = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -_.*";
}
