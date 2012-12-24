package com.sample.pubnubunittest.pubnub;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
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
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import pubnub.PubnubCrypto;

/**
 * PubNub 3.3 Real-time Push Cloud API
 * 
 * @author Stephen Blum
 * @package pubnub
 */
public class Pubnub {
	private String ORIGIN = "pubsub.pubnub.com";
	private String PUBLISH_KEY = "";
	private String SUBSCRIBE_KEY = "";
	private String SECRET_KEY = "";
	private String CIPHER_KEY = "";
	private boolean SSL = false;
	private String UUIDs = null;

	private class ChannelStatus {
		String channel;
		boolean connected, first;
	}

	private List<ChannelStatus> subscriptions;
	private Hashtable<String, Object> connection = new Hashtable<String, Object>();

	/**
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
	 * 
	 * @param String uuid.
	 */
	public Pubnub(String publish_key, String subscribe_key, String secret_key,
			String cipher_key, boolean ssl_on,String uuid) {
		this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on,uuid);
	}
	
	/**
	 * PubNub 3.2 with Presence
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
		this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on,uuid());
	}

	/**
	 * PubNub 3.0 Compatibility
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
		this.init(publish_key, subscribe_key, secret_key, "", ssl_on,uuid());
	}

	/**
	 * PubNub 2.0 Compatibility
	 * 
	 * Prepare PubNub Class State.
	 * 
	 * @param String
	 *            Publish Key.
	 * @param String
	 *            Subscribe Key.
	 */
	public Pubnub(String publish_key, String subscribe_key) {
		this.init(publish_key, subscribe_key, "", "", false,uuid());
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
		this.init(publish_key, subscribe_key, secret_key, "", false,uuid());
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
	public void init(String publish_key, String subscribe_key,
			String secret_key, String cipher_key, boolean ssl_on,String uuid) {
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
		UUIDs = uuid;
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
	 * @return JSONArray
	 */
	public JSONArray publish(String channel, JSONObject message) {
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("message", message);
		return publish(args);
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
	public JSONArray publish(HashMap<String, Object> args) {

		String channel = (String) args.get("channel");
		Object message = args.get("message");

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
		}
		System.out.println();

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
		List<String> url = new ArrayList<String>();
		url.add("publish");
		url.add(this.PUBLISH_KEY);
		url.add(this.SUBSCRIBE_KEY);
		url.add(signature);
		url.add(channel);
		url.add("0");
		url.add(message.toString());

		// Return JSONArray
		return _request(url, channel);
	}

	/**
	 * Subscribe
	 * 
	 * Listen for a message on a channel.
	 * 
	 * @param String
	 *            channel name.
	 * @param Callback
	 *            function callback.
	 */
	public void subscribe(String channel, Callback callback) {
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("callback", callback);
		subscribe(args);
	}

	/**
	 * Subscribe
	 * 
	 * Listen for a message on a channel.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback.
	 */
	public void subscribe(HashMap<String, Object> args) {
		args.put("timetoken", "0");
		this._subscribe(args);
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
	private void _subscribe(HashMap<String, Object> args) {

		String channel = (String) args.get("channel");
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
			callback.errorCallback(channel, "Invalid Channel.");
			return;
		}

		// Ensure Single Connection
		if (subscriptions != null && subscriptions.size() > 0) {
			boolean channel_exist = false;
			for (ChannelStatus it : subscriptions) {
				if (it.channel.equals(channel)) {
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
				callback.errorCallback(channel, "Already Connected");
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
				List<String> url = java.util.Arrays.asList("subscribe",
						this.SUBSCRIBE_KEY, channel, "0", timetoken);

				// Stop Connection?
				boolean isDisconnected = false;
				for (ChannelStatus it : subscriptions) {
					if (it.channel.equals(channel)) {
						if (!it.connected) {
							callback.disconnectCallback(channel);
							isDisconnected = true;
							subscriptions.remove(it);
							leave(channel);
							break;
						}
					}
				}
				if (isDisconnected)
					return;

				// Wait for Message
				JSONArray response = _request(url, channel);

				// Stop Connection?
				for (ChannelStatus it : subscriptions) {
					if (it.channel.equals(channel)) {
						if (!it.connected) {
							callback.disconnectCallback(channel);
							isDisconnected = true;
							subscriptions.remove(it);
							leave(channel);
							break;
						}
					}
				}

				if (isDisconnected)
					return;

				// Problem?
				if (response == null || response.optInt(1) == 0) {
					for (ChannelStatus it : subscriptions) {
						if (it.channel.equals(channel)) {
							if (it.connected && it.first) {
								subscriptions.remove(it);
								callback.disconnectCallback(channel);
								leave(channel);
							} else {
								subscriptions.remove(it);
								callback.errorCallback(channel,
										"No Network Connection");
							}
							break;
						}
					}
					// Ensure Connected (Call Time Function)
					boolean isReconnected = false;
					while (true) {
						double time_token = this.time();
						if (time_token == 0.0) {

							Thread.sleep(5000);
						} else {
							// Reconnect Callback
							callback.reconnectCallback(channel);
							isReconnected = true;
							break;
						}
					}
					if (isReconnected) {
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

				boolean returnval = true;
				for (int i = 0; messages.length() > i; i++) {
					JSONObject message = messages.optJSONObject(i);
					if (message != null) {

						if (this.CIPHER_KEY.length() > 0) {
							// Decrypt Message
							PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
							message = pc.decrypt(message);
						}
						if (callback != null)
						{
							returnval=callback.subscribeCallback(channel, message);
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
								returnval=callback.subscribeCallback(channel, arr);
						} else {
							String msgs = messages.getString(0);
							if (this.CIPHER_KEY.length() > 0) {
								PubnubCrypto pc = new PubnubCrypto(
										this.CIPHER_KEY);
								msgs = pc.decrypt(msgs);
							}
							if (callback != null)
								returnval=callback.subscribeCallback(channel, msgs);
						}
					}
				}
				
				if(!returnval)
				{
					break;
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
	 * History
	 * 
	 * Load history from a channel.
	 * 
	 * @param String
	 *            channel name.
	 * @param int limit history count response.
	 * @return JSONArray of history.
	 */
	public JSONArray history(String channel, int limit) {
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel);
		args.put("limit", limit);
		return history(args);
	}

	/**
	 * Detailed History
	 * 
	 * Load Detailed history from a channel.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, with optional:
	 *            'start', 'end', 'reverse', 'count'.
	 * @return JSONArray of history.
	 */
	public JSONArray detailedHistory(HashMap<String, Object> args) {

		String channel = (String) args.get("channel");

		if (channel == null || channel.equals("")) {

			System.out.println("Missing Channel");
		}

		StringBuilder parameter = new StringBuilder("?");
		int count = 100;

		if (args.get("count") != null) {
			count = (Integer) args.get("count");
		}

		parameter.append("count=" + count);

		if (args.get("reverse") != null) {
			boolean reverse = (Boolean) args.get("reverse");
			if (reverse)
				parameter.append("&reverse=true");
			else
				parameter.append("&reverse=false");
		}

		if (args.get("start") != null) {
			parameter.append("&start=").append((String) args.get("start"));
		}

		if (args.get("end") != null) {
			parameter.append("&end=").append((String) args.get("end"));
		}

		List<String> url = new ArrayList<String>();
		url.add("v2");
		url.add("history");
		url.add("sub-key");
		url.add(this.SUBSCRIBE_KEY);
		url.add("channel");
		url.add(channel);
		url.add(parameter.toString());
		JSONArray responce = _request(url, channel);

		if (this.CIPHER_KEY.length() > 0) {

			try {
				JSONArray messageArray = responce.getJSONArray(0);
				PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
				messageArray = pc.decryptJSONArray(messageArray);
				responce.put(0, messageArray);
			} catch (JSONException e) {
				
				e.printStackTrace();
			}

			// Decrpyt Messages

			return responce;
		} else {
			return _request(url, channel);
		}
	}

	/**
	 * History
	 * 
	 * Load history from a channel.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, limit history count
	 *            response.
	 * @return JSONArray of history.
	 */
	public JSONArray history(HashMap<String, Object> args) {

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
			return pc.decryptJSONArray(_request(url, channel));
		} else {
			return _request(url, channel);
		}
	}

	/**
	 * Here Now
	 * 
	 * Load current occupancy from a channel
	 * 
	 * @param HashMap
	 *            <String, Object> args with channel.
	 */
	public JSONArray here_now(HashMap<String, Object> args) {
		String channel = (String) args.get("channel");
		// Validate Arguments

		if (channel == null || channel.equals("")) {
			JSONArray jsono = new JSONArray();
			try {
				jsono.put(0);
				jsono.put("Missing Channel");
			} catch (Exception jsone) {
			}
			return jsono;
		}

		// Build URL
		List<String> url = new ArrayList<String>();
		url.add("v2");
		url.add("presence");
		url.add("sub_key");
		url.add(this.SUBSCRIBE_KEY);
		url.add("channel");
		url.add(channel);

		// Return JSONArray
		return _request(url, channel);

	}
	
	public JSONArray leave(String channel) {
		if (channel == null || channel.equals("")) {
			JSONArray jsono = new JSONArray();
			try {
				jsono.put(0);
				jsono.put("Missing Channel");
			} catch (Exception jsone) {
			}
			return jsono;
		}

		// Build URL
		List<String> url = new ArrayList<String>();
		url.add("v2");
		url.add("presence");
		url.add("sub_key");
		url.add(this.SUBSCRIBE_KEY);
		url.add("channel");
		url.add(channel);
		url.add("leave");
		// Return JSONArray
		return _request(url, channel);

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

		JSONArray response = _request(url, null);
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
	 * @param HashMap
	 *            <String, Object> containing channel name.
	 */
	public void unsubscribe(HashMap<String, Object> args) {
		String channel = (String) args.get("channel");
		for (ChannelStatus it : subscriptions) {
			if (it.channel.equals(channel) && it.connected) {
				it.connected = false;
				it.first = false;
				break;
			}
		}
		Enumeration<String> e = connection.keys();
		while (e.hasMoreElements()) {

			String ch = (String) e.nextElement();
			if (ch.equals(channel)) {
				HttpClient http = (HttpClient) connection.get(ch);
				http.getConnectionManager().shutdown();
				if (connection.containsKey(ch))
					connection.remove(ch);
			}
		}
	}

	/**
	 * Request URL
	 * 
	 * @param List
	 *            <String> request of url directories.
	 * @return JSONArray from JSON response.
	 */
	private JSONArray _request(List<String> url_components, String channel) {
		String json = "";
		StringBuilder url = new StringBuilder();
		Iterator<String> url_iterator = url_components.iterator();
		String _callFor = url_components.get(0);

		if (_callFor.equalsIgnoreCase("v2")) {
			_callFor = url_components.get(1);
			if(url_components.size()>=6 && url_components.get(6).equals("leave"))
			{
				_callFor="leave";
			}
		}

		url.append(this.ORIGIN);

		// Generate URL with UTF-8 Encoding
		while (url_iterator.hasNext()) {
			try {
				String url_bit = (String) url_iterator.next();
				if (url_bit.startsWith("?")) {
					url.append(url_bit);
				} else {
					url.append("/").append(_encodeToUTF8(url_bit));
				}
			} catch (Exception e) {
				e.printStackTrace();
				JSONArray jsono = new JSONArray();
				try {
					jsono.put(0);
					jsono.put("Failed UTF-8 Encoding URL.");
				} catch (Exception jsone) {
				}
				return jsono;
			}
		}
		if (_callFor.equalsIgnoreCase("subscribe")) {
			url.append("/").append("?uuid=" + UUIDs);
		}
		if (_callFor.equalsIgnoreCase("leave")) {
			url.append("?uuid=" + UUIDs);
		}
		try {

			PubnubHttpRequest request = new PubnubHttpRequest(url.toString(),
					channel);
			FutureTask<String> task = new FutureTask<String>(request);
			Thread t = new Thread(task);
			t.start();
			try {
				json = task.get();
			} catch (Exception e) {
				JSONArray jsono = new JSONArray();

				try {
					jsono.put(0);
					jsono.put("Request failed due to missing Internet connection.");
				} catch (Exception jsone) {
				}

				System.out.println(e.getMessage());

				return jsono;
			}

		} catch (Exception e) {

			JSONArray jsono = new JSONArray();

			try {
				jsono.put(0);
				jsono.put("Failed JSONP HTTP Request.");
			} catch (Exception jsone) {
			}

			System.out.println(e.getMessage());

			return jsono;
		}
		if (_callFor.equalsIgnoreCase("presence") || _callFor.equalsIgnoreCase("leave")) {
			try {
				JSONArray arr = new JSONArray();

				arr.put(new JSONObject(json));

				json = arr.toString();
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		// Parse JSON String
		try {
			return new JSONArray(json);
		} catch (Exception e) {
			JSONArray jsono = new JSONArray();

			try {
				jsono.put(0);
				jsono.put("Failed JSON Parsing.");
			} catch (Exception jsone) {
			}

			System.out.println(e.getMessage());

			// Return Failure to Parse
			return jsono;
		}
	}

	private class PubnubHttpRequest implements Callable<String> {

		String url, channel;

		public PubnubHttpRequest(String url, String channel) {
			this.url = url;
			this.channel = channel;
		}

		@Override
		public String call() throws Exception {
			// Prepare request
			String line = "", json = "";
			HttpParams httpParams = new BasicHttpParams();
			HttpConnectionParams.setConnectionTimeout(httpParams, 3000);
			HttpConnectionParams.setSoTimeout(httpParams, 310000);
			HttpClient httpclient = new DefaultHttpClient(httpParams);
			HttpUriRequest request = new HttpGet(url);
			request.setHeader("V", "3.3");
			request.setHeader("User-Agent", "Java-Android");
			request.setHeader("Accept-Encoding", "gzip");
			if (channel != null) {
				connection.put(channel, httpclient);
			}
			// Execute request
			HttpResponse response;
			response = httpclient.execute(request);

			HttpEntity entity = response.getEntity();
			if (entity != null) {

				// A Simple JSON Response Read
				InputStream instream = entity.getContent();
				BufferedReader reader = null;

				// Gzip decoding
				Header contentEncoding = response
						.getFirstHeader("Content-Encoding");
				if (contentEncoding != null
						&& contentEncoding.getValue().equalsIgnoreCase("gzip")) {
					reader = new BufferedReader(new InputStreamReader(
							new GZIPInputStream(instream)));
				} else {
					reader = new BufferedReader(new InputStreamReader(instream));
				}

				// Read JSON Message
				while ((line = reader.readLine()) != null) {
					json += line;
				}
				reader.close();
			}
			if (channel != null) {
				connection.remove(channel);
			}
			return json;
		}
	}

	private String _encodeToUTF8(String s) throws UnsupportedEncodingException {
		String enc = URLEncoder.encode(s, "UTF-8").replace("+", "%20");
		return enc;
	}

}
