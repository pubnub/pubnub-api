package com.sample.pubnubunittest.unittest;

import java.util.HashMap;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.sample.pubnubunittest.pubnub.Callback;
import com.sample.pubnubunittest.pubnub.Pubnub;
import com.sample.pubnubunittest.unittest.CL_165.SubcribeExicute;

import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;

public class CL_216 {

	String _publish_key ,_subscribe_key,_secret_key,_cipher_key,_uuid;
	String _crazy,_channel;
	boolean _ssl_on;
	Pubnub _pubnub;
	SubcribeExicute subcribe;
	
	private void initParameter() {
		_publish_key=_subscribe_key=_secret_key=_cipher_key="demo";
		_uuid="efc873ea-8512-45c2-b0c8-91c95b36a819";
		_ssl_on=false;
		_crazy = "~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
		_pubnub = new Pubnub(_publish_key,_subscribe_key,_secret_key,_cipher_key,_ssl_on,_uuid);
		_channel=CommonUtil.getBigDecimal(_pubnub.time());
	}
	
	public void RunUnitTest(Handler handler) {
		CommonUtil.setHandler(handler);
		initParameter();
		CommonUtil.PrintLog("subscribeing channel with uuid: "+_uuid);
		subcribe = new SubcribeExicute();
		subcribe.execute();
	}

	boolean PublishMessage() {
		boolean returnVal = false;
		try {
			JSONObject message = new JSONObject();
			message.put("message", _crazy);

			HashMap<String, Object> args = new HashMap<String, Object>();
			args.put("channel", _channel);
			args.put("message", message);
			JSONArray responce = _pubnub.publish(args);
			returnVal = responce.getInt(0) == 1 ? true : false;

		} catch (JSONException e) {
			e.printStackTrace();
		}
		return returnVal;

	}
	
	
	class SubcribeExicute extends AsyncTask<String, Void, Boolean> {

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e("Message Received", message.toString());

						if(message instanceof JSONObject)
						{
							try{
							JSONObject obj=(JSONObject)message;
							
							if(obj.getString("message").equals(_crazy))
							{
								CommonUtil.LogPass(true, "Messege receive to channel.");
							}else
							{
								CommonUtil.LogPass(false, "Messege receive to channel.");
							}
							}catch (Exception e) {
								
							}
							
							  HashMap<String, Object> args = new HashMap<String, Object>(1);
						       args.put("channel", _channel);
						       JSONArray array = _pubnub.here_now(args);
							
							try {
								JSONArray uuids=array.getJSONObject(0).getJSONArray("uuids");
								for(int i= 0; i<uuids.length();i++)
								{
									String uuid=uuids.getString(i);
									if(uuid.equals(_uuid))
									{
										CommonUtil.PrintLog("Receviev UUID:"+uuid);
										CommonUtil.LogPass(true, "UUID unit test.");
									}else
									{
										CommonUtil.LogPass(false, "UUID unit test.");
									}
								}
								
							} catch (JSONException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						       if(subcribe != null)
								{
									subcribe.cancel(true);
									subcribe=null;
									return false;
								}
						}
						return false;
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
						CommonUtil.LogPass(true, "Subscribe the channel.");
						
						if (PublishMessage()) {
							CommonUtil.LogPass(true, "Publish message sent.");
						} else {
							CommonUtil.LogPass(false, "Publish message sent.");
						}
						
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
						CommonUtil.LogPass(true, "Unsubscribe channel.");

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
}
