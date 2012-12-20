package pubnub.util;

import com.tinyline.util.GZIPInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;
import javax.microedition.io.HttpConnection;
import javax.microedition.lcdui.Alert;

// Default implementation of AsyncHttpCallback
public abstract class HttpCallback
        implements AsyncHttpCallback {

    private String _url = "";
    private String _request_for = "";
    private Hashtable _headerFields = new Hashtable();
    private HttpConnection _connection;
    private String _channel = "";
    private Object _message = null;

    public Object getMessage() {
        return _message;
    }

    public void setMessage(Object _message) {
        this._message = _message;
    }
     
    
    private HttpCallback() {
    }

    public void setConnection(HttpConnection _connection) {
       this._connection=_connection;
    }

    public HttpConnection getConnection() {
       return  this._connection;
    }

    public String getChannel() {
        return _channel;
    }

    public void setChannel(String _channel) {
        this._channel = _channel;
    }

    
    
    public HttpCallback(String url, Hashtable headerFields, String request_for) {
        _url = url;
        _headerFields = headerFields;
        _request_for = request_for;
    }

    // The URL to open must be provided by subclass.
    public String startingCall(Object cookie) {
        return _url;
    }

    public Hashtable getHeaderFields() {
        return _headerFields;
    }

    public String getRequestFor() {
        return _request_for;
    }
    // By default there's nothing to do.

    public boolean prepareRequest(HttpConnection conn,
            Object cookie)
            throws IOException {
        return true;
    }

    // Only continue if HTTP_OK or one of the redirection
    // codes is returned.
    public boolean checkResponse(HttpConnection conn,
            Object cookie)
            throws IOException {

        int rc = conn.getResponseCode();

        return (rc == HttpConnection.HTTP_OK
                || AsyncHttpManager.isRedirect(rc));
    }

    // Process response.
    public abstract void processResponse(HttpConnection conn,
            Object cookie)
            throws IOException;

    public abstract void OnComplet(HttpConnection hc, String responce,String req_for,String channel) throws IOException;
   public abstract void errorCall( HttpConnection conn,Object message ) throws IOException;
    // Operation completed with no exceptions. The connection
    // is immediately closed after this call.
    public void endingCall(HttpConnection hc,
            Object cookie ,String req_for,String channel)
            throws IOException {
        int rc = hc.getResponseCode();

        InputStream in = null;
        int lines = 0;
        String prefix = "";

        try {
            StringBuffer b = new StringBuffer();
            int ch;
            b.append(prefix);
            in = hc.openInputStream();
            if ("gzip".equals(hc.getEncoding())) 
                    in = new GZIPInputStream(in);
             byte[] data = null;
            ByteArrayOutputStream tmp = new ByteArrayOutputStream();

            while ((ch = in.read()) != -1) {
                tmp.write(ch);
            }
            data = tmp.toByteArray();
            tmp.close();
            b.append(new String(data,"UTF-8"));
       
            if (b.length() > 0) {
               OnComplet(hc,b.toString(),req_for,channel);
            }
        } finally {
            if (in != null) {
                try {
                    in.close();
                    hc.close();
                    hc = null;
                } catch (IOException e) {
                }
            }
        }

    }
    
    // Operation was cancelled or aborted.
    public void cancelingCall(HttpConnection conn,
           String channel,
            Object cookie,
            Throwable exception)
            throws IOException {
        if (exception != null) {
            errorCall(conn, exception.toString());
             OnComplet(conn, null,getRequestFor(),channel);
        } else {
             OnComplet(conn, null,getRequestFor(),channel);        
        }
    }
    
    public void cancelRequest(HttpCallback cb)
    {
        AsyncHttpManager.getInstance().cancel(cb);
    }
}
