package com.fbt;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class PubnubTestActivity extends Activity {
    /** Called when the activity is first created. */
    
    Pubnub pubnub;
    String myMessage = "", channel = "hello_world";
    EditText ed;
    RefreshHandler r = new RefreshHandler();
    int limit = 1;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        ed = (EditText) findViewById(R.id.editText1);
        
        XMLDownloader d = new XMLDownloader();
        d.execute("xml");
        
        Button publishBtn =(Button) findViewById(R.id.publishBtn);
        publishBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                
                /*-------------------------------------------------------------------------------
                Android: (Publish)
                -------------------------------------------------------------------------------*/
                
                // Create JSON Message
                JSONObject message = new JSONObject();
                try { 
                    if(ed.getText().toString() != null && !ed.getText().toString().equals(""))
                        message.put( "Message", ed.getText().toString()); 
                }
                catch (org.json.JSONException jsonError) {}

                // Publish Message
                
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);         // Channel Name
                args.put("message", message);         // JSON Message
                JSONArray info = pubnub.publish(args);

                // Print Response from PubNub JSONP REST Service
                System.out.println(info);
            }

        });
        
        Button unsubscribeBtn =(Button) findViewById(R.id.unsubscribeBtn);
        unsubscribeBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                
                /*-------------------------------------------------------------------------------
                Android: (Unsubscribe/disconnect)
                -------------------------------------------------------------------------------*/
                
                HashMap<String, Object> args = new HashMap<String, Object>(1);
                args.put("channel", channel);
                pubnub.unsubscribe( args );
            }
        
        });
        
        Button historyBtn =(Button) findViewById(R.id.historyBtn);
        historyBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                
                /*-------------------------------------------------------------------------------
                Android: (History)
                -------------------------------------------------------------------------------*/
                
                System.out.print(" HISTORY: ");
                
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);
                args.put("limit", limit);
                
                // Get History
                JSONArray response = pubnub.history( args );

                // Print Response from PubNub JSONP REST Service
                try {
                    if(response != null){
                        for (int i = 0; i < response.length(); i++) {
                             JSONObject jsono = response.optJSONObject(i);
                             if(jsono != null){
                                 @SuppressWarnings("rawtypes")
                                 Iterator keys = jsono.keys();
                                 while (keys.hasNext()) {
                                     System.out.print(jsono.get( keys.next().toString() ) +" ");
                                 }
                             }
                             System.out.println();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        });
        
        Button uuidBtn =(Button) findViewById(R.id.uuidBtn);
        uuidBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                
                /*-------------------------------------------------------------------------------
                Android: (UUID)
                -------------------------------------------------------------------------------*/
                
                System.out.println(" UUID: "+Pubnub.uuid());
            }

        });
        
        Button timeBtn =(Button) findViewById(R.id.timeBtn);
        timeBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                
                /*-------------------------------------------------------------------------------
                Android: (Time)
                -------------------------------------------------------------------------------*/
                
                Pubnub pubnub = new Pubnub("demo", "demo");
                System.out.println(" Time: "+pubnub.time());
            }

        });
    }
    public void AllMessageClick(View v)
    {
        JSONObject message = new JSONObject();
        try {
            message.put("some_val", "Hello World! --> ɂ顶@#$%^&*()!");
            /*
             * message.put( "title", "Android PubNub"); message.put(
             * "text", "This is a push to all users! woot!");
             * message.put( "url", "http://www.pubnub.com");
             */
        } catch (org.json.JSONException jsonError) {
        }

        // Publish
        HashMap<String, Object> args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", message);
        JSONArray response = null;
        response = pubnub.publish(args);
        System.out.println(response);

        args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", "Hello World");

        response = pubnub.publish(args);
        System.out.println(response);

        JSONArray array = new JSONArray();
        array.put("Sunday");
        array.put("Monday");
        array.put("Tuesday");
        array.put("Wednesday");
        array.put("Thursday");
        array.put("Friday");
        array.put("Saturday");

        args = new HashMap<String, Object>(2);
        args.put("channel", channel);
        args.put("message", array);

        response = pubnub.publish(args);
        System.out.println(response);
    }

    class RefreshHandler extends Handler {
        @Override  
        public void handleMessage(Message msg) {
            Log.v("IN","HANDLER");
            Toast.makeText(PubnubTestActivity.this, "You got message", Toast.LENGTH_LONG).show();
            final AlertDialog.Builder b = new AlertDialog.Builder(PubnubTestActivity.this);
            b.setIcon(android.R.drawable.ic_dialog_alert);
            b.setTitle("PUBNUB");
            Log.e("Message Recevie In Alert",myMessage);
            b.setMessage(myMessage);

            b.setNegativeButton("OK", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {

                }
            });

            b.show();
        }  
      
    };  
      
    
    class XMLDownloader extends AsyncTask <String, Void, Boolean>{        

        public void setUrl(String url)
        {

        }

        @Override
        protected Boolean doInBackground(String... params) {
            try {                    
                /*  -----------------------------------------------------------------------------
                Android: (Init)
                -------------------------------------------------------------------------------*/

                pubnub = new Pubnub(
                    "demo",  // PUBLISH_KEY
                    "demo",  // SUBSCRIBE_KEY
                    "demo",  // SECRET_KEY
                    "demo",  // CIPHER_KEY
                    true     // SSL_ON?
                );

                /* ------------------------------------------------------------------------------
                Android: (Subscribe)
                -------------------------------------------------------------------------------*/
                class Receiver implements Callback {
                    public boolean execute(Object message) {
                        Log.e("Message Recevie",message.toString());
                        myMessage = message.toString();
                       
                        r.sendEmptyMessage(0);

                        return true;
                    }
                }

                // Callback Interface when a channel is connected
                class ConnectCallback implements Callback {

                    @Override
                    public boolean execute(Object message) {
                        System.out.println(message.toString());
                        return false;
                    }
                }

                // Callback Interface when a channel is disconnected
                class DisconnectCallback implements Callback {

                    @Override
                    public boolean execute(Object message) {
                        System.out.println(message.toString());
                        return false;
                    }
                }

                // Callback Interface when a channel is reconnected
                class ReconnectCallback implements Callback {

                    @Override
                    public boolean execute(Object message) {
                        System.out.println(message.toString());
                        return false;
                    }
                }

                // Callback Interface when error occurs
                class ErrorCallback implements Callback {

                    @Override
                    public boolean execute(Object message) {
                        System.out.println(message.toString());
                        return false;
                    }
                }
                
                // Listen for Messages (Subscribe)
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);                             // Channel Name
                args.put("callback", new Receiver());                     // callback to get response
                args.put("connect_cb", new ConnectCallback());            // callback to get connect event
                args.put("disconnect_cb", new DisconnectCallback());      // callback to get disconnect event (optional)
                args.put("reconnect_cb", new ReconnectCallback());        // callback to get reconnect event (optional)
                args.put("error_cb", new ErrorCallback());                // callback to get error event (optional)
                pubnub.subscribe( args );

            } catch (Exception e) {
                e.printStackTrace();
                Log.v("ERROR","While downloading");
            }

            return Boolean.TRUE;   // Return your real result here
        }

        @Override
        protected void onPreExecute() {
        
        }

        protected void onPostExecute(Boolean result) {
            // result is the value returned from doInBackground
        }
    }
}
