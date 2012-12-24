package com.pubnub.api;

/** 
 * @author Pubnub
 */

interface ResponseHandler {
    public abstract void handleResponse(String response);
    public abstract void handleError(String response);
}