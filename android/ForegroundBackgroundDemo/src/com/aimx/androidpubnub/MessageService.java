package com.aimx.androidpubnub;

import java.util.HashMap;

import android.app.NotificationManager;
import android.os.*;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.app.Service;
import android.content.Intent;
import android.os.AsyncTask.Status;
import android.util.Log;

public class MessageService extends Service {

    Pubnub pubnub;
    MessageHandler mMessageHandler = new MessageHandler();
    MessageReceiver mMessageReceiver = new MessageReceiver();
    MessageListener mMessageListener = new MessageListener();

    private void broadcastMessage(Object message)//this method sends broadcast messages
    {
        Intent intent = new Intent("com.aimx.androidpubnub.MESSAGE");
        intent.putExtra("message", message.toString());
        sendBroadcast(intent);
    }
    
    class MessageHandler extends Handler {

        @Override
        public void handleMessage(Message msg) {

            Bundle data = msg.getData();
            String pnMessage = data.getString("message");

            if (pnMessage != null) {
                broadcastMessage(pnMessage);
            }
        }
    };
    
    // Callback Interface when a Message is Received
    class MessageReceiver implements Callback {
        @Override
        public boolean subscribeCallback(String channel, Object message) {
            try {
                Message m = Message.obtain();
                Bundle b = new Bundle();
                b.putString("message", message.toString());
                m.setData(b);
                mMessageHandler.sendMessage(m);
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

        @Override
        public boolean presenceCallback(String channel, Object data) {
            Log.e("PresenceCallback","Presented to channel :" + channel);
            return false;
        }
    }
    
    class MessageListener extends AsyncTask<String, Void, Boolean> {
        @Override
        protected Boolean doInBackground(String... params) {
            {
                try {
                    HashMap<String, Object> args = new HashMap<String, Object>(2);
                    args.put("channel", params[0]);
                    args.put("callback", mMessageReceiver);
                    pubnub.subscribe(args);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            return Boolean.TRUE;
        }
    }


    final Messenger myMessenger = new Messenger(new MessageHandler());

    @Override
    public IBinder onBind(Intent intent) {
        return myMessenger.getBinder();
    }
    
    @Override
    public void onCreate() {
        Log.e("onCreate", "Service created.");
        super.onCreate();

    }

    @Override
    public void onDestroy() {
        Log.e("onDestroy", "Service destroyed.");
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.e("onStartCommand", "Received start id " + startId + ": " + intent);

         pubnub = ApplicationContext.getPubnub();
         if (mMessageListener.getStatus() != Status.RUNNING) {
             mMessageListener.execute(intent.getStringExtra("channel"));
         }
         return startId;
    }
}
