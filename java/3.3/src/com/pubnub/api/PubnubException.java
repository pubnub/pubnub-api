/**
 * 
 */
package com.pubnub.api;

/**
 * @author Pubnub
 *
 */
public class PubnubException extends Exception {
    private int errorno = 0;
    private String errormsg = "Pubnub Exception Occurred";
    
    public PubnubException(String s){
        this.errormsg = s;
    }
    public PubnubException(int errorno) {
        this.errorno = errorno;
    }
    public PubnubException(int errorno, String errormsg) {
        this.errorno = errorno;
        this.errormsg = errormsg;
    }
    
    public String toString() {
        return errormsg;
    }
}
