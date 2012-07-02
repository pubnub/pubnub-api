package com.aimx.androidpubnub;

import java.util.HashMap;

import org.json.JSONObject;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.IBinder;
import android.os.AsyncTask.Status;
import android.util.Log;

public class PushService extends Service {
    String PUSHCHANNEL = "c2dmalt";
    Pubnub pubnub;
    PushReceiver mPushReceiver = new PushReceiver();
    PushListener mPushListener = new PushListener();

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        pubnub = new Pubnub("demo", // PUBLISH_KEY
                "demo", // SUBSCRIBE_KEY
                "demo", // SECRET_KEY
                "",     // CIPHER_KEY [Optional]
                true    // SSL_ON?
        );
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
        if (mPushListener.getStatus() != Status.RUNNING) {
            mPushListener.execute(PUSHCHANNEL);
        }
    }

    class PushReceiver implements Callback {
        private void generateNotification(Context context, String title,
                String message, Uri uri) {
            int icon = 0;
            long when = System.currentTimeMillis();

            icon = R.drawable.notify_icon;

            Notification notification = new Notification(icon, message, when);

            notification.defaults = Notification.DEFAULT_SOUND;
            notification.defaults |= Notification.DEFAULT_VIBRATE;
            notification.flags |= Notification.FLAG_AUTO_CANCEL;

            // Launch new Intent to view a new contact added
            Intent notificationIntent = new Intent(Intent.ACTION_VIEW, uri);
            PendingIntent contentIntent = PendingIntent.getActivity(getApplicationContext(), 0, notificationIntent, 0);
            notification.setLatestEventInfo(getApplicationContext(), title, message, contentIntent);

            NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            nm.notify(1, notification);

        }
    	@Override
        public boolean subscribeCallback(String channel, Object message) {
            try {
                if(message instanceof JSONObject)
                {
                    JSONObject message1 =(JSONObject)message;
                    generateNotification(getApplicationContext(),
                    message1.getString("title"), message1.getString("text"),
                    Uri.parse(message1.getString("url")));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            return true;
        }

    	@Override
		public void errorCallback(String channel, Object message) {
			 Log.e("ErrorCallback","Channel:" + channel + "-" + message.toString());
		}

		@Override
		public void connectCallback(String channel) {
			 Log.e("ConnectCallback","Connected to channel :" + channel);
		}

		@Override
		public void reconnectCallback(String channel) {
			 Log.e("ReconnectCallback","Reconnected to channel :" + channel);
		}

		@Override
		public void disconnectCallback(String channel) {
			 Log.e("DisconnectCallback","Disconnected to channel :" + channel);
		}
    }

    class PushListener extends AsyncTask<String, Void, Boolean> {
        @Override
        protected Boolean doInBackground(String... params) {
            {
                try {
                  
                   

                    HashMap<String, Object> args = new HashMap<String, Object>(2);
                    args.put("channel", params[0]);
                    args.put("callback", mPushReceiver);
                    pubnub.subscribe(args);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            return Boolean.TRUE; // Return your real result here
        }
    }
}
