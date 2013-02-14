package com.pubnub.api;

/**
 *
 * @author PubnubCore
 */
public class PubnubException extends Exception {
    private String errormsg = "PubnubCore Exception Occurred";

    /**
     * Constructor for PubnubException Class with error message as argument
     *
     * @param s
     *            Error message
     */
    public PubnubException(String s) {
        this.errormsg = s;
    }

    /**
     * Read the exception error message
     *
     * @return String
     */
    public String toString() {
        return errormsg;
    }
}
