package com.pubnub.util;

import java.io.ByteArrayOutputStream;

import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;

// Default implementation of AsyncHttpCallback
public abstract class HttpCallback
        implements AsyncHttpCallback {

    private String _url;
    private Hashtable _headerFields;
    private HttpConnection _connection;
    private AsyncHttpManager _connManager;
    
    public void setConnManager(AsyncHttpManager _connManager) {
        this._connManager = _connManager;
    }

    public void setConnection(HttpConnection _connection) {
        this._connection = _connection;
    }

    public HttpConnection getConnection() {
        return this._connection;
    }

    public HttpCallback(String url, Hashtable headerFields) {
        _url = url;
        _headerFields = headerFields;
    }

    // The URL to open must be provided by subclass.
    public String startingCall() {
        return _url;
    }

    public Hashtable getHeaderFields() {
        return _headerFields;
    }

    // By default there's nothing to do.
    public boolean prepareRequest(HttpConnection hconn)
            throws IOException {
        return true;
    }

    // Only continue if HTTP_OK or one of the redirection
    // codes is returned.
    public boolean checkResponse(HttpConnection hconn)
            throws IOException {

        int rc = hconn.getResponseCode();

        return (rc == HttpConnection.HTTP_OK
                || AsyncHttpManager.isRedirect(rc));
    }

    // Process response.
    public void processResponse(HttpConnection hconn)
            throws IOException {
    }

    public abstract void OnComplete(HttpConnection hconn, int statusCode, String response) throws IOException;

    public abstract void errorCall(HttpConnection hconn, int statusCode, String response) throws IOException;

    // Operation completed with no exceptions. The connection
    // is immediately closed after this call.
    public void endingCall(HttpConnection hconn)
            throws IOException {
        
        int rc = hconn.getResponseCode();

        InputStream in = null;
        String prefix = "";

        try {
            StringBuffer b = new StringBuffer();
            int ch;
            b.append(prefix);
            in = hconn.openInputStream();

            byte[] data = null;
            ByteArrayOutputStream tmp = new ByteArrayOutputStream();

            while ((ch = in.read()) != -1) {
                tmp.write(ch);
            }
            data = tmp.toByteArray();
            tmp.close();
            b.append(new String(data, "UTF-8"));

            if (b.length() > 0) {
                OnComplete(hconn, rc, b.toString());
            }
        } finally {
            if (in != null) {
                try {
                    in.close();
                    hconn.close();
                    hconn = null;
                } catch (IOException e) {
                }
            }
        }

    }

    // Operation was cancelled or aborted.
    public void cancelingCall(HttpConnection hconn)
            throws IOException {

            errorCall(hconn, hconn.getResponseCode(), "Cancelling");
           
    }

    public void cancelRequest(HttpCallback cb) {
        _connManager.cancel(cb);
    }
}
