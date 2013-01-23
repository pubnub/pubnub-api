package com.pubnub.api;

import java.util.Hashtable;

import org.bouncycastle.util.SecureRandom;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.pubnub.crypto.PubnubCrypto;
import com.pubnub.http.HttpManager;
import com.pubnub.http.HttpRequest;
import com.pubnub.http.ResponseHandler;

/**
 * Pubnub object facilitates querying channels for messages and listening on
 * channels for presence/message events
 *
 * @author Pubnub
 *
 */

public class Pubnub {

    private String ORIGIN = "pubsub.pubnub.com";
    private String PUBLISH_KEY = "";
    private String SUBSCRIBE_KEY = "";
    private String SECRET_KEY = "";
    private String CIPHER_KEY = "";
    private boolean SSL = true;
    private String UUID = null;
	private Hashtable _headers;
    private Subscriptions subscriptions;

    private HttpManager longPollConnManager;
    private HttpManager simpleConnManager;

    /**
     * UUID
     *
     * 32 digit UUID generation at client side.
     *
     * @return String uuid.
     */
    public static String uuid() {
        String valueBeforeMD5;
        String valueAfterMD5;
        SecureRandom mySecureRand = new SecureRandom();
        String s_id = String.valueOf(Pubnub.class.hashCode());
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
            return null;
        }
    }

    /**
     *
     * Constructor for Pubnub Class
     *
     * @param publish_key
     *            Publish Key
     * @param subscribe_key
     *            Subscribe Key
     * @param secret_key
     *            Secret Key
     * @param cipher_key
     *            Cipher Key
     * @param ssl_on
     *            SSL enabled ?
     */

    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            String cipher_key, boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
    }

    /**
     *
     * Constructor for Pubnub Class
     *
     * @param publish_key
     *            Publish Key
     * @param subscribe_key
     *            Subscribe Key
     * @param secret_key
     *            Secret Key
     * @param ssl_on
     *            SSL enabled ?
     */

    public Pubnub(String publish_key, String subscribe_key, String secret_key,
            boolean ssl_on) {
        this.init(publish_key, subscribe_key, secret_key, "", ssl_on);
    }

    /**
     *
     * Constructor for Pubnub Class
     *
     * @param publish_key
     *            Publish Key
     * @param subscribe_key
     *            Subscribe Key
     */

    public Pubnub(String publish_key, String subscribe_key) {
        this.init(publish_key, subscribe_key, "", "", false);
    }

    /**
     *
     * Constructor for Pubnub Class
     *
     * @param publish_key
     *            Publish Key
     * @param subscribe_key
     *            Subscribe Key
     * @param secret_key
     *            Secret Key
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key) {
        this.init(publish_key, subscribe_key, secret_key, "", false);
    }

    /**
     *
     * Initialize PubNub Object State.
     *
     * @param publish_key
     * @param subscribe_key
     * @param secret_key
     * @param cipher_key
     * @param ssl_on
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

        if (UUID == null)
            UUID = uuid();

        if (subscriptions == null)
            subscriptions = new Subscriptions();

        if (longPollConnManager == null)
            longPollConnManager = new HttpManager("Long Poll");

        if (simpleConnManager == null)
            simpleConnManager = new HttpManager("Simple");
        _headers = new Hashtable();
	    _headers.put("V", "3.3");
	    _headers.put("Accept-Encoding", "deflate");

    }

    /**
     * Start heartbeat thread to check connectivity to pubnub servers Calls to
     * pubnub api's will return network error, when heartbeat is on and pubnub
     * servers are not reachable
     *
     * @param interval
     */
    public static void startHeartbeat(int interval) {
        HttpManager.startHeartbeat("http://pubsub.pubnub.com/time/0",
                interval);
    }

    /**
     * Send a message to a channel.
     *
     * @param channel
     *            Channel name
     * @param message
     *            JSONObject to be published
     * @param callback
     *            Callback
     */
    public void publish(String channel, JSONObject message, Callback callback) {
        Hashtable args = new Hashtable();
        args.put("channel", channel);
        args.put("message", message);
        args.put("callback", callback);
        publish(args);
    }

    /**
     * Send a message to a channel.
     *
     * @param channel
     *            Channel name
     * @param message
     *            JSONObject to be published
     * @param callback
     *            Callback
     */
	public void publish(String channel, JSONArray message, Callback callback) {
        Hashtable args = new Hashtable();
        args.put("channel", channel);
        args.put("message", message);
        args.put("callback", callback);
        publish(args);
    }

    /**
     * Send a message to a channel.
     *
     * @param channel
     *            Channel name
     * @param message
     *            JSONObject to be published
     * @param callback
     *            Callback
     */
    public void publish(String channel, String message, Callback callback) {
        Hashtable args = new Hashtable();
        args.put("channel", channel);
        args.put("message", message);
        args.put("callback", callback);
        publish(args);
    }

    /**
     * Send a message to a channel.
     *
     * @param args
     *            Hashtable containing channel name, message.
     * @param callback
     *            Callback
     */
    public void publish(Hashtable args, Callback callback) {
        args.put("callback", callback);
        publish(args);
    }

    /**
     * Send a message to a channel.
     *
     * @param args
     *            Hashtable containing channel name, message, callback
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
                try {
                    message = pc.encrypt(obj);
                } catch (Exception e) {
                    JSONArray jsarr;
                    jsarr = new JSONArray();
                    jsarr.put("0").put("Error: Encryption Failure");
                    callback.errorCallback(channel, jsarr);
                    return;
                }
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
                    JSONArray jsarr;
                    jsarr = new JSONArray();
                    jsarr.put("0").put("Error: Encryption Failure");
                    callback.errorCallback(channel, jsarr);
                    return;
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
                try {
                    message = pc.encryptJSONArray(obj);
                } catch (Exception e) {
                    JSONArray jsarr;
                    jsarr = new JSONArray();
                    jsarr.put("0").put("Error: Encryption Failure");
                    callback.errorCallback(channel, jsarr);
                    return;
                }

            } else {
                message = obj;
            }
        }

        // Generate String to Sign
        String signature = "0";

        if (this.SECRET_KEY.length() > 0) {
            StringBuffer string_to_sign = new StringBuffer();
            string_to_sign.append(this.PUBLISH_KEY).append('/')
                    .append(this.SUBSCRIBE_KEY).append('/')
                    .append(this.SECRET_KEY).append('/').append(channel)
                    .append('/').append(message.toString());

            // Sign Message
            signature = PubnubCrypto.getHMacSHA256(this.SECRET_KEY,
                    string_to_sign.toString());
        }

        String[] urlComponents = { this.ORIGIN, "publish", PubnubUtil.urlEncode(this.PUBLISH_KEY),
                PubnubUtil.urlEncode(this.SUBSCRIBE_KEY), PubnubUtil.urlEncode(signature),
                PubnubUtil.urlEncode(channel), PubnubUtil.urlEncode("0"),
                PubnubUtil.urlEncode(message.toString())};

        PubnubRequest req = new PubnubRequest(urlComponents, channel,
                new ResponseHandler() {
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
                        JSONArray jsarr;
                        try {
                            jsarr = new JSONArray(response);
                        } catch (JSONException e) {
                            jsarr = new JSONArray();
                            jsarr.put("0").put(
                                    "Error: Failed JSON HTTP PubnubRequest");
                        }
                        callback.errorCallback(channel, jsarr);
                        return;
                    }
                });

        _request(req, simpleConnManager);
    }

    /**
     *
     * Listen for presence of subscribers on a channel
     *
     * @param channel
     *            Name of the channel on which to listen for join/leave i.e.
     *            presence events
     * @param callback
     *            Callback
     * @exception PubnubException
     *                Throws PubnubException if Callback is null
     */
    public void presence(String channel, Callback callback)
            throws PubnubException {
        Hashtable args = new Hashtable(2);
        args.put("channel", channel + "-pnpres");
        args.put("callback", callback);
        subscribe(args);
    }

    /**
     *
     * Read presence information from a channel
     *
     * @param channel
     *            Channel name
     * @param requestTimeout
     *            timeout in milliseconds for this request
     */
    public void hereNow(final String channel, final Callback callback) {

        String[] urlargs = { this.ORIGIN, "v2", "presence", "sub_key",
                this.SUBSCRIBE_KEY, "channel", channel };

        PubnubRequest req = new PubnubRequest(urlargs, (String) null,
                new ResponseHandler() {

                    public void handleResponse(String response) {
                        callback.successCallback(channel, response);

                    }

                    public void handleError(String response) {
                        callback.errorCallback(channel, response);

                    }

                });

        _request(req, simpleConnManager);
    }

    /**
     *
     * Read history from a channel.
     *
     * @param channel
     *            Channel Name
     * @param limit
     *            Upper limit on number of messages in response
     * @param requestTimeout
     *            timeout in milliseconds for this request
     * @return JSONArray of message history on a channel.
     */
    public void history(String channel, int limit, Callback callback) {
        Hashtable args = new Hashtable(2);
        args.put("channel", channel);
        args.put("limit", String.valueOf(limit));
        args.put("callback", callback);
        history(args);
    }

    /**
     *
     * Read history from a channel.
     *
     * @param args
     *            HashMap of <String, Object> containing channel name, limit
     *            history count
     * @param requestTimeout
     *            timeout in milliseconds for this request
     * @return JSONArray of history.
     */
    private void history(Hashtable args) {

        final String channel = (String) args.get("channel");
        String limit = (String) args.get("limit");
        final Callback callback = (Callback) args.get("callback");

        String[] urlargs = { this.ORIGIN, "history", this.SUBSCRIBE_KEY,
                channel, "0", limit };

        PubnubRequest req = new PubnubRequest(urlargs, channel, new ResponseHandler() {

            public void handleResponse(String response) {
                callback.successCallback(channel, response);

            }

            public void handleError(String response) {
                callback.errorCallback(channel, response);

            }

        });
        _request(req, simpleConnManager);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param start
     *            Start time
     * @param end
     *            End time
     * @param count
     *            Upper limit on number of messages to be returned
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(final String channel, long start, long end,
            int count, boolean reverse, final Callback callback) {
        Hashtable parameters = new Hashtable();
        if (count == -1)
            count = 100;

        parameters.put("count", String.valueOf(count));
        parameters.put("reverse", String.valueOf(reverse));

        if (start != -1)
            parameters.put("start", Long.toString(start).toLowerCase());

        if (end != -1)
            parameters.put("end", Long.toString(end).toLowerCase());

        String[] urlargs = { this.ORIGIN, "v2", "history", "sub-key",
                this.SUBSCRIBE_KEY, "channel", channel };

        PubnubRequest req = new PubnubRequest(urlargs, parameters, channel,
                new ResponseHandler() {

                    public void handleResponse(String response) {
                        callback.successCallback(channel, response);

                    }

                    public void handleError(String response) {
                        callback.errorCallback(channel, response);

                    }

                });
        _request(req, simpleConnManager);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param start
     *            Start time
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, long start, boolean reverse,
            Callback callback) {
        detailedHistory(channel, start, -1, -1, reverse, callback);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param start
     *            Start time
     * @param end
     *            End time
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, long start, long end,
            Callback callback) {
        detailedHistory(channel, start, end, -1, false, callback);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param start
     *            Start time
     * @param end
     *            End time
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, long start, long end,
            boolean reverse, Callback callback) {
        detailedHistory(channel, start, end, -1, reverse, callback);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param count
     *            Upper limit on number of messages to be returned
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, int count, boolean reverse,
            Callback callback) {
        detailedHistory(channel, -1, -1, count, reverse, callback);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, boolean reverse,
            Callback callback) {
        detailedHistory(channel, -1, -1, -1, reverse, callback);
    }

    /**
     *
     * Read DetailedHistory for a channel.
     *
     * @param channel
     *            Channel name for which detailed history is required
     * @param reverse
     *            True if messages need to be in reverse order
     * @return JSONArray of detailed history.
     */
    public void detailedHistory(String channel, int count, Callback callback) {
        detailedHistory(channel, -1, -1, count, false, callback);
    }

    /**
     * Read current time from PubNub Cloud.
     *
     * @return current timestamp.
     */
    public void time(final Callback cb) {

        String[] url = { this.ORIGIN, "time", "0" };
        PubnubRequest req = new PubnubRequest(url, (String) null, new ResponseHandler() {

            public void handleResponse(String response) {
                cb.successCallback(null, response);
            }

            public void handleError(String response) {
                cb.errorCallback(null, response);
            }

        });

        _request(req, simpleConnManager);
    }

    private boolean inputsValid(Hashtable args) throws PubnubException {
        boolean channelMissing;
        if (((Callback) args.get("callback")) == null) {
            throw new PubnubException("Invalid Callback");
        }
        Object _channels = args.get("channels");
        Object _channel = args.get("channel");

        channelMissing = ((_channel == null || _channel.equals("")) && (_channels == null || _channels
                .equals(""))) ? true : false;

        if (channelMissing) {
            throw new PubnubException("Channel Missing");
        }
        return true;
    }

    /**
     * Unsubscribe/Disconnect from channel.
     *
     * @param channels
     *            String[] array containing channel names as string.
     */
    public void unsubscribe(String[] channels) {
        for (int i = 0; i < channels.length; i++) {
            subscriptions.removeChannel(channels[i]);
        }
    }

    /**
     * Unsubscribe/Disconnect from channel.
     *
     * @param channel
     *            channel name as String.
     */
    public void unsubscribe(String channel) {
        unsubscribe(new String[] { channel });
    }

    /**
     * Unsubscribe/Disconnect from channel.
     *
     * @param args
     *            Hashtable containing channel name.
     */
    public void unsubscribe(Hashtable args) {
        String[] channelList = (String[]) args.get("channels");
        if (channelList == null) {
            channelList = new String[] { (String) args.get("channel") };
        }
        unsubscribe(channelList);
    }

    /**
     *
     * Listen for a message on a channel.
     *
     * @param args
     *            Hashtable containing channel name
     * @param callback
     *            Callback
     * @exception PubnubException
     *                Throws PubnubException if Callback is null
     */
    public void subscribe(Hashtable args, Callback callback)
            throws PubnubException {

        args.put("callback", callback);

        if (!inputsValid(args)) {
            return;
        }
        args.put("timetoken", "0");
        _subscribe(args);
    }

    /**
     *
     * Listen for a message on a channel.
     *
     * @param args
     *            Hashtable containing channel name, callback
     * @exception PubnubException
     *                Throws PubnubException if Callback is null
     */
    public void subscribe(Hashtable args) throws PubnubException {

        if (!inputsValid(args)) {
            return;
        }

        args.put("timetoken", "0");
        _subscribe(args);
    }

    /**
     *
     * Listen for a message on a channel.
     *
     * @param channelsArr
     *            Array of channel names (string) to listen on
     * @param callback
     *            Callback
     * @exception PubnubException
     *                Throws PubnubException if Callback is null
     */
    public void subscribe(String[] channelsArr, Callback callback)
            throws PubnubException {

        Hashtable args = new Hashtable();

        args.put("channels", channelsArr);
        args.put("callback", callback);
        subscribe(args);
    }

    private void callErrorCallbacks(String[] channelList, String message) {
        for (int i = 0; i < channelList.length; i++) {
            Callback cb = ((Channel) subscriptions.getChannel(channelList[i])).callback;
            cb.errorCallback(channelList[i], message);
        }
    }

    /**
     * @param args
     *            Hashtable
     */
    private void _subscribe(Hashtable args) {

        String[] channelList = (String[]) args.get("channels");
        if (channelList == null) {
            channelList = new String[] { (String) args.get("channel") };
        }
        Callback callback = (Callback) args.get("callback");
        String timetoken = (String) args.get("timetoken");

        /*
         * Scan through the channels array. If a channel does not exist in
         * hashtable create a new entry with default values. If already exists
         * and connected, then return
         */

        for (int i = 0; i < channelList.length; i++) {
            String channel = channelList[i];
            Channel channelObj = (Channel) subscriptions.getChannel(channel);

            if (channelObj == null) {
                Channel ch = new Channel();
                ch.name = channel;
                ch.connected = false;
                ch.callback = callback;
                subscriptions.addChannel(ch);
            } else if (channelObj.connected) {

                return;
            }
        }
        _subscribe_base(timetoken);
    }

    /**
     * @param timetoken
     *            , Timetoken to be used
     */
    private void _subscribe_base(String timetoken) {
        String channelString = subscriptions.getChannelString();
        String[] channelsArray = subscriptions.getChannelNames();

        if (channelString == null) {
            callErrorCallbacks(channelsArray, "Parsing Error");
            return;
        }
        System.out.println("Called with timetoken : " + timetoken);
        String[] urlComponents = { Pubnub.this.ORIGIN, "subscribe",
                Pubnub.this.SUBSCRIBE_KEY, channelString, "0", timetoken };

        Hashtable params = new Hashtable();
        params.put("uuid", UUID);

        PubnubRequest req = new PubnubRequest(urlComponents, params, channelsArray,
                new ResponseHandler() {
                    String _timetoken = "0";

                    public void handleResponse(String response) {

                        subscriptions.invokeConnectCallbackOnChannels();

                        /*
                         * Check if response has channel names. A JSON response
                         * with more than 2 items means the response contains
                         * the channel names as well. The channel names are in a
                         * comma delimted string. Call success callback on all
                         * he channels passing the corresponding response
                         * message.
                         */

                        JSONArray jsa;
                        try {
                            jsa = new JSONArray(response);
                            _timetoken = jsa.get(1).toString();
                            JSONArray messages = new JSONArray(jsa.get(0)
                                    .toString());

                            if (jsa.length() > 2) {
                                /*
                                 * Response has multiple channels
                                 */

                                String[] _channels = PubnubUtil.splitString(
                                        jsa.getString(2), ",");

                                for (int i = 0; i < _channels.length; i++) {
                                    Channel _channel = (Channel) subscriptions
                                            .getChannel(_channels[i]);
                                    if (_channel != null)
                                        _channel.callback.successCallback(
                                                _channels[i], messages.get(i));
                                }

                            } else {
                                /*
                                 * Response for single channel Callback on
                                 * single channel
                                 */
                                Channel _channel = subscriptions
                                        .getFirstChannel();

                                if (_channel != null) {
                                    for (int i = 0; i < messages.length(); i++) {
                                        _channel.callback.successCallback(
                                                _channel.name, messages.get(i));
                                    }
                                }

                            }
                            System.out.println(_timetoken);
                            _subscribe_base(_timetoken);
                        } catch (JSONException e) {
                            _subscribe_base(_timetoken);
                        }

                    }

                    public void handleError(String response) {
                        subscriptions.invokeDisconnectCallbackOnChannels();
                        _subscribe_base(_timetoken);
                    }
                });

        _request(req, longPollConnManager);
    }

    /**
     * @param req
     * @param connManager
     */
    private void _request(final PubnubRequest req, HttpManager connManager) {
        HttpRequest hreq = new HttpRequest(req.getUrl(), _headers, req.responseHandler);
        System.out.println("_request : " + hreq + " : " + req.getUrl());
        connManager.queue(hreq);
    }
}
