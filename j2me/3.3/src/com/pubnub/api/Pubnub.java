package com.pubnub.api;

import java.io.IOException;
import java.util.Hashtable;

import javax.microedition.io.HttpConnection;

import org.json.me.JSONArray;
import org.json.me.JSONException;
import org.json.me.JSONObject;

import com.pubnub.asynchttp.AsyncHttpManager;
import com.pubnub.asynchttp.HttpCallback;
import com.pubnub.crypto.me.PubnubCrypto;


public class Pubnub {

	private String ORIGIN = "pubsub.pubnub.com";
	private String PUBLISH_KEY = "";
	private String SUBSCRIBE_KEY = "";
	private String SECRET_KEY = "";
	private String CIPHER_KEY = "";
	private boolean SSL = false;
	private String UUID = null;
	private Hashtable _headers;
	private Subscriptions  subscriptions;
	
	private AsyncHttpManager longPollConnManager;
	private AsyncHttpManager simpleConnManager;

	private String uuid() {
		return "abcd-efgh-jikl-mnop";
	}

	/**
	 * PubNub 3.1 with Cipher Key
	 * 
	 * Prepare PubNub State.
	 * 
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 * @param String
	 *            Secret Key.
	 * @param String
	 *            Cipher Key.
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
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 * @param String
	 *            Secret Key.
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
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 */
	public Pubnub(String publish_key, String subscribe_key) {
		this.init(publish_key, subscribe_key, "", "", false);
	}

	/**
	 * PubNub 3.0 without SSL
	 * 
	 * Prepare PubNub Class State.
	 * 
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 * @param String
	 *            Secret Key.
	 */
	public Pubnub(String publish_key, String subscribe_key, String secret_key) {
		this.init(publish_key, subscribe_key, secret_key, "", false);
	}

	/**
	 * Init
	 * 
	 * Prepare PubNub Class State.
	 * 
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 * @param String
	 *            Secret Key.
	 * @param String
	 *            Cipher Key.
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

		if (UUID == null)
			UUID = uuid();

		if (subscriptions == null)
			subscriptions = new Subscriptions();
		
		if (longPollConnManager == null)
			longPollConnManager = new AsyncHttpManager("Subscribe/Presence");
		
		if (simpleConnManager == null)
			simpleConnManager = new AsyncHttpManager("Simple");

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
	 * @param String
	 *            channel name.
	 * @param JSONObject
	 *            message.
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
	 * @param String
	 *            channel name.
	 * @param JSONObject
	 *            message.
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
	 * @param HashMap
	 *            <String, Object> containing channel name, message.
	 * @return JSONArray.
	 */
	public void publish(Hashtable args) {

		final String channel = (String) args.get("channel");
		Object message = args.get("message");
		final Callback callback = (Callback) args.get("callback");
		System.out.println("CIPHER KEY length : " + this.CIPHER_KEY.length());
		if (message instanceof JSONObject) {
			JSONObject obj = (JSONObject) message;
			
			if (this.CIPHER_KEY.length() > 0) {
				System.out.println("CIPHER KEY length : " + this.CIPHER_KEY.length());
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
			string_to_sign.append(this.PUBLISH_KEY).append('/')
					.append(this.SUBSCRIBE_KEY).append('/')
					.append(this.SECRET_KEY).append('/').append(channel)
					.append('/').append(message.toString());

			// Sign Message
			signature = PubnubCrypto.getHMacSHA256(this.SECRET_KEY,
					string_to_sign.toString());
		}

		String[] urlComponents = { this.ORIGIN, "publish", this.PUBLISH_KEY,
				this.SUBSCRIBE_KEY, signature, channel, "0", PubnubUtil.urlEncode(message.toString())};

		Request req = new Request(urlComponents, channel,
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
						JSONArray jsarr = new JSONArray();
						jsarr.put("0").put("Error: Failed JSON HTTP Request");
						callback.errorCallback(channel, jsarr);
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
		
		channelMissing = ((_channel == null || _channel.equals("")) &&
						  (_channels == null || _channels.equals("")))?true:false;
		
		if (channelMissing) {
			throw new PubnubException("Channel Missing");
		}
		return true;
	}

	/**
	 * Subscribe
	 * 
	 * Listen for a message on a channel.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback.
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
	 * Subscribe
	 * 
	 * Listen for a message on a channel.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback.
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
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback.
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
	 * Subscribe - Private Interface
	 * 
	 * Patch provided by petereddy on GitHub
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback,
	 *            timetoken.
	 */
	private void _subscribe(Hashtable args) {

		String[] channelList = (String[]) args.get("channels");
		if (channelList == null) {
			channelList = new String[]{(String) args.get("channel")};
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
			System.out.println(channel);
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


	private void _subscribe_base(String timetoken) {
		System.out.println("In _subscribe_base");
		String channelString = subscriptions.getChannelString();
		String[] channelsArray = subscriptions.getChannelNames();

		if (channelString == null) {
			callErrorCallbacks(channelsArray, "Parsing Error");
			return;
		}

		String[] urlComponents = { Pubnub.this.ORIGIN, "subscribe",
				Pubnub.this.SUBSCRIBE_KEY, channelString, "0", timetoken };

		Hashtable params = new Hashtable();
		params.put("uuid", uuid());

		Request req = new Request(urlComponents, params, channelsArray,
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
							String _timetoken = jsa.get(1).toString();
							JSONArray messages = new JSONArray(jsa.get(0)
									.toString());

							if (jsa.length() > 2) {
								/*
								 * Response has multiple channels
								 */

								String[] _channels = PubnubUtil.splitString(
										jsa.getString(2), ",");
								System.out.println(_channels.length);

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
								Channel _channel = subscriptions.getFirstChannel();

								if (_channel != null) {
								for (int i = 0; i < messages.length(); i++) {
									_channel.callback.successCallback(
											_channel.name, messages.get(i));
								}
								}

							}
							_subscribe_base(_timetoken);
						} catch (JSONException e) {
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
	 * Request URL
	 * 
	 * @param List
	 *            <String> request of url directories.
	 * @return JSONArray from JSON response.
	 */
	private void _request(final Request req, AsyncHttpManager connManager) {
		
		HttpCallback callback = new HttpCallback(req.getUrl(), _headers) {
			public void OnComplete(HttpConnection hc, int statusCode,
					String response) throws IOException {
				System.out.println(response);
				req.responseHandler.handleResponse(response);
			}

			public void errorCall(HttpConnection conn, int statusCode,
					String response) throws IOException {
				System.out.println(response);
				req.responseHandler.handleError(response);

			}
		};
		connManager.queue(callback);
	}

}
