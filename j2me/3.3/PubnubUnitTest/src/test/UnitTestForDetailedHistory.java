package test;

import java.util.Hashtable;
import java.util.Vector;
import javax.microedition.lcdui.StringItem;
import pubnub.Pubnub;
import org.json.me.JSONArray;
import org.json.me.JSONObject;
import pubnub.Callback;

public class UnitTestForDetailedHistory implements Callback {

    String publish_key = "demo";
    String subscribe_key = "demo";
    String secret_key = "demo";
    boolean ssl_on = false;
    Pubnub pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
    String crazy = " ~`!@#$%^&*(???)+=[]\\{}|;\':,./<>?abcd";
    String channel;
    int total_msg = 10;
    Vector inputs = new Vector();
    String starttime = null;
    String endtime = null;
    String midtime = null;
    String _runningUnitTest;
    int _currentCount;
StringItem stringItem;
    public void RunUnitTest(StringItem _stringItem ) {
        stringItem= _stringItem;
        pubnub = new Pubnub(publish_key, subscribe_key, secret_key, ssl_on);
        channel = getBigDecimal(pubnub.time());
        pubnub.setCallback(this);
        System.out.println("Setting up context for Detailed History tests. Please wait ...");
        starttime = getBigDecimal(pubnub.time());

        PublishMessage(0, total_msg / 2, 0);
        midtime = getBigDecimal(pubnub.time());

        PublishMessage(0, total_msg / 2, total_msg / 2);
        
         }

    private String getBigDecimal(long time) {
        return Long.toString(time, 0);
    }

    private void LogPass(boolean pass, String message) {
        if (pass) {
            System.out.println("PASS -" + message);
            stringItem.setText(stringItem.getText()+"\n"+"PASS -" + message);
        } else {
            System.out.println("-FAILE -" + message);
            stringItem.setText(stringItem.getText()+"\n"+"-FAILE -" + message);
        }
    }

    private void PublishMessage(int start, int end, int offset) {
        try {
            System.out.println("Publishing messages");
            for (int i = start + offset; i < end + offset; i++) {

                JSONObject message = new JSONObject();
                message.put("message", i + "  " + crazy);
                Hashtable args = new Hashtable();
                args.put("channel", channel);
                args.put("message", message);
                pubnub.publish(args);

            }
        } catch (Exception e) {
            // TODO: handle exception
        }
    }

