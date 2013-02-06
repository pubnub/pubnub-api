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


public class MainActivity extends Activity {
    
    String channel = "bb";
    IntentFilter messageFilter = new IntentFilter("com.aimx.androidpubnub.MESSAGE");
    MessageReceiver messageReceiver = new MessageReceiver();
    Button subscribe = null;
    Button unsubscribe = null;
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
            }
        });
        
        unsubscribe = (Button) findViewById(R.id.unsubscribe);
        unsubscribe.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                unsubscribe();
                isSubscribed = false;
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
        if(isSubscribed){
            subscribe();
        }

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
        stopService(messageservice);
    }
    
    public class MessageReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {


            JSONObject message = null;
            try {
                message = (JSONObject) new JSONTokener(intent.getStringExtra("message")).nextValue();
                if (message != null) {
                    if (ApplicationContext.isActivityVisible()) {
                        Toast.makeText(getApplicationContext(), "Foreground Message received: " + message.toString(), Toast.LENGTH_LONG).show();
                    } else {
                        Toast.makeText(getApplicationContext(), "Background Message received: " + message.toString(), Toast.LENGTH_LONG).show();
                    }

                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
    }
}
