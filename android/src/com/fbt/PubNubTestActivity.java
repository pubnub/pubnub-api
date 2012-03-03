package com.fbt;

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

public class PubNubTestActivity extends Activity {
    /** Called when the activity is first created. */
    
    Pubnub pubnub;
    String myMessage="";
    EditText ed;
    RefreshHandler r = new RefreshHandler();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        ed = (EditText) findViewById(R.id.editText1);
        
        XMLDownloader d = new XMLDownloader();
        d.execute("xml");
        
        Button clickMe =(Button) findViewById(R.id.button1);
        clickMe.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
                /*-------------------------------------------------------------------------------
                Java: (Publish)
                -------------------------------------------------------------------------------*/

                // Create JSON Message
                JSONObject message = new JSONObject();
                try { message.put( "Message", ed.getText().toString()); }
                catch (org.json.JSONException jsonError) {}

                // Publish Message
                JSONArray info = pubnub.publish(
                    "hello_world", // Channel Name
                    message        // JSON Message
                );

                // Print Response from PubNub JSONP REST Service
                System.out.println(info);
            }

        });
    }
    
    class RefreshHandler extends Handler {
        @Override  
        public void handleMessage(Message msg) {
            Log.v("IN","HANDLER");
            Toast.makeText(PubNubTestActivity.this, "You got message", Toast.LENGTH_LONG).show();
            final AlertDialog.Builder b = new AlertDialog.Builder(PubNubTestActivity.this);
            b.setIcon(android.R.drawable.ic_dialog_alert);
            b.setTitle("PUBNUB");
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
                Java: (Init)
                -------------------------------------------------------------------------------*/
                pubnub = new Pubnub(
                    "demo",  // PUBLISH_KEY
                    "demo",  // SUBSCRIBE_KEY
                    "",      // SECRET_KEY
                    false    // SSL_ON?
                );

                /* ------------------------------------------------------------------------------
                Java: (Subscribe)
                -------------------------------------------------------------------------------*/
                class Receiver implements Callback {
                    public boolean execute(JSONObject message) {
                        System.out.println(message);
                        myMessage =message.toString();
                        r.sendEmptyMessage(0);

                        return true;
                    }
                }

                // Create a new Message Receiver
                Receiver message_receiver = new Receiver();

                // Listen for Messages (Subscribe)
                pubnub.subscribe(
                    "hello_world",   // Channel Name
                    message_receiver // Receiver Callback Class
                );

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