    private void test_begin_to_end_count() {
        try {
            int count = 5;

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("start", starttime);
            args.put("end", endtime);
            args.put("count", count + "");
            _currentCount = count;
            _runningUnitTest = "test_begin_to_end_count";
            pubnub.detailedHistory(args);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_end_to_begin_count() {
        try {
            int count = 5;
            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("start", endtime);
            args.put("end", starttime);
            args.put("count", count + "");
            _currentCount = count;
            _runningUnitTest = "test_end_to_begin_count";
            pubnub.detailedHistory(args);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_start_reverse_true() {
        try {

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("start", midtime);
            args.put("reverse", Boolean.TRUE);
            pubnub.detailedHistory(args);
            _runningUnitTest = "test_start_reverse_true";
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_start_reverse_false() {
        try {

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("start", midtime);
            _runningUnitTest = "test_start_reverse_false";
            pubnub.detailedHistory(args);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_end_reverse_true() {
        try {

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("end", midtime);
            args.put("reverse", Boolean.TRUE);
            _runningUnitTest = "test_end_reverse_true";
            pubnub.detailedHistory(args);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_end_reverse_false() {
        try {

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("end", midtime);
            pubnub.detailedHistory(args);
            _runningUnitTest = "test_end_reverse_false";
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_count() {
        try {
            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("count", 5 + "");
            _runningUnitTest = "test_count";
            _currentCount = 5;
            pubnub.detailedHistory(args);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void test_count_zero() {
        try {

            Hashtable args = new Hashtable();
            args.put("channel", channel);
            args.put("count", "" + 0);
            _runningUnitTest = "test_count_zero";
            _currentCount = 0;
            pubnub.detailedHistory(args);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void publishCallback(String channel, Object message, Object responce) {
        try {
            JSONObject msg = new JSONObject(message.toString());
            String text = (String) msg.get("message");
            int index = Integer.parseInt(text.charAt(0) + "");
            JSONArray resp = new JSONArray(responce.toString());
            String timestamp = resp.getString(2);
            System.out.println("Message # " + index + " published with timestamp:" + timestamp);
            stringItem.setText(stringItem.getText()+"\n"+"Message # " + index + " published");
            inputs.addElement(message);

            if (inputs.size() == total_msg / 2) {
                midtime = timestamp;
                long temp = Long.parseLong(midtime);
                temp += 10;
                midtime = Long.toString(temp, 0);
            }

            if (inputs.size() == total_msg) {
                endtime = pubnub.time()+"";
                stringItem.setText(stringItem.getText()+"\n"+"Context setup for Detailed History tests. Now running tests");
                System.out.println("Context setup for Detailed History tests. Now running tests");
                test_begin_to_end_count();
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void subscribeCallback(String channel, Object message) {
    }

    public void historyCallback(String channel, Object message) {
    }

    public void errorCallback(String channel, Object message) {
    }

    public void connectCallback(String channel) {
    }

    public void reconnectCallback(String channel) {
    }

    public void disconnectCallback(String channel) {
    }

    public void hereNowCallback(String channel, Object message) {
    }

    public void presenceCallback(String channel, Object message) {
    }

    public void detailedHistoryCallback(String channel, Object message) {
        try {
            JSONArray responce = new JSONArray(message.toString());
            JSONArray history = responce.getJSONArray(0);
            if (_runningUnitTest.equals("test_begin_to_end_count")) {

                LogPass(history.length() == _currentCount
                        && history.getString(history.length() - 1).toString().equals(
                        new JSONObject(inputs.elementAt(_currentCount - 1).toString()).toString()),
                        "test_begin_to_end_count");
                test_end_to_begin_count();
            } else if (_runningUnitTest.equals("test_end_to_begin_count")) {
                LogPass(history.length() == _currentCount
                        && history.getString(history.length() - 1).toString().equals(
                        new JSONObject(inputs.elementAt(total_msg - 1).toString()).toString()),
                        "test_end_to_begin_count");
                test_start_reverse_true();
            } else if (_runningUnitTest.equals("test_start_reverse_true")) {
                LogPass(history.length() == total_msg / 2
                        && history.getString(history.length() - 1).toString().equals(
                        new JSONObject(inputs.elementAt(total_msg - 1).toString()).toString()),
                        "test_start_reverse_true");
                test_start_reverse_false();
            } else if (_runningUnitTest.equals("test_start_reverse_false")) {
                LogPass(history.getString(0).toString().equals(
                        inputs.elementAt(0).toString()),
                        "test_start_reverse_false");
                test_end_reverse_true();
            } else if (_runningUnitTest.equals("test_end_reverse_true")) {
                LogPass(history.getString(0).toString().equals(
                        inputs.elementAt(0).toString()),
                        "test_end_reverse_true");
                test_end_reverse_false();
            } else if (_runningUnitTest.equals("test_end_reverse_false")) {
                LogPass(history.length() == total_msg / 2
                        && (new JSONObject(history.getString(history.length() - 1).toString())).toString().equals(
                        inputs.elementAt(total_msg - 1).toString()), "test_end_reverse_false");
                test_count();
            } else if (_runningUnitTest.equals("test_count")) {
                LogPass(history.length() == 5, "test_count");
                test_count_zero();
            } else if (_runningUnitTest.equals("test_count_zero")) {
                LogPass(history.length() == 0, "test_count_zero");
            }
        } catch (Exception e) {
        }
    }
}
