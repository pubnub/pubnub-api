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
    
    String channel = "bbb";
    IntentFilter messageFilter = new IntentFilter("com.aimx.androidpubnub.MESSAGE");
    MessageReceiver messageReceiver = new MessageReceiver();
    Button subscribe = null;
    Button unsubscribe = null;
    Boolean isSubscribed = false;

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

        subscribe();
    }
    
    @Override
    public void onPause() {
        if(isSubscribed){
            //unsubscribe();
        }
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();
        startPushService(); //only really matters the first time you launch the app after you install.. otherwise, it will start on boot

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
    
    private void startPushService(){
        AlarmManager am = (AlarmManager) this.getSystemService(Context.ALARM_SERVICE);

        Intent intent = new Intent(this, PushAlarm.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(this, 0,
                intent, PendingIntent.FLAG_CANCEL_CURRENT);
        am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(),
                (5 * 60 * 1000), pendingIntent); //wake up every 5 minutes to ensure service stays alive
    }

    private void subscribe(){
        registerReceiver(messageReceiver, messageFilter);
        Intent messageservice = new Intent(this, MessageService.class);
        messageservice.putExtra("channel", channel);
        ApplicationContext.getInstance().startService(messageservice);
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
        stopService(messageservice);
    }
    
    public class MessageReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            JSONObject message = null;
            try {
                message = (JSONObject) new JSONTokener(intent.getStringExtra("message")).nextValue();
                if(message != null){
                    Toast.makeText(getApplicationContext(), "Received a message " +message.toString() , Toast.LENGTH_LONG).show();
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
    }
}
