package com.fbt;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class UnitTestForDetailedHistory {

    String publish_key = "demo";
    String subscribe_key = "demo";
    String secret_key = "demo";
    boolean ssl_on = false;
    Pubnub pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
    String crazy = " ~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
    String channel;

    int total_msg = 10;
    ArrayList<HashMap<String, Object>> inputs = new ArrayList<HashMap<String, Object>>();
    String starttime = null;
    String endtime = null;
    String midtime = null;

    public void RunUnitTest() {
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
        channel = getBigDecimal(pubnub.time());
        Log.e("Message",
                "Setting up context for Detailed History tests. Please wait ...");
        starttime = getBigDecimal(pubnub.time());
        PublishMessage(0, total_msg / 2, 0);
        midtime = getBigDecimal(pubnub.time());
        PublishMessage(0, total_msg / 2, total_msg / 2);
        endtime = getBigDecimal(pubnub.time());
        Log.e("Messahe",
                "Context setup for Detailed History tests. Now running tests");
        
        test_begin_to_end_count();
        test_end_to_begin_count();
        test_start_reverse_true();
        
        test_start_reverse_false();
        test_end_reverse_true();
        test_end_reverse_false();
        test_count_zero();
        test_count();
    }

    private String getBigDecimal(double time) {

        BigDecimal big = new BigDecimal(time);
        return big.toString();
    }

    private void LogPass(boolean pass, String message) {
        if (pass) {
            Log.e("Test", "PASS -" + message);
        } else {
            Log.e("Test", "-FAILE -" + message);
        }
    }

    private void PublishMessage(int start, int end, int offset) {
        try {
            Log.e("PublishMessage", "Publishing messages");
            for (int i = start + offset; i < end + offset; i++) {
                
                JSONObject message= new JSONObject();
                message.put("message",  i + "  " + crazy);
                HashMap<String, Object> args = new HashMap<String, Object>();
                args.put("channel", channel);
                args.put("message", message);
                JSONArray responce = pubnub.publish(args);
                if ((Integer) responce.get(0) == 1) {
                    String timestamp = (String) responce.get(2);
                    HashMap<String, Object> param = new HashMap<String, Object>();
                    param.put("timestamp", timestamp);
                    param.put("message",message);
                    inputs.add(param);
                    Log.e("Sent", "Message #  " + i + "  published");
                }
            }
        } catch (Exception e) {
            // TODO: handle exception
        }
    }

    private void test_begin_to_end_count() {
        try {
            int count = 5;
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("start", starttime);
            args.put("end", endtime);
            args.put("count", count);
            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == count
                    && history.getString(history.length() - 1).equals(
                            inputs.get(count - 1).get("message").toString()),
                    "test_begin_to_end_count");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void test_end_to_begin_count() {
        try {
            int count = 5;
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("start", endtime);
            args.put("end", starttime);
            args.put("count", count);
            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == count
                    && history.getString(history.length() - 1).equals(
                            inputs.get(total_msg - 1).get("message").toString()),
                    "test_end_to_begin_count");
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    
    private void test_start_reverse_true() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("start", midtime);
            args.put("reverse", Boolean.TRUE);
            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == total_msg / 2
                    && history.getString(history.length() - 1).equals(
                            inputs.get(total_msg - 1).get("message").toString()),
                    "test_start_reverse_true");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    
    private void test_start_reverse_false() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("start", midtime);
            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.getString(0).equals(
                            inputs.get(0).get("message").toString()),
                    "test_start_reverse_false");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void test_end_reverse_true() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("end", midtime);
            args.put("reverse", Boolean.TRUE);
            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.getString(0).equals(
                            inputs.get(0).get("message").toString()),
                    "test_end_reverse_true");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    
    
    private void test_end_reverse_false() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("end", midtime);

            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == total_msg / 2
                    && history.getString(history.length() - 1).equals(
                            inputs.get(total_msg - 1).get("message").toString()),"test_end_reverse_true");
        
            
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    
    private void test_count() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("count", 5);

            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == 5,"test_count");
            
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void test_count_zero() {
        try {
            
            HashMap<String, Object> args = new HashMap<String, Object>();
            args.put("channel", channel);
            args.put("count", 0);

            JSONArray responce = pubnub.detailedHistory(args);
            JSONArray history = responce.getJSONArray(0);

            LogPass(history.length() == 0,"test_count_zero");
            
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    
}
