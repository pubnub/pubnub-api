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

/*Add API Keys - COMING SOON

- COMING SOON - You will be able to add new account keys, allowing you to keep your applications organized.
PUBLISH KEY:

pub-e9de5ea1-6d11-4de9-86c1-3633dd72cd12
SUBSCRIBE KEY:

sub-39add79c-fb17-11e0-b82b-53345a41c1d8
SECRET KEY:

sec-cae06c3b-0aa3-404b-a736-bc66f53505a5*/

	

public class PubNubTestActivity extends Activity {
    /** Called when the activity is first created. */
	
	Pubnub pubnub;
	String myMessage="";
	EditText ed ;
	   RefreshHandler r = new RefreshHandler();
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        ed = (EditText) findViewById(R.id.editText1);
        
        XMLDownloader d = new XMLDownloader();
        d.execute("xml");
        
    

       


    

      /*  -------------------------------------------------------------------------------
        Java: (History)
        -------------------------------------------------------------------------------

            // Get History
            JSONArray response = pubnub.history(
                "hello_world", // Channel Name
                1              // Limit
            );

            // Print Response from PubNub JSONP REST Service
            System.out.println(response);
            System.out.println(response.optJSONObject(0).optString("some_key"));*/
            
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
      
    
    class XMLDownloader extends AsyncTask <String, Void, Boolean> 
	{		

		public void setUrl(String url)
		{

		}

		@Override   
		protected Boolean doInBackground(String... params) {


			//	for(int i=0; i<channelsArrayList.size();i++)
			{
				//Log.v("DownLoading",""+i);
				//	Log.v("DownLoading",""+"http://meetguru.com:8080/AvaniTvResorces/logos/"+channelsArrayList.get(i));
				try {					

					 /*   -------------------------------------------------------------------------------
			        Java: (Init)
			        -------------------------------------------------------------------------------*/

			        
			        
			             pubnub = new Pubnub(
			                "pub-e9de5ea1-6d11-4de9-86c1-3633dd72cd12",  // PUBLISH_KEY
			                "sub-39add79c-fb17-11e0-b82b-53345a41c1d8",  // SUBSCRIBE_KEY
			                "sec-cae06c3b-0aa3-404b-a736-bc66f53505a5",      // SECRET_KEY
			                false    // SSL_ON?
			            );
			             
			             /* -------------------------------------------------------------------------------
			             Java: (Subscribe)
			             -------------------------------------------------------------------------------*/

			                 // Callback Interface when a Message is Received
			                 class Receiver implements Callback {
			                     public boolean execute(JSONObject message) {

			                         // Print Received Message
			                         System.out.println(message);
			                         myMessage =message.toString();
			                      
			                         r.sendEmptyMessage(0);
			                         
			                         
			                       //  Toast.makeText(PubNubTestActivity.this, "You got message", Toast.LENGTH_LONG).show();
			                         
			                        /* final AlertDialog.Builder b = new AlertDialog.Builder(PubNubTestActivity.this);
			             			b.setIcon(android.R.drawable.ic_dialog_alert);
			             			b.setTitle("Network");
			             			b.setMessage("No network access.");
			             			b.setNegativeButton("OK", new DialogInterface.OnClickListener() {
			             				public void onClick(DialogInterface dialog, int which) {
			             					
			             				}
			             			});*/
			             			
			                         // Continue Listening?
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

