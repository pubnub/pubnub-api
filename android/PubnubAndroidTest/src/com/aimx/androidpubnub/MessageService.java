package com.aimx.androidpubnub;

import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.app.Service;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.AsyncTask.Status;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;

public class MessageService extends Service {
    Pubnub pubnub;
    MessageHandler mMessageHandler = new MessageHandler();
    MessageReceiver mMessageReceiver = new MessageReceiver();
    MessageListener mMessageListener = new MessageListener();
    
    private void broadcastMessage(JSONObject message)//this method sends broadcast messages
    {
        Intent intent = new Intent("com.aimx.androidpubnub.MESSAGE");
        intent.putExtra("message", message.toString());
        sendBroadcast(intent);
    }
    
    class MessageHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            try {
                String m = msg.getData().getString("message");
                JSONObject message = (JSONObject) new JSONTokener(m).nextValue();
                broadcastMessage(message);
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

    };
    
    // Callback Interface when a Message is Received
    class MessageReceiver implements Callback {
        public boolean execute(JSONObject message) {
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
                "demo", // CIPHER_KEY
                true // SSL_ON?
        );
        
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
    
    @Override
    public void onStart(Intent intent, int startid) {
        super.onStart(intent, startid);
        if(mMessageListener.getStatus() != Status.RUNNING){
                mMessageListener.execute(intent.getStringExtra("channel"));
        }
            
        
    }
}
