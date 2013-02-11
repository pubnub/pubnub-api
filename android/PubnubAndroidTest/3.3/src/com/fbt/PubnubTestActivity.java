package com.fbt;

import java.util.ArrayList;
import java.util.HashMap;

import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import com.example.Android.R;
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
import android.content.Context;
/**
 * PubnubTestActivity
 * 
 */
public class PubnubTestActivity extends Activity {

    Pubnub pubnub;
    String myMessage = "", channel = "hello_world";
    EditText ed;
    RefreshHandler r = new RefreshHandler();
    int limit = 5;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        ed = (EditText) findViewById(R.id.editText1);

        // Android: (Init)
        pubnub = new Pubnub("demo", // PUBLISH_KEY
                "demo",          // SUBSCRIBE_KEY
                "demo",          // SECRET_KEY
                "",              // CIPHER_KEY
                true             // SSL_ON?
        );

        XMLDownloader d = new XMLDownloader();
        d.execute("xml");

        Button publishBtn = (Button) findViewById(R.id.publishBtn);
        publishBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (Publish)

                // Create JSON Message
                JSONObject message = new JSONObject();
                try {
                    if (ed.getText().toString() != null
                            && !ed.getText().toString().equals(""))
                        message.put("Message", ed.getText().toString());
                } catch (org.json.JSONException jsonError) {
                }

