package com.pubnub.http;

/**
 * @author Pubnub
 */

public interface ResponseHandler {
    public abstract void handleResponse(String response);
    public abstract void handleError(String response);
}
