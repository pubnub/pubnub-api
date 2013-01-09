package com.pubnub.examples;

import java.util.Hashtable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

public class PubnubExample {

	String channel = "hello_world";
	String[] channels = { "hello_world1", "hello_world2", "hello_world3",
			"hello_world4" };

	public PubnubExample() {
	}

	Pubnub _pubnub = new Pubnub("demo", "demo", "demo", false);

	/**
	 * @param params
	 */
	public static void main(String[] params) {
		PubnubExample pex = new PubnubExample();
		System.out.println("\nRunning publish()");
		pex.publish();

		System.out.println("\nRunning history()");
		pex.history();

		System.out.println("\nRunning here_now()");
		pex.hereNow();

		System.out.println("\nRunning detailedHistory()");
		pex.detailedHistory();

		System.out.println("\nRunning presence()");
		pex.presence();

		System.out.println("\nRunning subscribe()");
		pex.subscribe();

	}

	private static void notifyUser(Object message) {
		try {
			if (message instanceof JSONObject) {
				JSONObject obj = (JSONObject) message;
				System.out.println("Received : " + obj.toString());
			} else if (message instanceof String) {
				String obj = (String) message;
				System.out.println("Received : " + obj);
			} else if (message instanceof JSONArray) {
				JSONArray obj = (JSONArray) message;
				System.out.println("Received : " + obj.toString());
			}
		} catch (Exception e) {

		}
	}

	public void publish() {
		try {
			JSONObject message = new JSONObject();
			message.put("some_key", "Java says hello, world!");

			Hashtable args = new Hashtable(2);
			args.put("channel", channel); // Channel Name
			args.put("message", message); // JSON Message
			_pubnub.publish(args, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message.toString());
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.toString());
				}
			});

		} catch (JSONException ex) {

		}
	}

	public void subscribe() {
		Hashtable args = new Hashtable(6);
		args.put("channels", channels);

		try {
			_pubnub.subscribe(args, new Callback() {
				public void connectCallback(String channel) {
					notifyUser("CONNECT on channel:" + channel);
				}

				public void disconnectCallback(String channel) {
					notifyUser("DISCONNECT on channel:" + channel);
				}

				public void reconnectCallback(String channel) {
					notifyUser("RECONNECT on channel:" + channel);
				}

				public void successCallback(String channel, Object message) {
					notifyUser(channel + " " + message.toString());
				}
			});

		} catch (Exception e) {

		}
	}

	public void unsubscribe() {
		Hashtable args = new Hashtable(1);
		args.put("channels", channels);
		_pubnub.unsubscribe(args);

	}

	public void time() {
		_pubnub.time(new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	public void history() {

		_pubnub.history(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	private void hereNow() {
		_pubnub.hereNow(channel, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	private void presence() {
		try {
			_pubnub.presence(channel, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message.toString());
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.toString());
				}
			});
		} catch (PubnubException e) {

		}
	}

	private void detailedHistory() {

		_pubnub.detailedHistory(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

}
