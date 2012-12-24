package com.pubnub.asynchttp;

import java.io.ByteArrayOutputStream;

import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;

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

    public String startingCall() {
        return _url;
    }

    public Hashtable getHeaderFields() {
        return _headerFields;
    }

    public boolean checkResponse(HttpConnection hconn)
            throws IOException {

        int rc = hconn.getResponseCode();

        return (rc == HttpConnection.HTTP_OK
                || AsyncHttpManager.isRedirect(rc));
    }

    public abstract void OnComplete(HttpConnection hconn, int statusCode, String response);

    public abstract void errorCall(HttpConnection hconn, int statusCode, String response);

    public void endingCall(HttpConnection hconn) throws IOException {
        
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

    public void cancelingCall(HttpConnection hconn)
            throws IOException {
            errorCall(hconn, hconn.getResponseCode(), "Cancelling");
    }

    public void cancelRequest(HttpCallback cb) {
        _connManager.cancel(cb);
    }
}