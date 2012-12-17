package com.pubnub.util;

import java.io.IOException;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;

public interface AsyncHttpCallback {

    String startingCall( Object cookie );
    boolean prepareRequest( HttpConnection conn,Object cookie )throws IOException;
    boolean checkResponse( HttpConnection conn,Object cookie )throws IOException;
    void processResponse( HttpConnection conn,Object cookie ) throws IOException;
   
    void endingCall( HttpConnection conn,Object cookie,String request_for ,String Channel )throws IOException;
    void cancelingCall( HttpConnection conn,String channel,Object cookie,Throwable exception ) throws IOException;
    Hashtable getHeaderFields();
    String getRequestFor();
    String getChannel();

    public HttpConnection getConnection();
 

    public void setConnection(HttpConnection _connection);
   
}