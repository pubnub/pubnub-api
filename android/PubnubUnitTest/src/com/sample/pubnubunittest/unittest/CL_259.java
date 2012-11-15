package com.sample.pubnubunittest.unittest;

import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.sample.pubnubunittest.pubnub.Callback;
import com.sample.pubnubunittest.pubnub.Pubnub;


import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;

public class CL_259 {

	String _publish_key ,_subscribe_key,_secret_key,_cipher_key,_uuid;
	String _channel;
	boolean _ssl_on;
	Pubnub _pubnub;
	SubExicute subcribe;
	PresenceExicute presence;
	public void RunUnitTest(Handler handler) {
		CommonUtil.setHandler(handler);
		initParameter();
		presence= new PresenceExicute();
		presence.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
	
		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		subcribe= new SubExicute();
		subcribe.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
	}

	private void initParameter() {
		_publish_key=_subscribe_key=_secret_key="demo";
		_cipher_key="";
		_uuid="efc873ea-8512-45c2-b0c8-91c95b36a819";
		_ssl_on=false;
		_pubnub = new Pubnub(_publish_key,_subscribe_key,_secret_key,_cipher_key,_ssl_on,_uuid);
		_channel=CommonUtil.getBigDecimal(_pubnub.time());
	}
	
	class SubExicute extends AsyncTask<String, Void, Boolean> {

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e("Message Received", message.toString());
						return true;
					}

					@Override
					public boolean presenceCallback(String channel,
							Object message) {
						Log.e("Message Received", message.toString());
						return true;
					}

					@Override
					public void errorCallback(String channel, Object message) {
						Log.e("ErrorCallback", "Channel:" + channel + "-"
								+ message.toString());
					}

					@Override
					public void connectCallback(String channel) {
						Log.e("ConnectCallback", "Connected to channel :"
								+ channel);
					}

					@Override
					public void reconnectCallback(String channel) {
						Log.e("ReconnectCallback", "Reconnecting to channel :"
								+ channel);
					}

					@Override
					public void disconnectCallback(String channel) {
						Log.e("DisconnectCallback", "Disconnected to channel :"
								+ channel);
					}
				}

				// Listen for Messages (Subscribe)
				HashMap<String, Object> args = new HashMap<String, Object>(2);
				args.put("channel", _channel); // Channel Name
				args.put("callback", new Receiver()); // Callback to get response
				_pubnub.subscribe(args);

			} catch (Exception e) {
				e.printStackTrace();
				Log.v("ERROR", "While downloading");
			}

			return Boolean.TRUE;
		}

		@Override
		protected void onPreExecute() {
		}

		protected void onPostExecute(Boolean result) {
		
		}
	}

	class PresenceExicute extends AsyncTask<String, Void, Boolean> {

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e("Message Received", message.toString());
						try{
							JSONObject object=(JSONObject)message;
							//JSONObject object=(JSONObject)array.get(0);
							String uuid=object.getString("uuid");
							String action=object.getString("action");
							
							if(action.equalsIgnoreCase("join"))
							{
								if(uuid.equals(_uuid))
								{
									CommonUtil.LogPass(true, "Channel "+_channel+" join successfully");
									HashMap<String, Object> args = new HashMap<String, Object>(
											1);
									args.put("channel", _channel);
									CommonUtil.PrintLog("Unsubscribing channel");
									_pubnub.unsubscribe(args);
								}
							}else if(action.equalsIgnoreCase("leave"))
							{
								if(uuid.equals(_uuid))
								{
									CommonUtil.LogPass(true, "Channel "+_channel+" leave successfully");
								}
							}
							
						}catch (Exception e) {
						}
						
						return true;
					}

					@Override
					public boolean presenceCallback(String channel,
							Object message) {
						Log.e("Message P", message.toString());
						
						return true;
					}

					@Override
					public void errorCallback(String channel, Object message) {
						Log.e("ErrorCallback", "Channel:" + channel + "-"
								+ message.toString());
					}

					@Override
					public void connectCallback(String channel) {
						Log.e("ConnectCallback", "Connected to channel :"
								+ channel);
					}

					@Override
					public void reconnectCallback(String channel) {
						Log.e("ReconnectCallback", "Reconnecting to channel :"
								+ channel);
					}

					@Override
					public void disconnectCallback(String channel) {
						Log.e("DisconnectCallback", "Disconnected to channel :"
								+ channel);
					}
				}

				// Listen for Messages (Subscribe)
				HashMap<String, Object> args = new HashMap<String, Object>(2);
				args.put("channel", _channel + "-pnpres"); // Channel Name
				args.put("callback", new Receiver()); // Callback to get response
				_pubnub.subscribe(args);

			} catch (Exception e) {
				e.printStackTrace();
				Log.v("ERROR", "While downloading");
			}

			return Boolean.TRUE;
		}

		@Override
		protected void onPreExecute() {
		}

		protected void onPostExecute(Boolean result) {
		}
	}

	
}
