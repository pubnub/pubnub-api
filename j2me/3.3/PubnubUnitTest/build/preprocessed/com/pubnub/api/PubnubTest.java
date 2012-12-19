/*
 * PubnubTest.java
 * JMUnit based test
 *
 * Created on 18 Dec, 2012, 7:46:43 PM
 */

package com.pubnub.api;


import java.util.Hashtable;
import jmunit.framework.cldc10.*;
import org.json.me.JSONObject;

/**
 * @author work
 */
public class PubnubTest extends TestCase {
    
    public PubnubTest() {
        //The first parameter of inherited constructor is the number of test cases
        super(14,"PubnubTest");
    }            

    public void test(int testNumber) throws Throwable {
        switch (testNumber) {    
            case 0:
                testSetCallback();
                break;
            case 1:
                testPublish();
                break;
            case 2:
                testDetailedHistory();
                break;
            case 3:
                testGetCallback();
                break;
            case 4:
                testSubscribe();
                break;
            case 5:
                testEncode();
                break;
            case 6:
                testTime();
                break;
            case 7:
                testGetViaHttpsConnection();
                break;
            case 8:
                testHistory();
                break;
            case 9:
                testUnsubscribe();
                break;
            case 10:
                testHereNow();
                break;
            case 11:
                testDontNeedEncoding();
                break;
            case 12:
                testUuid();
                break;
            case 13:
                testPresence();
                break;
            default:
                break;
        }
    }

    /**
     * Test of testSetCallback method, of class Pubnub.
     */
    public void testSetCallback() throws AssertionFailedException {
        System.out.println("setCallback");
        Pubnub instance = null;
        Callback _callback_1 = null;
        instance.setCallback(_callback_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testPublish method, of class Pubnub.
     */
    public void testPublish() throws AssertionFailedException {
        System.out.println("publish");
        Pubnub instance = null;
        String channel_1 = "";
        JSONObject message_1 = null;
        instance.publish(channel_1, message_1);
        fail("The test case is a prototype.");
        Hashtable args_2 = null;
        instance.publish(args_2);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testDetailedHistory method, of class Pubnub.
     */
    public void testDetailedHistory() throws AssertionFailedException {
        System.out.println("detailedHistory");
        Pubnub instance = null;
        Hashtable args_1 = null;
        instance.detailedHistory(args_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testGetCallback method, of class Pubnub.
     */
    public void testGetCallback() throws AssertionFailedException {
        System.out.println("getCallback");
        Pubnub instance = null;
        Callback expResult_1 = null;
        Callback result_1 = instance.getCallback();
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testSubscribe method, of class Pubnub.
     */
    public void testSubscribe() throws AssertionFailedException {
        System.out.println("subscribe");
        Pubnub instance = null;
        Hashtable args_1 = null;
        instance.subscribe(args_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testEncode method, of class Pubnub.
     */
    public void testEncode() throws AssertionFailedException, Exception {
        System.out.println("encode");
        Pubnub instance = null;
        String s_1 = "";
        String enc_1 = "";
        String expResult_1 = "";
        String result_1 = instance.encode(s_1, enc_1);
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testTime method, of class Pubnub.
     */
    public void testTime() throws AssertionFailedException {
        System.out.println("time");
        Pubnub instance = null;
        long expResult_1 = 0L;
        long result_1 = instance.time();
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testGetViaHttpsConnection method, of class Pubnub.
     */
    public void testGetViaHttpsConnection() throws AssertionFailedException, Exception {
        System.out.println("getViaHttpsConnection");
        Pubnub instance = null;
        String url_1 = "";
        String expResult_1 = "";
        String result_1 = instance.getViaHttpsConnection(url_1);
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testHistory method, of class Pubnub.
     */
    public void testHistory() throws AssertionFailedException {
        System.out.println("history");
        Pubnub instance = null;
        String channel_1 = "";
        int limit_1 = 0;
        instance.history(channel_1, limit_1);
        fail("The test case is a prototype.");
        Hashtable args_2 = null;
        instance.history(args_2);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testUnsubscribe method, of class Pubnub.
     */
    public void testUnsubscribe() throws AssertionFailedException {
        System.out.println("unsubscribe");
        Pubnub instance = null;
        Hashtable args_1 = null;
        instance.unsubscribe(args_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testHereNow method, of class Pubnub.
     */
    public void testHereNow() throws AssertionFailedException {
        System.out.println("hereNow");
        Pubnub instance = null;
        String channel_1 = "";
        instance.hereNow(channel_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testDontNeedEncoding method, of class Pubnub.
     */
    public void testDontNeedEncoding() throws AssertionFailedException {
        System.out.println("dontNeedEncoding");
        int ch_1 = 0;
        boolean expResult_1 = false;
        boolean result_1 = Pubnub.dontNeedEncoding(ch_1);
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testUuid method, of class Pubnub.
     */
    public void testUuid() throws AssertionFailedException {
        System.out.println("uuid");
        Pubnub instance = null;
        String expResult_1 = "";
        String result_1 = instance.uuid();
        assertEquals(expResult_1, result_1);
        fail("The test case is a prototype.");
    }

    /**
     * Test of testPresence method, of class Pubnub.
     */
    public void testPresence() throws AssertionFailedException {
        System.out.println("presence");
        Pubnub instance = null;
        String channel_1 = "";
        instance.presence(channel_1);
        fail("The test case is a prototype.");
    }
}
