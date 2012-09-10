package pubnub.api;

import com.ning.http.client.*;
import com.ning.http.client.AsyncHttpClientConfig.Builder;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.*;
import java.util.concurrent.Future;
import java.util.zip.GZIPInputStream;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Iterator;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.Mac;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * PubNub 3.2 Real-time Push Cloud API
 * 
 * @author Stephen Blum 3.1
 * @author Leonardo Redmond 3.2 Revision
 * @package pubnub.api
 */
public class Pubnub {
	private String ORIGIN = "pubsub.pubnub.com";
	private String PUBLISH_KEY = "";
	private String SUBSCRIBE_KEY = "";
	private String SECRET_KEY = "";
	public String CIPHER_KEY = "";
	private boolean SSL = false;
	private String sessionUUID = "";
	private String parameters = "";
	
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
	 * PubNub 3.0
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
	public void init(String publish_key, String subscribe_key,
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
			// System.out.println();
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

		return _request(url);
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
				boolean is_disconnect = false;
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
							if (it.connected && it.first) {
								subscriptions.remove(it);
								callback.disconnectCallback(channel);
							} else {
								subscriptions.remove(it);
								callback.errorCallback(channel,
										"Lost Network Connection");
							}
						}

					}
					// Ensure Connected (Call Time Function)
					boolean is_reconnected = false;
					while (true) {
						double time_token = this.time();
						if (time_token == 0.0) {

							Thread.sleep(5000);
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

				for (int i = 0; messages.length() > i; i++) {
					JSONObject message = messages.optJSONObject(i);
					if (message != null) {

						if (this.CIPHER_KEY.length() > 0) {
							// Decrypt Message
							PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
							message = pc.decrypt(message);
						}
						if (callback != null)
							if (!callback.subscribeCallback(channel, message)) return;
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
								if(!callback.subscribeCallback(channel, arr)) return;
						} else {
							String msgs = messages.getString(0);
							if (this.CIPHER_KEY.length() > 0) {
								PubnubCrypto pc = new PubnubCrypto(
										this.CIPHER_KEY);
								msgs = pc.decrypt(msgs);
							}
							if (callback != null)
								if(!callback.subscribeCallback(channel, msgs)) return;
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
	 * Presence
	 * 
	 * Listen for a message on a channel & add presence info.
	 * 
	 * @param String
	 *            channel name.
	 * @param Callback
	 *            function callback.
	 */
	public void presence(String channel, Callback callback) {
		HashMap<String, Object> args = new HashMap<String, Object>(2);
		args.put("channel", channel + "-pnpres");
		args.put("callback", callback);
		subscribe(args);
	}

	/**
	 * Presence
	 * 
	 * Listen for a message on a channel & add presence info.
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback.
	 */
	public void presence(HashMap<String, Object> args) {
		args.put("timetoken", "0");
		this._presence(args);
	}

	/**
	 * Presence - Private Interface
	 * 
	 * Implemented by Leonardo Redmond on GitHub
	 * 
	 * @param HashMap
	 *            <String, Object> containing channel name, function callback,
	 *            timetoken.
	 */
	private void _presence(HashMap<String, Object> args) {

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
				boolean is_disconnect = false;
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
							if (it.connected && it.first) {
								subscriptions.remove(it);
								callback.disconnectCallback(channel);
							} else {
								subscriptions.remove(it);
								callback.errorCallback(channel,
										"Lost Network Connection");
							}
						}

					}
					// Ensure Connected (Call Time Function)
					boolean is_reconnected = false;
					while (true) {
						double time_token = this.time();
						if (time_token == 0.0) {

							Thread.sleep(5000);
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

				for (int i = 0; messages.length() > i; i++) {
					JSONObject message = messages.optJSONObject(i);
					if (message != null) {

						if (this.CIPHER_KEY.length() > 0) {
							// Decrypt Message
							PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
							message = pc.decrypt(message);
						}
						if (callback != null)
							if(!callback.presenceCallback(channel, message)) return;
					} else {

						JSONArray arr = messages.optJSONArray(i);
						if (arr != null) {
							if (this.CIPHER_KEY.length() > 0) {
								PubnubCrypto pc = new PubnubCrypto(
										this.CIPHER_KEY);
								arr = pc.decryptJSONArray(arr);
							}
							if (callback != null)
								if (!callback.presenceCallback(channel, arr)) return;
						} else {
							String msgs = messages.getString(0);
							if (this.CIPHER_KEY.length() > 0) {
								PubnubCrypto pc = new PubnubCrypto(
										this.CIPHER_KEY);
								msgs = pc.decrypt(msgs);
							}
							if (callback != null)
								if (!callback.presenceCallback(channel, msgs)) return;
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
	 * Here Now
	 * 
	 * Load presence information from a channel
	 * 
	 * @param String channel name.
	 * @return JSONObject of here_now
	 */
	public JSONArray here_now(String channel) {
		List<String> url = new ArrayList<String>();

		url.add("v2");
		url.add("presence");
		url.add("sub_key");
		url.add(this.SUBSCRIBE_KEY);
		url.add("channel");
		url.add(channel);
		
		JSONArray response = _request(url);

		if (this.CIPHER_KEY.length() > 0) {
			// Decrypt Messages
			PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
			return pc.decryptJSONArray(response);
		} else {
			return response;
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

		JSONArray response = _request(url);

		if (this.CIPHER_KEY.length() > 0) {
			// Decrypt Messages
			PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
			return pc.decryptJSONArray(response);
		} else {
			return response;
		}
	}
	
	/**
	 * DetailedHistory
	 * 
	 * DetailedHistory from PubNub Cloud.
	 * 
	 * @return JSONArray of detailed history.
	 */
	public JSONArray detailedHistory(String channel, long start, long end, int count, Boolean reverse) {
		parameters = "";
		if (count == -1) count = 100;
		if (count == -1) count = 100;
        parameters = "?count=" + count;
        if (reverse)
            parameters = parameters + "&" + "reverse=" + reverse.toString().toLowerCase();
        if (start != -1)
            parameters = parameters + "&" + "start=" + Long.toString(start).toLowerCase();
        if (end != -1)
            parameters = parameters + "&" + "end=" + Long.toString(end).toLowerCase();
        
        List<String> url = new ArrayList<String>();
        url.add("v2");
        url.add("history");
        url.add("sub-key");
        url.add(this.SUBSCRIBE_KEY);
        url.add("channel");
        url.add(channel);
        
        JSONArray response = _request(url);
        
        if (this.CIPHER_KEY.length() > 0) {
        	PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
        	try {
				return pc.decryptJSONArray(response.getJSONArray(0));
			} catch (JSONException e) {
				return response;
			}
        } else {
        	return response;
        }
	}
	
	public JSONArray detailedHistory(String channel, long start, boolean reverse) {
		return detailedHistory(channel, start, -1, -1, reverse);
	}

	public JSONArray detailedHistory(String channel, int count) {
		return detailedHistory(channel, -1, -1, count, false);
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
	}

	/**
	 * Request URL
	 * 
	 * @param List
	 *            <String> request of url directories.
	 * @return JSONArray from JSON response.
	 */
	private JSONArray _request(List<String> url_components) {
		String json = "";
		StringBuilder url = new StringBuilder();
		Iterator<String> url_iterator = url_components.iterator();
		String request_for = url_components.get(0);
		String request_type = url_components.get(1);
		
		url.append(this.ORIGIN);

		// Generate URL with UTF-8 Encoding
		while (url_iterator.hasNext()) {
			try {
				String url_bit = (String) url_iterator.next();
				url.append("/").append(_encodeURIcomponent(url_bit));
			} catch (Exception e) {
				// e.printStackTrace();
				JSONArray jsono = new JSONArray();
				try {
					jsono.put("Failed UTF-8 Encoding URL.");
				} catch (Exception jsone) {
				}
				return jsono;
			}
		}
		if (request_for.equals("subscribe") || request_for.equals("presence"))
			url.append("?uuid=").append(this.sessionUUID);
		if (request_for.equals("v2") && request_type.equals("history"))
			url.append(parameters);
		
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

			// Execute Request
			Future<String> f = ahc.executeRequest(request,
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
			ahc.close();

		} catch (Exception e) {

			// Response If Failed JSONP HTTP Request.
			JSONArray jsono = new JSONArray();
			try {
				if (request_for != null) {
					if (request_for.equals("time")) {
						jsono.put("0");
					} else if (request_for.equals("history")) {
						jsono.put("Error: Failed JSONP HTTP Request.");
					} else if (request_for.equals("publish")) {
						jsono.put("0");
						jsono.put("Error: Failed JSONP HTTP Request.");
					} else if (request_for.equals("subscribe")) {
						jsono.put("0");
						jsono.put("0");
					}
				}
			} catch (Exception jsone) {
			}

			if (ahc != null) {
				ahc.close();
			}
			return jsono;
		}

		// Parse JSON String
		try {
			if (json.contains("uuids")) {
				JSONArray resp = new JSONArray();
				resp.put(json);
				return resp;
			}
			return new JSONArray(json);
		} catch (Exception e) {
			JSONArray jsono = new JSONArray();

			try {
				jsono.put("Error: Failed JSON Parsing.");
			} catch (Exception jsone) {
			}

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
	private static char[]    map1 = new char[64];
	   static {
	      int i=0;
	      for (char c='A'; c<='Z'; c++) map1[i++] = c;
	      for (char c='a'; c<='z'; c++) map1[i++] = c;
	      for (char c='0'; c<='9'; c++) map1[i++] = c;
	      map1[i++] = '+'; map1[i++] = '/'; 
	   }

	// Mapping table from Base64 characters to 6-bit nibbles.
	private static byte[]    map2 = new byte[128];
	   static {
	      for (int i=0; i<map2.length; i++) map2[i] = -1;
	      for (int i=0; i<64; i++) map2[map1[i]] = (byte)i; 
	   }

	/**
	* Encodes a string into Base64 format.
	* No blanks or line breaks are inserted.
	* 
	* @param s  a String to be encoded.
	* @return   A String with the Base64 encoded data.
	*/
	public static String encodeString (String s) {
	   return new String(encode(s.getBytes())); 
	}

	/**
	* Encodes a byte array into Base64 format.
	* No blanks or line breaks are inserted.
	* 
	* @param in  an array containing the data bytes to be encoded.
	* @return    A character array with the Base64 encoded data.
	*/
	public static char[] encode (byte[] in) {
	   return encode(in,in.length); 
	}

	/**
	* Encodes a byte array into Base64 format.
	* No blanks or line breaks are inserted.
	* 
	* @param in   an array containing the data bytes to be encoded.
	* @param iLen number of bytes to process in <code>in</code>.
	* @return     A character array with the Base64 encoded data.
	*/
	public static char[] encode (byte[] in, int iLen) {
	   int oDataLen = (iLen*4+2)/3;       // output length without padding
	   int oLen = ((iLen+2)/3)*4;         // output length including padding
	   char[] out = new char[oLen];
	   int ip = 0;
	   int op = 0;
	   while (ip < iLen) {
	      int i0 = in[ip++] & 0xff;
	      int i1 = ip < iLen ? in[ip++] & 0xff : 0;
	      int i2 = ip < iLen ? in[ip++] & 0xff : 0;
	      int o0 = i0 >>> 2;
	      int o1 = ((i0 &   3) << 4) | (i1 >>> 4);
	      int o2 = ((i1 & 0xf) << 2) | (i2 >>> 6);
	      int o3 = i2 & 0x3F;
	      out[op++] = map1[o0];
	      out[op++] = map1[o1];
	      out[op] = op < oDataLen ? map1[o2] : '='; op++;
	      out[op] = op < oDataLen ? map1[o3] : '='; op++; }
	   return out; 
	}

	/**
	* Decodes a string from Base64 format.
	* 
	* @param s  a Base64 String to be decoded.
	* @return   A String containing the decoded data.
	* @throws   IllegalArgumentException if the input is not valid Base64 encoded data.
	*/
	public static String decodeString (String s) {
	   return new String(decode(s)); 
	}

	/**
	* Decodes a byte array from Base64 format.
	* 
	* @param s  a Base64 String to be decoded.
	* @return   An array containing the decoded data bytes.
	* @throws   IllegalArgumentException if the input is not valid Base64 encoded data.
	*/
	public static byte[] decode (String s) {
	   return decode(s.toCharArray()); 
	}

	/**
	* Decodes a byte array from Base64 format.
	* No blanks or line breaks are allowed within the Base64 encoded data.
	* 
	* @param in  a character array containing the Base64 encoded data.
	* @return    An array containing the decoded data bytes.
	* @throws    IllegalArgumentException if the input is not valid Base64 encoded data.
	*/
	public static byte[] decode (char[] in) {
	   int iLen = in.length;
	   if (iLen%4 != 0) throw new IllegalArgumentException ("Length of Base64 encoded input string is not a multiple of 4.");
	   while (iLen > 0 && in[iLen-1] == '=') iLen--;
	   int oLen = (iLen*3) / 4;
	   byte[] out = new byte[oLen];
	   int ip = 0;
	   int op = 0;
	   while (ip < iLen) {
	      int i0 = in[ip++];
	      int i1 = in[ip++];
	      int i2 = ip < iLen ? in[ip++] : 'A';
	      int i3 = ip < iLen ? in[ip++] : 'A';
	      if (i0 > 127 || i1 > 127 || i2 > 127 || i3 > 127)
	         throw new IllegalArgumentException ("Illegal character in Base64 encoded data.");
	      int b0 = map2[i0];
	      int b1 = map2[i1];
	      int b2 = map2[i2];
	      int b3 = map2[i3];
	      if (b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0)
	         throw new IllegalArgumentException ("Illegal character in Base64 encoded data.");
	      int o0 = ( b0       <<2) | (b1>>>4);
	      int o1 = ((b1 & 0xf)<<4) | (b2>>>2);
	      int o2 = ((b2 &   3)<<6) |  b3;
	      out[op++] = (byte)o0;
	      if (op<oLen) out[op++] = (byte)o1;
	      if (op<oLen) out[op++] = (byte)o2; }
	   return out; 
	}

	/**
	 * This class is not instantiate.
	 */
	private Base64Encoder() {}
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
     * @param JSONObject Message to encrypt
     * @return JSONObject as Encrypted message
     */
    @SuppressWarnings("unchecked")
	public JSONObject encrypt(JSONObject message) {
    	try {
    		JSONObject message_encrypted = new JSONObject();
        	Iterator<String> it = message.keys();
        	
	    	while(it.hasNext()) {
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
     * @param JSONObject Encrypted message
     * @return JSONObject Message decrypted
     */
    @SuppressWarnings("unchecked")
	public JSONObject decrypt(JSONObject message_encrypted) {
    	try {
    		JSONObject message_decrypted = new JSONObject();
        	Iterator<String> it = message_encrypted.keys();
        	
	    	while(it.hasNext()) {
	    		String key = it.next();
	    		String encrypted_str = message_encrypted.getString(key);
	    		String decrypted_str = decrypt(encrypted_str);
	    		message_decrypted.put(key, decrypted_str);
	    	}
	    	return message_decrypted;
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Encrypt JSONArray
     * 
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray encryptJSONArray(JSONArray jsona_arry) {
    	try {
    		JSONArray jsona_decrypted = new JSONArray();
    		
    		for (int i = 0; i < jsona_arry.length(); i++) {
				 Object o = jsona_arry.get(i);
				 if(o != null) {
					 if(o instanceof JSONObject) {
						 jsona_decrypted.put(i, encrypt((JSONObject)o));
					 } else if(o instanceof JSONArray) {
						 jsona_decrypted.put(i, encryptJSONArray((JSONArray)o));
					 } else if(o instanceof String) {
						 jsona_decrypted.put(i, encrypt(o.toString()));
					 }
				 }
			}
    		
    		return jsona_decrypted;
    		
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Decrypt JSONArray
     * 
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray decryptJSONArray(JSONArray jsona_encrypted) {
    	try {
    		JSONArray jsona_decrypted = new JSONArray();
    		
    		for (int i = 0; i < jsona_encrypted.length(); i++) {
				 Object o = jsona_encrypted.get(i);
				 if(o != null) {
					 if(o instanceof JSONObject) {
						 jsona_decrypted.put(i, decrypt((JSONObject)o));
					 } else if(o instanceof JSONArray) {
						 jsona_decrypted.put(i, decryptJSONArray((JSONArray)o));
					 } else if(o instanceof String) {
						 jsona_decrypted.put(i, decrypt(o.toString()));
					 }
				 }
			}
    		
    		return jsona_decrypted;
    		
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Encrypt
     * 
     * @param String plain text to encrypt
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
     * @param String cipherText
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
     * @param ByteArray input_bytes
     * @return ByteArray
     * @throws Exception
     */
    private byte[] transform(boolean encrypt_or_decrypt, byte[] input_bytes) throws Exception {  
    	ByteArrayOutputStream output = new ByteArrayOutputStream();
    	byte[] iv_bytes = "0123456789012345".getBytes();
    	byte[] key_bytes = md5(this.CIPHER_KEY);

    	SecretKeySpec key = new SecretKeySpec(key_bytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv_bytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

        if(encrypt_or_decrypt) {
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
     * @param String input
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
	 * @param string
	 * @return
	 */
	public static byte[] md5(String string) { 
	    byte[] hash; 
	 
	    try { 
	        hash = MessageDigest.getInstance("MD5").digest(string.getBytes("UTF-8")); 
	    } catch (NoSuchAlgorithmException e) { 
	        throw new RuntimeException("MD5 should be supported!", e); 
	    } catch (UnsupportedEncodingException e) { 
	        throw new RuntimeException("UTF-8 should be supported!", e); 
	    } 
	 
	    StringBuilder hex = new StringBuilder(hash.length * 2); 
	    for (byte b : hash) { 
	        if ((b & 0xFF) < 0x10) hex.append("0"); 
	        hex.append(Integer.toHexString(b & 0xFF)); 
	    }
	    return hexStringToByteArray(hex.toString());
	}
	
	public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i+1), 16));
        }
        return data;
    }
}