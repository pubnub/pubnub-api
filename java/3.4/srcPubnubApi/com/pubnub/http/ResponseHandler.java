package com.pubnub.http;

/**
 * @author PubnubCore
 */

public abstract class ResponseHandler {
    public abstract void handleResponse(String response);
    public abstract void handleError(String response);
    public void handleTimeout() {}
}
