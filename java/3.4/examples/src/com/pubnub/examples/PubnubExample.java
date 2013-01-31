package com.pubnub.examples;

import java.util.Hashtable;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

public class PubnubExample {

	String channel = "hello_world1";
	String[] channels = { "hello_world1", "hello_world2", "hello_world3",
			"hello_world4" };

	public PubnubExample() {
	}

	Pubnub _pubnub = new Pubnub("demo", "demo",false);

	/**
	 * @param params
	 */
	public static void main(String[] params) {
		
		int counter = 0;		
		PubnubExample pex = new PubnubExample();
		
		pex._pubnub.setSubscribeTimeout(310000);
		pex._pubnub.setNonSubscribeTimeout(15000);
		/*
		while(true) {
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("\nRunning publish()");
		pex.publish();

		System.out.println("\nRunning history()");
		pex.history();

		System.out.println("\nRunning here_now()");
		pex.hereNow();

		System.out.println("\nRunning detailedHistory()");
		pex.detailedHistory();
		}

		System.out.println("\nRunning presence()");
		pex.presence();*/

		System.out.println("\nRunning subscribe()");
		pex.subscribe(new String[]{"hello_world" + "-" + String.valueOf(counter)});
		
		while (true) {
			counter = (counter + 1) % 9;
			try {
				//Thread.sleep((long) (Math.floor((Math.random())  % 17 ) * 1000));
				Thread.sleep(20000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.out.println("Calling disconnect and resubscribe");
			pex._pubnub.disconnectAndResubscribe();
			pex.subscribe(new String[]{"hello_world" + "-" + String.valueOf(counter)});
		}

	}

	private static void notifyUser(Object message) {
		System.out.println("Received : " + message.toString());
	}

	public void publish() {
		JSONObject message = new JSONObject();
		try {
			message.put("some_key", "Java says hello, world!");
		} catch (JSONException e) {
		}
		Hashtable args = new Hashtable(2);
		args.put("channel", channel); // Channel Name
		args.put("message", message); // JSON Message
		_pubnub.publish(args, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}
		});
	}

	public void subscribe(String[] channels) {
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
					notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
				}
				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
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
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}
		});
	}

	public void history() {

		_pubnub.history(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}
		});
	}

	private void hereNow() {
		_pubnub.hereNow(channel, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}
		});
	}

	private void presence() {
		try {
			_pubnub.presence(channel, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
				}
			});
		} catch (PubnubException e) {

		}
	}

	private void detailedHistory() {

		_pubnub.detailedHistory(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.getClass() + " : " + message.toString());
			}
		});
	}

}
