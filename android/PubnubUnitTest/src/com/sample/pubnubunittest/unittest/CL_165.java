package com.sample.pubnubunittest.unittest;

import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;

import com.sample.pubnubunittest.pubnub.Callback;
import com.sample.pubnubunittest.pubnub.Pubnub;

/**
 * 
 * @author tanaji
 * 
 *         This unit test for testing unsubcribe problem in android api
 * 
 *         This test include following steps.
 *          1.Subscribe to channel 
 *          2.Publish message to channel. 
 *          3.UnSubscribe the channel. 
 *          4.Publish message to channel. 
 *          5.Subscribe the channel 
 *          6.Publish message to channel.
 * 
 */

public class CL_165 {

	String publish_key = "demo";
	String subscribe_key = "demo";
	String secret_key = "demo";
	boolean ssl_on = false;
	Pubnub pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
	String crazy = " ~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
	String channel;
	SubcribeExicute subcribe;

	public void RunUnitTest(Handler handler) {
		CommonUtil.setHandler(handler);
		pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
		channel = CommonUtil.getBigDecimal(pubnub.time());

		subcribe = new SubcribeExicute();
		subcribe.execute("Start");
	}

	boolean PublishMessage() {
		boolean returnVal = false;
		try {
			JSONObject message = new JSONObject();
			message.put("message", crazy);

			HashMap<String, Object> args = new HashMap<String, Object>();
			args.put("channel", channel);
			args.put("message", message);
			JSONArray responce = pubnub.publish(args);
			returnVal = responce.getInt(0) == 1 ? true : false;

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return returnVal;

	}

	class SubcribeExicute extends AsyncTask<String, Void, Boolean> {

		String _callFrom = null;

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				_callFrom = params[0];
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e("Message Received", message.toString());

						if(message instanceof JSONObject)
						{
							try{
							JSONObject obj=(JSONObject)message;
							
							if(obj.getString("message").equals(crazy))
							{
								CommonUtil.LogPass(true, "Messege receive to channel.");
							}else
							{
								CommonUtil.LogPass(false, "Messege receive to channel.");
							}
							}catch (Exception e) {
								
							}
							if (_callFrom.equalsIgnoreCase("Start")) {
								HashMap<String, Object> args = new HashMap<String, Object>(
										1);
								args.put("channel", channel);
								pubnub.unsubscribe(args);
							}
							
							if(_callFrom.equalsIgnoreCase("End"))
							{
								if(subcribe != null)
								{
									subcribe.cancel(true);
									subcribe=null;
									return false;
								}
							}
						}
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

						if (PublishMessage()) {
							CommonUtil.LogPass(true, "Publish message sent.");
						} else {
							CommonUtil.LogPass(false, "Publish message sent.");
						}
						if (_callFrom.equalsIgnoreCase("Start")) {
							if(subcribe != null)
							{
								subcribe.cancel(true);
								subcribe=null;
								
							}
							subcribe = new SubcribeExicute();
							subcribe.execute("End");
						}

					}
				}

				// Listen for Messages (Subscribe)
				HashMap<String, Object> args = new HashMap<String, Object>(2);
				args.put("channel", channel); // Channel Name
				args.put("callback", new Receiver()); // Callback to get response
				pubnub.subscribe(args);

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
