package com.pubnub.asynchttp;

import java.io.IOException;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;

public interface AsyncHttpCallback {

    String startingCall();

    boolean checkResponse(HttpConnection conn) throws IOException;

    void endingCall(HttpConnection conn) throws IOException;

    void cancelingCall(HttpConnection conn) throws IOException;

    Hashtable getHeaderFields();

    public HttpConnection getConnection();

    public void setConnection(HttpConnection connection);

    public void setConnManager(AsyncHttpManager connManager);

    public void errorCall(HttpConnection hconn, int statusCode, String response);
}
