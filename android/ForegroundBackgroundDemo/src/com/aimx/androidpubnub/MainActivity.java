package com.aimx.androidpubnub;

import java.util.HashMap;
import java.util.List;

import android.content.*;
import android.os.*;
import android.util.Log;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.example.ForegroundBackgroundDemo.R;


public class MainActivity extends Activity {
    
    String channel = "string_demo";
    IntentFilter messageFilter = new IntentFilter("com.aimx.androidpubnub.MESSAGE");
    MessageReceiver messageReceiver = new MessageReceiver();
    Button subscribe = null;
    Boolean isSubscribed = false;

    Messenger myService = null;
    boolean isBound;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        subscribe = (Button) findViewById(R.id.subscribe);
        subscribe.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                subscribe();
                isSubscribed = true;
                Toast.makeText(getApplicationContext(), "Subscribed messages will now appear regardless if application is in foreground or background.", Toast.LENGTH_LONG).show();
            }
        });

        Intent intent = new Intent("com.aimx.androidpubnub.MessageService");
        bindService(intent, myConnection, Context.BIND_AUTO_CREATE);

    }

    private ServiceConnection myConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            myService = new Messenger(service);
            isBound = true;
            Log.e("ServiceConnection", "Service Established.");
        }

        public void onServiceDisconnected(ComponentName className) {
            myService = null;
            isBound = false;
            Log.e("ServiceConnection", "Service Disconnected.");
        }
    };

    @Override
    public void onPause() {
        super.onPause();

        ApplicationContext.activityPaused();
    }

    @Override
    public void onResume() {
        super.onResume();

        ApplicationContext.activityResumed();
    }

    @Override
    public void onRestart() {
        super.onResume();
    }

    @Override
    public void onDestroy() {
        Log.e("onDestroy", "Destroying PubNub Example app.");
        if(ApplicationContext.isSubscribed()){
            unsubscribe();
        }

        super.onDestroy();
    }

    private void subscribe(){

        if (!ApplicationContext.isSubscribed()) {
            registerReceiver(messageReceiver, messageFilter);
            Intent messageService = new Intent(this, MessageService.class);
            messageService.putExtra("channel", channel);
            ApplicationContext.getInstance().startService(messageService);
            ApplicationContext.justSubscribed();
        }
    }
    
    private void unsubscribe(){
        killService();
        try {
            unregisterReceiver(messageReceiver);
        } catch (Exception ex){
            // Do something better
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

            StringBuilder displayText;
            displayText = new StringBuilder();

            String message = "";
            String rawData = intent.getStringExtra("message");

            try {
                message = new JSONTokener(rawData).nextValue().toString();
            } catch (JSONException e) {
                message = (String)rawData;
            }

            if (message != null) {
                if (ApplicationContext.isActivityVisible()) {
                    displayText.append("Foreground Message received: ").append(message);
                } else {
                    displayText.append("Background Message received: ").append(message);
                }

                Toast.makeText(getApplicationContext(), displayText.toString(), Toast.LENGTH_LONG).show();

            }
        }
    }
}
