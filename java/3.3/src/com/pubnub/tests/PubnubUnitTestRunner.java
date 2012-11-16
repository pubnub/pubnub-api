package com.pubnub.tests;

import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

public class PubnubUnitTestRunner {

    /**
     * @param args
     */
    public static void main(String[] args) {
        Result result = JUnitCore.runClasses(PubnubUnitTest.class);
        for (Failure failure : result.getFailures()) {
            System.out.println(failure.toString());
        }
        if (result.getFailureCount() != 0) {
            System.out.println("Pubnub Unit Test Failed: # of failures - "
                    + result.getFailureCount());
        } else {
            System.out.println("Pubnub Unit Test Completed Successfully.");
        }

    }

}
