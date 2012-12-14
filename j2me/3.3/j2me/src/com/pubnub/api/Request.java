/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.pubnub.api;

import java.util.Vector;
import java.util.Hashtable;

/**
 *
 * @author Pubnub
 */
class Request {
    private String url;
    private String channel;
    ResponseHandler responseHandler;
    
    public String getUrl(){
        return this.url;
    }
    public String getChannel() {
        return this.channel;
    }
    public Request(String url, String channel, ResponseHandler responseHandler){
        this.url = url;
        this.channel = channel;
        this.responseHandler = responseHandler;
    }
    public Request(Vector urlComponents, Hashtable params, String channel
            , ResponseHandler responseHandler){
        
    }
    public Request(Vector urlComponents, String channel
            , ResponseHandler responseHandler){
        
    }
    public Request(String[] urlComponents, Hashtable params, String channel
            , ResponseHandler responseHandler){
        
    }
    public Request(String[] urlComponents, String channel
            , ResponseHandler responseHandler){
        
    }
    
}
