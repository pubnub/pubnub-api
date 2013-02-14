package com.pubnub.examples;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.Hashtable;
import java.util.List;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.widget.TextView;
import com.example.PubnubExample.R;
import org.apache.http.conn.util.InetAddressUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

public class MainActivity extends Activity {
    // Noise Test
    //Pubnub pubnub = new Pubnub("pub-c-87f96934-8c44-4f8d-a35f-deaa2753f083", "sub-c-3a693cf8-7401-11e2-8b02-12313f022c90", "", false);
    //String channel = "noise";
    String channel = "a";


    Pubnub pubnub = new Pubnub("demo", "demo", "", false);
    //String channel = "hello_world";
    EditText ed;
    protected int count;



    private BroadcastReceiver myRssiChangeReceiver
            = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            NetworkInfo.State mState;
            NetworkInfo mNetworkInfo;
            NetworkInfo mOtherNetworkInfo;
            String mReason;
            Boolean mIsFailover;




            if (!action.equals(ConnectivityManager.CONNECTIVITY_ACTION) ) {
                Log.e("******* NET: ", "onReceived() called with " + intent);
                return;
            }

            boolean noConnectivity = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);

            if (noConnectivity) {
                mState = NetworkInfo.State.DISCONNECTED;
            } else {
                mState = NetworkInfo.State.CONNECTED;
            }

            mNetworkInfo = (NetworkInfo) intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
            mOtherNetworkInfo = (NetworkInfo) intent.getParcelableExtra(ConnectivityManager.EXTRA_OTHER_NETWORK_INFO);

            mReason = intent.getStringExtra(ConnectivityManager.EXTRA_REASON);
            mIsFailover = intent.getBooleanExtra(ConnectivityManager.EXTRA_IS_FAILOVER, false);


            Log.e("******* NET: ", "onReceive(): mNetworkInfo=" + mNetworkInfo + " mOtherNetworkInfo = "
                        + (mOtherNetworkInfo == null ? "[none]" : mOtherNetworkInfo + " noConn=" + noConnectivity)
                        + " mState=" + mState.toString() + " reason: " + mReason + " failover: " + mIsFailover);

            TextView ipText = (TextView) findViewById(R.id.ip);
            ipText.setText(getIPAddress(true));

        }
    };



    private void DisplayWifiState() {

        ConnectivityManager myConnManager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
        NetworkInfo myNetworkInfo = myConnManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        WifiManager myWifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        WifiInfo myWifiInfo = myWifiManager.getConnectionInfo();

        // textMac.setText(myWifiInfo.getMacAddress());

        TextView ipText = (TextView) findViewById(R.id.ip);

        if (myNetworkInfo.isConnected()) {
            int myIp = myWifiInfo.getIpAddress();

            // textConnected.setText("--- CONNECTED ---");

            int intMyIp3 = myIp / 0x1000000;
            int intMyIp3mod = myIp % 0x1000000;

            int intMyIp2 = intMyIp3mod / 0x10000;
            int intMyIp2mod = intMyIp3mod % 0x10000;

            int intMyIp1 = intMyIp2mod / 0x100;
            int intMyIp0 = intMyIp2mod % 0x100;



            ipText.setText(String.valueOf(intMyIp0)
                    + "." + String.valueOf(intMyIp1)
                    + "." + String.valueOf(intMyIp2)
                    + "." + String.valueOf(intMyIp3)
            );

//            textSsid.setText(myWifiInfo.getSSID());
//            textBssid.setText(myWifiInfo.getBSSID());
//
//            textSpeed.setText(String.valueOf(myWifiInfo.getLinkSpeed()) + " " + WifiInfo.LINK_SPEED_UNITS);
//            textRssi.setText(String.valueOf(myWifiInfo.getRssi()));
        } else {
//            textConnected.setText("--- DIS-CONNECTED! ---");
            ipText.setText("---");
//            textSsid.setText("---");
//            textBssid.setText("---");
//            textSpeed.setText("---");
//            textRssi.setText("---");
        }

    }




    private void notifyUser(Object message) {
        try {
            if (message instanceof JSONObject) {
                final JSONObject obj = (JSONObject) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj.toString(),
                                Toast.LENGTH_LONG).show();

                        Log.e("Received msg : ", String.valueOf(obj));
                    }
                });

            } else if (message instanceof String) {
                final String obj = (String) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj,
                                Toast.LENGTH_LONG).show();
                        Log.e("Received msg : ", obj.toString());
                    }
                });

            } else if (message instanceof JSONArray) {
                final JSONArray obj = (JSONArray) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj.toString(),
                                Toast.LENGTH_LONG).show();
                        Log.e("Received msg : ", obj.toString());
                    }
                });
            }


        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getIPAddress(boolean useIPv4) {
        try {
            List<NetworkInterface> interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());
            for (NetworkInterface intf : interfaces) {
                List<InetAddress> addrs = Collections.list(intf.getInetAddresses());
                for (InetAddress addr : addrs) {
                    if (!addr.isLoopbackAddress()) {
                        String sAddr = addr.getHostAddress().toUpperCase();
                        boolean isIPv4 = InetAddressUtils.isIPv4Address(sAddr);
                        if (useIPv4) {
                            if (isIPv4)
                                return sAddr;
                        } else {
                            if (!isIPv4) {
                                int delim = sAddr.indexOf('%'); // drop ip6 port suffix
                                return delim < 0 ? sAddr : sAddr.substring(0, delim);
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
        } // for now eat exceptions
        return "";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        this.registerReceiver(this.myRssiChangeReceiver,
                new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));

        TextView ipText = (TextView) findViewById(R.id.ip);
        ipText.setText(getIPAddress(true));


        Button publishBtn = (Button) findViewById(R.id.btnPublish);
        publishBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                ed = (EditText) findViewById(R.id.editText1);

                JSONObject message = new JSONObject();
                try {
                    if (ed.getText().toString() != null
                            && !ed.getText().toString().equals(""))
                        message.put("Message", ed.getText().toString());
                } catch (org.json.JSONException jsonError) {
                }

                // Publish Message
                Hashtable args = new Hashtable(2);
                args.put("channel", channel); // Channel Name
                args.put("message", message); // JSON Message
                pubnub.publish(args, new Callback() {
                    public void successCallback(String channel, Object message) {
                        notifyUser(message.toString());
                    }

                    public void errorCallback(String channel, Object message) {
                        notifyUser(channel + " : " + message.toString());
                    }
                });
            }
        });

        Button subscribeBtn = (Button) findViewById(R.id.btnSubscribe);
        subscribeBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                Hashtable args = new Hashtable(1);
                args.put("channel", channel);

                try {
                    pubnub.subscribe(args, new Callback() {
                        public void connectCallback(String channel) {
                            notifyUser("CONNECT on channel:" + channel);
                        }

                        public void disconnectCallback(String channel) {
                            notifyUser("DISCONNECT on channel:" + channel);
                        }

                        public void reconnectCallback(String channel) {
                            notifyUser("RECONNECT on channel:" + channel);
                        }

                        public void successCallback(String channel,
                                                    Object message) {
                            notifyUser(channel + " " + message.toString());
                        }
                    });

                } catch (Exception e) {

                }

            }
        });

        Button presenceBtn = (Button) findViewById(R.id.btnPresence);
        presenceBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                try {
                    pubnub.presence(channel, new Callback() {
                        public void successCallback(String channel,
                                                    Object message) {
                            notifyUser(message.toString());
                        }

                        public void errorCallback(String channel, Object message) {
                            notifyUser(channel + " : " + message.toString());
                        }
                    });
                } catch (PubnubException e) {

                }

            }
        });


        Button toggleRoRBtn = (Button) findViewById(R.id.btnToggleRoR);
        toggleRoRBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Boolean previousState = pubnub.isResumeOnReconnect();
                pubnub.setResumeOnReconnect(pubnub.isResumeOnReconnect() ? false : true);
                Log.e("Resume on reconnect: ", String.format("Setting from: %s to %s", String.valueOf(previousState), String.valueOf(pubnub.isResumeOnReconnect())));

            }
        });

        Button disconnectAndResubButton = (Button) findViewById(R.id.btnDisconnectAndResubscribe);
        disconnectAndResubButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                pubnub.disconnectAndResubscribe();

            }
        });

        Button detailedHistoryBtn = (Button) findViewById(R.id.btnDetailedHistory);
        detailedHistoryBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                pubnub.detailedHistory(channel, 2, new Callback() {
                    public void successCallback(String channel, Object message) {
                        notifyUser(message.toString());
                    }

                    public void errorCallback(String channel, Object message) {
                        notifyUser(channel + " : " + message.toString());
                    }
                });

            }
        });
        Button hereNowBtn = (Button) findViewById(R.id.btnHereNow);
        hereNowBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                pubnub.hereNow(channel, new Callback() {
                    public void successCallback(String channel, Object message) {
                        notifyUser(message.toString());
                    }

                    public void errorCallback(String channel, Object message) {
                        notifyUser(channel + " : " + message.toString());
                    }
                });

            }
        });

        Button pubSubBtn = (Button) findViewById(R.id.btnPubSubTest);
        pubSubBtn.setOnClickListener(new OnClickListener() {
            private int sub_succ = 0;
            private int sub_fail = 0;
            private int pub_succ = 0;
            private int pub_fail = 0;
            private int total = 100;
            private String channel = "3.3-noise";


            @Override
            public void onClick(View v) {
                Hashtable args = new Hashtable(1);
                args.put("channel", channel);
                System.out.println("debug PubSubTest");
                notifyUser(channel);

                try {
                    pubnub.subscribe(args, new Callback() {
                        public void successCallback(String channel,
                                                    Object message) {
                            sub_succ++;
                            notifyUser(" " + sub_succ);
                            Log.e("Received count : ", String.valueOf(sub_succ));
                        }

                        public void errorCallback(String channel,
                                                  Object message) {
                            System.out.println(message);
                            notifyUser("failed");
                            sub_fail++;
                        }
                    });
                    notifyUser("subscribed");

                } catch (Exception e) {
                    e.printStackTrace();
                }
                for (int i = 0; i < total; i++) {
                    // Publish Message
                    Hashtable args1 = new Hashtable(2);
                    args1.put("channel", channel); // Channel Name
                    JSONObject message = new JSONObject();
                    try {
                        message.put("Message", "Testing Android Pub/Sub");
                    } catch (org.json.JSONException jsonError) {
                    }
                    args1.put("message", message); // JSON Message
                    pubnub.publish(args1, new Callback() {
                        public void successCallback(String channel, Object message) {
                            pub_succ++;
                        }

                        public void errorCallback(String channel, Object message) {
                            System.out.println(message);
                            pub_fail++;
                        }
                    });
                }
                try {
                    Thread.sleep(60000);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                String result = "Publish Success : " + pub_succ + " , " +
                        "Publish Failure : " + pub_fail + " , " +
                        "Subscribe Success : " + sub_succ + " , " +
                        "Subscribe Failure : " + sub_fail;
                System.out.println(result);
                notifyUser(result);
                pub_succ = pub_fail = sub_succ = sub_fail = 0;
            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.activity_main, menu);

        return true;
    }

}
