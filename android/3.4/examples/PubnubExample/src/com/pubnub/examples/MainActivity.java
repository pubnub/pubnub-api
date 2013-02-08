package com.pubnub.examples;

import java.util.Hashtable;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

public class MainActivity extends Activity {
	Pubnub pubnub = new Pubnub("demo", "demo", "demo", false);
	String channel = "hello_world";
	EditText ed;
	protected int count;

	private void notifyUser(Object message) {
		try {
			if (message instanceof JSONObject) {
				final JSONObject obj = (JSONObject) message;
				this.runOnUiThread(new Runnable() {
					public void run() {
						Toast.makeText(getApplicationContext(), obj.toString(),
								Toast.LENGTH_LONG).show();
					}
				});

			} else if (message instanceof String) {
				final String obj = (String) message;
				this.runOnUiThread(new Runnable() {
					public void run() {
						Toast.makeText(getApplicationContext(), obj,
								Toast.LENGTH_LONG).show();
					}
				});

			} else if (message instanceof JSONArray) {
				final JSONArray obj = (JSONArray) message;
				this.runOnUiThread(new Runnable() {
					public void run() {
						Toast.makeText(getApplicationContext(), obj.toString(),
								Toast.LENGTH_LONG).show();
					}
				});
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		Button publishBtn = (Button) findViewById(R.id.btnPublish);
		publishBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				ed = (EditText) findViewById(R.id.editText1);

				JSONObject message = new JSONObject();
				try {
					if (ed.getText().toString() != null
							&& !ed.getText().toString().equals(""))
						message.put("Message", ed.getText().toString());
				} catch (org.json.JSONException jsonError) {
				}

				// Publish Message
				Hashtable args = new Hashtable(2);
				args.put("channel", channel); // Channel Name
				args.put("message", message); // JSON Message
				pubnub.publish(args, new Callback() {
					public void successCallback(String channel, Object message) {
						notifyUser(message.toString());
					}

					public void errorCallback(String channel, Object message) {
						notifyUser(channel + " : " + message.toString());
					}
				});
			}
		});

		Button subscribeBtn = (Button) findViewById(R.id.btnSubscribe);
		subscribeBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Hashtable args = new Hashtable(1);
				args.put("channel", channel + ++count);

				try {
					pubnub.subscribe(args, new Callback() {
						public void connectCallback(String channel) {
							notifyUser("CONNECT on channel:" + channel);
						}

						public void disconnectCallback(String channel) {
							notifyUser("DISCONNECT on channel:" + channel);
						}

						public void reconnectCallback(String channel) {
							notifyUser("RECONNECT on channel:" + channel);
						}

						public void successCallback(String channel,
								Object message) {
							notifyUser(channel + " " + message.toString());
						}
					});

				} catch (Exception e) {

				}

			}
		});

		Button presenceBtn = (Button) findViewById(R.id.btnPresence);
		presenceBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				try {
					pubnub.presence(channel, new Callback() {
						public void successCallback(String channel,
								Object message) {
							notifyUser(message.toString());
						}

						public void errorCallback(String channel, Object message) {
							notifyUser(channel + " : " + message.toString());
						}
					});
				} catch (PubnubException e) {

				}

			}
		});

		Button historyBtn = (Button) findViewById(R.id.btnHistory);
		historyBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				pubnub.history(channel, 2, new Callback() {
					public void successCallback(String channel, Object message) {
						notifyUser(message.toString());
					}

					public void errorCallback(String channel, Object message) {
						notifyUser(channel + " : " + message.toString());
					}
				});

			}
		});

		Button toggleRoRBtn = (Button) findViewById(R.id.btnToggleRoR);
		toggleRoRBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				pubnub.setResumeOnReconnect(pubnub.isResumeOnReconnect()?false:true);

			}
		});

		Button disconnectAndResubButton = (Button) findViewById(R.id.btnDisconnectAndResubscribe);
		disconnectAndResubButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				pubnub.disconnectAndResubscribe();

			}
		});

		Button detailedHistoryBtn = (Button) findViewById(R.id.btnDetailedHistory);
		detailedHistoryBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				pubnub.detailedHistory(channel, 2, new Callback() {
					public void successCallback(String channel, Object message) {
						notifyUser(message.toString());
					}

					public void errorCallback(String channel, Object message) {
						notifyUser(channel + " : " + message.toString());
					}
				});

			}
		});
		Button hereNowBtn = (Button) findViewById(R.id.btnHereNow);
		hereNowBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				pubnub.hereNow(channel, new Callback() {
					public void successCallback(String channel, Object message) {
						notifyUser(message.toString());
					}

					public void errorCallback(String channel, Object message) {
						notifyUser(channel + " : " + message.toString());
					}
				});

			}
		});

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);

		return true;
	}

}
