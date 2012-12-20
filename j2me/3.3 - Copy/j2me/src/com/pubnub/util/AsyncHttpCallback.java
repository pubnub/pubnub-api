package com.pubnub.util;

import java.io.IOException;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;

public interface AsyncHttpCallback {

    String startingCall();
    
    boolean prepareRequest(HttpConnection conn)throws IOException;
    boolean checkResponse(HttpConnection conn)throws IOException;
    void processResponse(HttpConnection conn) throws IOException;
   
    void endingCall( HttpConnection conn)throws IOException;
    void cancelingCall(HttpConnection conn) throws IOException;
    
    Hashtable getHeaderFields();

    public HttpConnection getConnection();
    public void setConnection(HttpConnection connection);
   
}