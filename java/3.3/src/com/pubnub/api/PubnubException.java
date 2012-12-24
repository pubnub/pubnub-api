/**
 * 
 */
package com.pubnub.api;

/**
 * This Exception can be thrown by Pubnub API's in case of critical errors
 * @author Pubnub
 *
 */
public class PubnubException extends Exception {
    private static final long serialVersionUID = 1L;
    private String errormsg = "Pubnub Exception Occurred";
    
    /**
     * Constructor for PubnubException Class with error message as argument
     * @param s Error message
     */
    public PubnubException(String s){
        this.errormsg = s;
    }
    
    /** Read the exception error message
     *  @return String
     */
    public String toString() {
        return errormsg;
    }
}
