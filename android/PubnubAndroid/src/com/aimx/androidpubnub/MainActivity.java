package com.aimx.androidpubnub;

import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;


public class MainActivity extends Activity {
    
    String channel = "bb";
    IntentFilter messageFilter = new IntentFilter("com.aimx.androidpubnub.MESSAGE");
    MessageReceiver messageReceiver = new MessageReceiver();
    Button subscribe = null;
    Button unsubscribe = null;
    Boolean isSubscribed = false;
    Boolean isForeground = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        subscribe = (Button) findViewById(R.id.subscribe);
        subscribe.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                subscribe();
                isSubscribed = true;
            }
        });
        
        unsubscribe = (Button) findViewById(R.id.unsubscribe);
        unsubscribe.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                unsubscribe();
                isSubscribed = false;
            }
        });

        if (isSubscribed == false) {
            //subscribe();
            isSubscribed = true;
        }
    }
    
    @Override
    public void onPause() {
        if(isSubscribed){
            subscribe();
        }
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();
        if(isSubscribed){
            subscribe();
        }
    }

    @Override
    public void onRestart() {
        super.onResume();
        if(isSubscribed){
            subscribe();
        }
    }

    @Override
    public void onDestroy() {
        if(isSubscribed){
            unsubscribe();
        }
        super.onDestroy();
    }


    private void subscribe(){
        registerReceiver(messageReceiver, messageFilter);
        Intent messageService = new Intent(this, MessageService.class);
        messageService.putExtra("channel", channel);
        messageService.putExtra("isForeground", isForeground);
        ApplicationContext.getInstance().startService(messageService);
    }
    
    private void unsubscribe(){
        killService();
        try {
            unregisterReceiver(messageReceiver);
        } catch (Exception ex){
            //just eat it
        }
    }
    
    private void killService() {
        HashMap<String, Object> args = new HashMap<String, Object>();
        args.put("channel", channel);  
        ApplicationContext.getPubnub().unsubscribe(args);

        Intent messageservice = new Intent(this, MessageService.class);
        messageservice.putExtra("channel", channel);
        messageservice.putExtra("isForeground", isForeground);
        stopService(messageservice);
    }
    
    public class MessageReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            JSONObject message = null;
            try {
                message = (JSONObject) new JSONTokener(intent.getStringExtra("message")).nextValue();
                if(message != null){
                        Toast.makeText(getApplicationContext(), "From the Foreground: "  + message.toString() , Toast.LENGTH_LONG).show();
                        Toast.makeText(getApplicationContext(), "Hey! Your PubNub app has received an update!  Switch back to it for all the latest goodness! But here is a sneak peak... "  + message.toString().substring(0,10) + "..." , Toast.LENGTH_LONG).show();

                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
    }
}
