package examples;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

import pubnub.Callback;
import pubnub.Pubnub;

class CallbackExample {

    public static void main(String args[]) {

        String publish_key = "demo", subscribe_key = "demo", secret_key = "", cipher_key = "";
        Boolean ssl_on = false;

        Pubnub pubnub_user_supplied_options = new Pubnub(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);

        CallbackExample pubnub = new CallbackExample();
        pubnub.unitTest(pubnub_user_supplied_options);
    }

    String message = " ~`!@#$%^&*()+=[]\\{}|;\':,./<>?abcd עברית";

    Pubnub _pubnub;

    ArrayList<String> many_channels = null;
    LinkedHashMap<String, Object> status = null;
    LinkedHashMap<String, Object> threads = null;
    int max_retries = 10;


    private void unitTest(Pubnub pubnub) {
        many_channels = new ArrayList<String>();
        status = new LinkedHashMap<String, Object>();
        threads = new LinkedHashMap<String, Object>();

        _pubnub = pubnub;


        status.put("sent", 0);
        status.put("received", 0);
        status.put("connections", 0);

        final String _channel = "callback_test";

        Thread t = new Thread() {
            public void run() {

                HashMap<String, Object> args = new HashMap<String, Object>(2);
                args.put("channel", _channel);
                args.put("callback", new CallbackExample.CallbackImplementation());   // callback to get response

                System.out.println("Subscribing to channel: " + args.get("channel"));
                _pubnub.subscribe(args);
            }
        };

        t.start();
        threads.put(_channel, t);

        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    // Callback Interface when a Message is Received
    class CallbackImplementation implements Callback {

        @Override
        public boolean subscribeCallback(String channel, Object message) {
            System.out.println("Receiving message: " + message.toString() + " on channel: " + channel);
            return true;
        }

        @Override
        public void errorCallback(String channel, Object message) {
            System.out.println("Error received on channel " + channel + " " + message.toString());
        }

        @Override
        public void connectCallback(String channel) {
            System.out.println("Connected to channel: " + channel);
            return;
        }

        @Override
        public void reconnectCallback(String channel) {
            System.out.println("Reconnecting to channel: " + channel);
        }

        @Override
        public void disconnectCallback(String channel) {
            System.out.println("Disconnected from channel: " + channel);
        }
    }
}
