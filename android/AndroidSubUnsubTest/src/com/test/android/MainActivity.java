package com.test.android;

import java.math.BigDecimal;
import java.util.HashMap;
import org.json.JSONArray;
import org.json.JSONException;
import com.test.android.pubnub.Callback;
import com.test.android.pubnub.Pubnub;

import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.util.Log;

public class MainActivity extends Activity {

	Handler _handler = new Handler();
	Pubnub _pubnub = null;
	static String channel = null;
	static String TAG = "ForegroundTask";
	static String BGTAG = "BackgroundTask";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		_pubnub = new Pubnub("demo", "demo");
		channel = new BigDecimal(System.currentTimeMillis()).toString();
		Log.e(TAG, "Channel:" + channel);
		
		new ForegroundTask().execute("FG_SUB");
	}

	boolean publishMessage() {

		try {
			JSONArray array = new JSONArray();
			array.put("Sunday");
			array.put("Monday");
			array.put("Tuesday");
			array.put("Wednesday");
			array.put("Thursday");
			array.put("Friday");
			array.put("Saturday");

			HashMap<String, Object> args = new HashMap<String, Object>(2);
			args.put("channel", channel);
			args.put("message", array);
			JSONArray responce = _pubnub.publish(args);
			return (Integer.parseInt(responce.get(0).toString())) == 0 ? false
					: true;
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return false;
	}

	class HandlerRunner implements Runnable {
		String _callFrom;

		public HandlerRunner(String callString) {
			_callFrom = callString;
		}

		@Override
		public void run() {
			if (_callFrom == "FG_SUB") {
				HashMap<String, Object> args = new HashMap<String, Object>(1);
				args.put("channel", MainActivity.channel);
				_pubnub.unsubscribe(args);
				Log.e(TAG, "Unsubscribe sucessfully from Foreground Task");
				if (publishMessage()) {
					Log.e(TAG, "Publish message Sucessfully after unsubcribe.");
				} else {
					Log.e(TAG, "Publish message fail after unsubcribe.");
				}

				new ForegroundTask().execute("FG_TSUB");

			} else if (_callFrom == "FG_TSUB") {
				HashMap<String, Object> args = new HashMap<String, Object>(1);
				args.put("channel", MainActivity.channel);
				_pubnub.unsubscribe(args);
				Log.e(TAG, "First Unsubscribe sucessfully  from Foreground Task");
				_pubnub.unsubscribe(args);
				Log.e(TAG, "Second Unsubscribe sucessfully from Foreground Task");
				if (publishMessage()) {
					Log.e(TAG, "Publish message Sucessfully after unsubcribe.");
				} else {
					Log.e(TAG, "Publish message fail after unsubcribe.");
				}
				new ForegroundTask().execute("BG_SUB");
			} else if (_callFrom == "BG_SUB") {
				new AsyncTask<String, Void, Boolean>() {
					@Override
					protected Boolean doInBackground(String... params) {
						HashMap<String, Object> args = new HashMap<String, Object>(
								1);
						args.put("channel", MainActivity.channel);
						_pubnub.unsubscribe(args);
						Log.e(TAG, "Unsubscribe sucessfully from Backgroung Task");
						if (publishMessage()) {
							Log.e(TAG,
									"Backgroung Publish message Sucessfully after unsubcribe.");
						} else {
							Log.e(TAG, "Backgroung Publish message fail after unsubcribe.");
						}
						return Boolean.TRUE;
					}
				}.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

				new ForegroundTask().execute("BG_TSUB");

			} else if (_callFrom == "BG_TSUB") {
				new AsyncTask<String, Void, Boolean>() {
					@Override
					protected Boolean doInBackground(String... params) {
						HashMap<String, Object> args = new HashMap<String, Object>(
								1);
						args.put("channel", MainActivity.channel);
						_pubnub.unsubscribe(args);
						Log.e(TAG, "First Unsubscribe sucessfully from Backgroung Task");
						_pubnub.unsubscribe(args);
						Log.e(TAG, "Second Unsubscribe sucessfully from Backgroung Task");
						if (publishMessage()) {
							Log.e(TAG,
									"Backgroung Publish message Sucessfully after unsubcribe.");
						} else {
							Log.e(TAG, "Backgroung Publish message fail after unsubcribe.");
						}
						return Boolean.TRUE;
					}
				}.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
				
				new BackgroundTask().execute("BG_FG_SUB");
				
			}else if (_callFrom == "BG_FG_SUB") {
				HashMap<String, Object> args = new HashMap<String, Object>(1);
				args.put("channel", MainActivity.channel);
				_pubnub.unsubscribe(args);
				Log.e(BGTAG, "Unsubscribe sucessfully form Foreground Task");
				if (publishMessage()) {
					Log.e(BGTAG, "Publish message Sucessfully after unsubcribe.");
				} else {
					Log.e(BGTAG, "Publish message fail after unsubcribe.");
				}
		
				new BackgroundTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR,"BG_FG_TSUB");

			} else if (_callFrom == "BG_FG_TSUB") {
				HashMap<String, Object> args = new HashMap<String, Object>(1);
				args.put("channel", MainActivity.channel);
				_pubnub.unsubscribe(args);
				Log.e(BGTAG, "First Unsubscribe sucessfully form Foreground Task");
				_pubnub.unsubscribe(args);
				Log.e(BGTAG, "Second Unsubscribe sucessfully form Foreground Task");
				if (publishMessage()) {
					Log.e(BGTAG, "Publish message Sucessfully after unsubcribe.");
				} else {
					Log.e(BGTAG, "Publish message fail after unsubcribe.");
				}
				new BackgroundTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR,"BG_BG_SUB");
			} else if (_callFrom == "BG_BG_SUB") {
				new AsyncTask<String, Void, Boolean>() {
					@Override
					protected Boolean doInBackground(String... params) {
						HashMap<String, Object> args = new HashMap<String, Object>(
								1);
						args.put("channel", MainActivity.channel);
						_pubnub.unsubscribe(args);
						Log.e(BGTAG, "Unsubscribe sucessfully from Backgroung Task");
						if (publishMessage()) {
							Log.e(BGTAG,
									"Backgroung Publish message Sucessfully after unsubcribe.");
						} else {
							Log.e(BGTAG, "Backgroung Publish message fail after unsubcribe.");
						}
						return Boolean.TRUE;
					}
				}.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

				new BackgroundTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR,"BG_BG_TSUB");

			} else if (_callFrom == "BG_BG_TSUB") {
				new AsyncTask<String, Void, Boolean>() {
					@Override
					protected Boolean doInBackground(String... params) {
						HashMap<String, Object> args = new HashMap<String, Object>(
								1);
						args.put("channel", MainActivity.channel);
						_pubnub.unsubscribe(args);
						Log.e(BGTAG, "First Unsubscribe sucessfully from Backgroung Task");
						_pubnub.unsubscribe(args);
						Log.e(BGTAG, "Second Unsubscribe sucessfully from Backgroung Task");
						if (publishMessage()) {
							Log.e(BGTAG,
									"Backgroung Publish message Sucessfully after unsubcribe.");
						} else {
							Log.e(BGTAG, "Backgroung Publish message fail after unsubcribe.");
						}
						return Boolean.TRUE;
					}
				}.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

			}
		}

	}

	class ForegroundTask extends AsyncTask<String, Void, Boolean> {
		String _callFrom;

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				// Android: (Subscribe)
				_callFrom = params[0];
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e(TAG+"Message Received", message.toString());

						return true;
					}

					@Override
					public boolean presenceCallback(String channel,
							Object message) {
						Log.e(TAG+"Message Received", message.toString());

						return true;
					}

					@Override
					public void errorCallback(String channel, Object message) {
						Log.e(TAG, "Channel:" + channel + "-"
								+ message.toString());
					}

					@Override
					public void connectCallback(String channel) {
						Log.e(TAG, "Connected to channel :"
								+ channel);
						if (_callFrom.equals("FG_SUB")) {
							Log.e(TAG,
									"Set Forground task unsubcribe after 30 sec");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("FG_TSUB")) {
							Log.e(TAG,
									"Set Forground task twice unsubcribe after 30 sec");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("BG_SUB")) {
							Log.e(TAG,
									"Set Background task unsubcribe after 30 sec");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("BG_TSUB")) {
							Log.e(TAG,
									"Set Background task twice unsubcribe after 30 sec");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						}
					}

					@Override
					public void reconnectCallback(String channel) {
						Log.e(TAG, "Reconnecting to channel :"
								+ channel);
					}

					@Override
					public void disconnectCallback(String channel) {
						Log.e(TAG, "Disconnected to channel :"
								+ channel);
					}
				}

				// Listen for Messages (Subscribe)
				HashMap<String, Object> args = new HashMap<String, Object>(2);
				args.put("channel", channel); // Channel Name
				args.put("callback", new Receiver()); // Callback to get				// response
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

	class BackgroundSubcribeTask extends AsyncTask<String, Void, Boolean> {
		String _callFrom;

		@Override
		protected Boolean doInBackground(String... params) {
			try {
				// Android: (Subscribe)
				_callFrom = params[0];
				class Receiver implements Callback {

					public boolean subscribeCallback(String channel,
							Object message) {
						Log.e(BGTAG+"Message Received", message.toString());

						return true;
					}

					@Override
					public boolean presenceCallback(String channel,
							Object message) {
						Log.e(BGTAG+"Message Received", message.toString());

						return true;
					}

					@Override
					public void errorCallback(String channel, Object message) {
						Log.e(BGTAG, "Channel:" + channel + "-"
								+ message.toString());
					}

					@Override
					public void connectCallback(String channel) {
						Log.e(BGTAG, "Connected to channel :"
								+ channel);
						if (_callFrom.equals("BG_FG_SUB")) {
							Log.e(BGTAG,
									"Set Forground task unsubcribe after 30 sec from backgrouund task");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("BG_FG_TSUB")) {
							Log.e(BGTAG,
									"Set Forground task twice unsubcribe after 30 sec from backgrouund task");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("BG_BG_SUB")) {
							Log.e(BGTAG,
									"Set Background task unsubcribe after 30 sec from backgrouund task");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						} else if (_callFrom.equals("BG_BG_TSUB")) {
							Log.e(BGTAG,
									"Set Background task twice unsubcribe after 30 sec from backgrouund task");
							_handler.postDelayed(new HandlerRunner(_callFrom),
									30000);
						}
					}

					@Override
					public void reconnectCallback(String channel) {
						Log.e(BGTAG, "Reconnecting to channel :"
								+ channel);
					}

					@Override
					public void disconnectCallback(String channel) {
						Log.e(BGTAG, "Disconnected to channel :"
								+ channel);
					}
				}

				// Listen for Messages (Subscribe)
				HashMap<String, Object> args = new HashMap<String, Object>(2);
				args.put("channel", channel); // Channel Name
				args.put("callback", new Receiver()); // Callback to get				// response
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
	class BackgroundTask extends AsyncTask<String, Void, Boolean> {
		String _callFrom;
		@Override
		protected Boolean doInBackground(String... paramArrayOfParams) {
			_callFrom = paramArrayOfParams[0];
			new BackgroundSubcribeTask().execute(_callFrom);
			return Boolean.TRUE;
		}
		
	}
	
}