                // Publish Message
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel); // Channel Name
                args.put("message", message); // JSON Message
                JSONArray info = pubnub.publish(args);

                // Print Response from PubNub JSONP REST Service
                System.out.println(info);
            }
        });

        Button unsubscribeBtn = (Button) findViewById(R.id.unsubscribeBtn);
        unsubscribeBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (Unsubscribe/disconnect)
                HashMap<String, Object> args = new HashMap<String, Object>(1);
                args.put("channel", channel);
                pubnub.unsubscribe(args);
            }
        });

        Button presenceBtn = (Button) findViewById(R.id.presenceBtn);
        presenceBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                PresenceDownloader d = new PresenceDownloader();
                d.execute("xml");

            }
        });

        Button subscribeBtn = (Button) findViewById(R.id.subscribeBtn);
        subscribeBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (Subscribe)
                XMLDownloader d = new XMLDownloader();
                d.execute("xml");
            }
        });

        Button historyBtn = (Button) findViewById(R.id.historyBtn);
        historyBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (History)

                System.out.print(" HISTORY: ");
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);
                args.put("limit", limit);

                // Get History
                JSONArray response = pubnub.history(args);

                // Print Response from PubNub JSONP REST Service
                try {
                    if (response != null) {
                        StringBuffer messages = new StringBuffer("");
                        for (int i = 0; i < response.length(); i++) {
                            Object o = response.get(i);
                            String message = o.toString() + "\n\n";
                            messages.append(message);
                        }
                        final AlertDialog.Builder b = new AlertDialog.Builder(
                                PubnubTestActivity.this);
                        b.setIcon(android.R.drawable.ic_dialog_alert);
                        b.setTitle("History: ");
                        b.setMessage(messages.toString());
                        b.setNegativeButton("OK",
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog,
                                            int which) {
                                    }
                                });
                        b.show();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        Button detailedHistoryBtn = (Button) findViewById(R.id.detailedHistoryBtn);
        detailedHistoryBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (History)

                System.out.print("Detailed History: ");
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);
                args.put("limit", limit);

                // Get History
                JSONArray response = pubnub.detailedHistory(args);

                // Print Response from PubNub JSONP REST Service
                try {
                    if (response != null) {
                        StringBuffer messages = new StringBuffer("");
                        for (int i = 0; i < response.length(); i++) {
                            Object o = response.get(i);
                            String message = o.toString() + "\n\n";
                            messages.append(message);
                        }
                        final AlertDialog.Builder b = new AlertDialog.Builder(
                                PubnubTestActivity.this);
                        b.setIcon(android.R.drawable.ic_dialog_alert);
                        b.setTitle("History: ");
                        b.setMessage(messages.toString());
                        b.setNegativeButton("OK",
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog,
                                                        int which) {
                                    }
                                });
                        b.show();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        Button uuidBtn = (Button) findViewById(R.id.uuidBtn);
        uuidBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (UUID)

                String uuid = Pubnub.uuid();
                System.out.println(" UUID: " + uuid);
                final AlertDialog.Builder b = new AlertDialog.Builder(
                        PubnubTestActivity.this);
                b.setIcon(android.R.drawable.ic_dialog_alert);
                b.setTitle("UUID: ");
                b.setMessage(uuid);
                b.setNegativeButton("OK",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                    int which) {
                            }
                        });
                b.show();
            }
        });

        Button timeBtn = (Button) findViewById(R.id.timeBtn);
        timeBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (Time)

                double time = pubnub.time();
                System.out.println(" Time: " + Double.toString(time));
                final AlertDialog.Builder b = new AlertDialog.Builder(
                        PubnubTestActivity.this);
                b.setIcon(android.R.drawable.ic_dialog_alert);
                b.setTitle("Time: ");
                b.setMessage(Double.toString(time));
                b.setNegativeButton("OK",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                    int which) {
                            }
                        });
                b.show();
            }
        });

        Button netBtn = (Button) findViewById(R.id.netBtn);
        netBtn.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                // Android: (net)

                Boolean net = isInternetOn();
                System.out.println(" net: " + net);
                final AlertDialog.Builder b = new AlertDialog.Builder(
                        PubnubTestActivity.this);
                b.setIcon(android.R.drawable.ic_dialog_alert);
                b.setTitle("net: ");
                b.setMessage(net.toString());
                b.setNegativeButton("OK",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int which) {
                            }
                        });
                b.show();
            }
        });

    }

    public void allMessageClick(View v) {
        JSONObject message = new JSONObject();
        try {
            message.put("some_val", "Hello World! --> ɂ顶@#$%^&*()!");
            /*
             * message.put( "title", "Android PubNub"); message.put( "text",
             * "This is a push to all users! woot!"); message.put( "url",
             * "http://www.pubnub.com");
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

    
    public void  DetailedHistoryClick(View v)
    {
         HashMap<String, Object> args = new HashMap<String, Object>(2);
         args.put("channel", channel);
         args.put("count", 5);
         myMessage = pubnub.detailedHistory(args).toString();
         r.sendEmptyMessage(0);
         Log.e("Detailed History", myMessage);
    }
    
    public void UnitTestDetailedHistoryClick(View v)
    {
        UnitTestForDetailedHistory unitTest= new UnitTestForDetailedHistory();
        unitTest.RunUnitTest();
    }


    public final boolean isInternetOn() {
        ConnectivityManager connec = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);

        // ARE WE CONNECTED TO THE NET
        if (connec.getNetworkInfo(0).getState() == NetworkInfo.State.CONNECTED ||
                connec.getNetworkInfo(0).getState() == NetworkInfo.State.CONNECTING ||
                connec.getNetworkInfo(1).getState() == NetworkInfo.State.CONNECTING ||
                connec.getNetworkInfo(1).getState() == NetworkInfo.State.CONNECTED) {

        // MESSAGE TO SCREEN FOR TESTING (IF REQ)
            Log.e("Net State", "connected");
            return true;
        } else if (connec.getNetworkInfo(0).getState() == NetworkInfo.State.DISCONNECTED || connec.getNetworkInfo(1).getState() == NetworkInfo.State.DISCONNECTED) {

        Log.e("Net State", "not connected");
            return false;
        }
        return false;
    }

    public void HereNowClick(View v) {
        HashMap<String, Object> args = new HashMap<String, Object>(1);
        args.put("channel", channel);
        myMessage = pubnub.here_now(args).toString();
        r.sendEmptyMessage(0);
        Log.e("Here Now", pubnub.here_now(args).toString());

    }


    class RefreshHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            Log.v("IN", "HANDLER");
            Toast.makeText(PubnubTestActivity.this, myMessage, Toast.LENGTH_LONG).show();
//            final AlertDialog.Builder b = new AlertDialog.Builder(
//                    PubnubTestActivity.this);
//            b.setIcon(android.R.drawable.ic_dialog_alert);
//            b.setTitle("PUBNUB");
//            b.setMessage(myMessage);
//
//            b.setNegativeButton("OK", new DialogInterface.OnClickListener() {
//                public void onClick(DialogInterface dialog, int which) {
//                }
//            });
//            b.show();
        }
    };

    class XMLDownloader extends AsyncTask<String, Void, Boolean> {

        @Override
        protected Boolean doInBackground(String... params) {
            try {
                // Android: (Subscribe)

                class Receiver implements Callback {

                    public boolean subscribeCallback(String channel,
                                                     Object message) {
                        Log.i("Message Received", message.toString());
                        myMessage = message.toString();
                        r.sendEmptyMessage(0);
                        return true;
                    }

                    @Override
                    public boolean presenceCallback(String channel,
                                                     Object message) {
                        Log.i("Message Received", message.toString());
                        myMessage = message.toString();
                        r.sendEmptyMessage(0);
                        return true;
                    }
                    @Override
                    public void errorCallback(String channel, Object message) {
                        Log.e("ErrorCallback", "Channel:" + channel + "-"
                                + message.toString());
                    }

                    @Override
                    public void connectCallback(String channel) {
                        Log.i("ConnectCallback", "Connected to channel :"
                                + channel);
                    }

                    @Override
                    public void reconnectCallback(String channel) {
                        Log.i("ReconnectCallback", "Reconnecting to channel :"
                                + channel);
                    }

                    @Override
                    public void disconnectCallback(String channel) {
                        Log.i("DisconnectCallback", "Disconnected to channel :"
                                + channel);
                    }
                }

                // Listen for Messages (Subscribe)
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel);         // Channel Name
                args.put("callback", new Receiver()); // Callback to get response
                pubnub.subscribe(args);

            } catch (Exception e) {
                e.printStackTrace();
                Log.v("ERROR", "While downloading");
            }

            return Boolean.TRUE;
        }

        @Override
        protected void onPreExecute() {
        }

        protected void onPostExecute(Boolean result) {
        }
    }


    class PresenceDownloader extends AsyncTask<String, Void, Boolean> {

        @Override
        protected Boolean doInBackground(String... params) {
            try {
                // Android: (Subscribe)
                
                class Receiver implements Callback {
                    public boolean subscribeCallback(String channel,
                            Object message) {
                        Log.i("Message Received", message.toString());
                        myMessage = message.toString();
                        r.sendEmptyMessage(0);
                        return true;
                    }

                    @Override
                    public boolean presenceCallback(String channel,
                                                    Object message) {
                        Log.i("Message Received", message.toString());
                        myMessage = message.toString();
                        r.sendEmptyMessage(0);
                        return true;
                    }

                    @Override
                    public void errorCallback(String channel, Object message) {
                        Log.e("ErrorCallback", "Channel:" + channel + "-"
                                + message.toString());
                    }

                    @Override
                    public void connectCallback(String channel) {
                        Log.i("ConnectCallback", "Connected to channel :"
                                + channel);
                    }

                    @Override
                    public void reconnectCallback(String channel) {
                        Log.i("ReconnectCallback", "Reconnecting to channel :"
                                + channel);
                    }

                    @Override
                    public void disconnectCallback(String channel) {
                        Log.i("DisconnectCallback", "Disconnected to channel :"
                                + channel);
                    }
                }

                // Listen for Messages (Subscribe)
                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", channel + "-pnpres");         // Channel Name with -pnpres appended for Presence
                args.put("callback", new Receiver()); // Callback to get response
                pubnub.subscribe(args);

            } catch (Exception e) {
                e.printStackTrace();
                Log.v("ERROR", "While downloading");
            }

            return Boolean.TRUE;
        }

        @Override
        protected void onPreExecute() {
        }

        protected void onPostExecute(Boolean result) {
        }
    }

    String publish_key = "demo", subscribe_key = "demo";
    String secret_key = "demo", cipher_key = "";
    Boolean ssl_on = false;

    // User Supplied Options PubNub
    Pubnub pubnub_user_supplied_options = new Pubnub(publish_key, // OPTIONAL (supply "" to disable)
            subscribe_key,   // REQUIRED
            secret_key,      // OPTIONAL (supply "" to disable)
            cipher_key,      // OPTIONAL (supply "" to disable)
            ssl_on           // OPTIONAL (supply "" to disable)
    );

    // High Security PubNub
    Pubnub pubnub_high_security = new Pubnub(
            // Publish Key
            "pub-c-a30c030e-9f9c-408d-be89-d70b336ca7a0",

            // Subscribe Key
            "sub-c-387c90f3-c018-11e1-98c9-a5220e0555fd",

            // Secret Key
            "sec-c-MTliNDE0NTAtYjY4Ni00MDRkLTllYTItNDhiZGE0N2JlYzBl",

            // Cipher Key
            "YWxzamRmbVjFaa05HVnGFqZHM3NXRBS73jxmhVMkjiwVVXV1d5UrXR1JLSkZFRr"
                    + "WVd4emFtUm1iR0TFpUZvbiBoYXMgYmVlbxWkhNaF3uUi8kM0YkJTEVlZYVFjBYi"
                    + "jFkWFIxSkxTa1pGUjd874hjklaTFpUwRVuIFNob3VsZCB5UwRkxUR1J6YVhlQWa"
                    + "V1ZkNGVH32mDkdho3pqtRnRVbTFpUjBaeGUgYXNrZWQtZFoKjda40ZWlyYWl1eX"
                    + "U4RkNtdmNub2l1dHE2TTA1jd84jkdJTbFJXYkZwWlZtRnKkWVrSRhhWbFpZVmFz"
                    + "c2RkZmTFpUpGa1dGSXhTa3hUYTFwR1Vpkm9yIGluZm9ybWFNfdsWQdSiiYXNWVX"
                    + "RSblJWYlRGcFVqQmFlRmRyYUU0MFpXbHlZV2wxZVhVNFJrTnR51YjJsMWRIRTJU"
                    + "W91ciBpbmZvcm1hdGliBzdWJtaXR0ZWQb3UZSBhIHJlc3BvbnNlLCB3ZWxsIHJl"
                    + "VEExWdHVybiB0am0aW9uIb24gYXMgd2UgcG9zc2libHkgY2FuLuhcFe24ldWVns"
                    + "dSaTFpU3hVUjFKNllWaFdhRmxZUWpCaQo34gcmVxdWlGFzIHNveqQl83snBfVl3",

            // 2048bit SSL ON - ENABLED TRUE
            false);

    // Channel | Message Test Data (UTF-8)
    String message = " עברית~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
    Pubnub _pubnub;
    ArrayList<String> many_channels = new ArrayList<String>();
    HashMap<String, Object> status = new HashMap<String, Object>(3);
    HashMap<String, Object> threads = new HashMap<String, Object>(4);
    int max_retries = 10;

    // Full Unit Test
    public void runUnitTest(View v) {
        /*final AlertDialog.Builder b = new AlertDialog.Builder(
                PubnubTestActivity.this);
        b.setIcon(android.R.drawable.ic_dialog_alert);
        b.setTitle("Unit Test");
        b.setMessage("Please see the logs (Info) for detailed result.");
        b.setNegativeButton("OK",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog,
                            int which) {
                    }
                });
        b.show();*/
        unitTest(pubnub_user_supplied_options);
        unitTest(pubnub_high_security);
    }

    private void unitTest(Pubnub pubnub) {
        _pubnub = pubnub;
        for (int i = 0; i < max_retries; i++) {
            many_channels.add("channel_" + i);
        }

        status.put("sent", 0);
        status.put("received", 0);
        status.put("connections", 0);

        for (final String _channel : many_channels) {
            Thread t = new Thread() {
                public void run() {
                    HashMap<String, Object> args = new HashMap<String, Object>(2);
                    args.put("channel", _channel);
                    args.put("callback", new ReceivedMessage()); // Callback to get response

                    // Listen for Messages (Subscribe)
                    _pubnub.subscribe(args);
                };
            };
            t.start();
            threads.put(_channel, t);

            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    // Callback Interface when a Message is Received
    class ReceivedMessage implements Callback {

        @Override
        public boolean subscribeCallback(String channel, Object message) {
            Integer sent = (Integer) status.get("sent");
            Integer received = (Integer) status.get("received");

            test(received <= sent, "many sends");
            status.remove(received);
            status.put("received", received.intValue() + 1);
            HashMap<String, Object> args = new HashMap<String, Object>(1);
            args.put("channel", channel);
            _pubnub.unsubscribe(args);

            HashMap<String, Object> argsHistory = new HashMap<String, Object>(2);
            argsHistory.put("channel", channel);
            argsHistory.put("limit", 2);

            // Get History
            JSONArray response = _pubnub.history(argsHistory);
            if (response != null) {
                test(true, " History with channel " + channel);
            }
            return true;
        }

        @Override
        public boolean presenceCallback(String channel,
                                        Object message) {
            Log.i("Message Received", message.toString());
            myMessage = message.toString();
            r.sendEmptyMessage(0);
            return true;
        }

        @Override
        public void errorCallback(String channel, Object message) {
            Log.e("Pubnub", "Channel:" + channel + "-" + message.toString());
        }

        @Override
        public void connectCallback(String channel) {
            Log.e("Pubnub", "Connected to channel :" + channel);

            Integer connections = (Integer) status.get("connections");
            status.remove(connections);
            status.put("connections", connections.intValue() + 1);

            JSONArray array = new JSONArray();
            array.put("Sunday");
            array.put("Monday");
            array.put("Tuesday");
            array.put("Wednesday");
            array.put("Thursday");
            array.put("Friday");
            array.put("Saturday");

            HashMap<String, Object> args = new HashMap<String, Object>(2);
            args.put("channel", channel);
            args.put("message", array);

            JSONArray response = _pubnub.publish(args);
            Integer sent = (Integer) status.get("sent");
            status.remove(sent);
            status.put("sent", sent.intValue() + 1);

            test(true, "publish complete");
            test(true, "publish response" + response);
        }

        @Override
        public void reconnectCallback(String channel) {
            Log.e("Pubnub", "Reconnected to channel :" + channel);
        }

        @Override
        public void disconnectCallback(String channel) {
            Log.e("Pubnub", "Disconnected to channel :" + channel);
        }
    }

    private void test(Boolean trial, String name) {
        if (trial)
            Log.e("PASS ", name);
        else
            Log.e("- FAIL - ", name);
    }
}
