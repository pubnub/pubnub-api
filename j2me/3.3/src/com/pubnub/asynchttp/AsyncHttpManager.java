package com.pubnub.asynchttp;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;

public class AsyncHttpManager {

    private Vector _waiting = new Vector();
    private Worker _worker;
    
    private void init() {
    	_worker = new Worker();
    	new Thread(_worker).start();
    }
    
    public AsyncHttpManager() {
    	init();
    }
    
    public void stop(){
    	_worker.die();
    	synchronized(_waiting) {
    		_waiting.removeAllElements();
    	}
    }

    public static boolean isRedirect(int rc) {
        return (rc == HttpConnection.HTTP_MOVED_PERM
                || rc == HttpConnection.HTTP_MOVED_TEMP
                || rc == HttpConnection.HTTP_SEE_OTHER
                || rc == HttpConnection.HTTP_TEMP_REDIRECT);
    }
    
    public void queue(AsyncHttpCallback cb) {
    	cb.setConnManager(this);
    	
        synchronized (_waiting) {
            AsyncConnection conn = new AsyncConnection(cb);
            _waiting.addElement(conn);
            _waiting.notifyAll();
        }
        System.out.println("added to queue");
    }

    private static class AsyncConnection {
    	private AsyncHttpCallback _callback;
        AsyncConnection(AsyncHttpCallback cb) {
            _callback = cb;
        }
        AsyncHttpCallback getCallback() {
            return _callback;
        }
    }
    
    private class Worker implements Runnable {

        public void die() {
            _die = true;
        }

        private void process(AsyncConnection conn) {

            AsyncHttpCallback cb = conn.getCallback();
            String url = null;
            try {
            	HttpConnection hc = conn.getConnection();
                boolean process = true;
                
                if (hc == null) {
                    url = cb.startingCall();

                    if (url == null) {
                        return;
                    }
                }
                
                int follow = 5;

                while (follow-- > 0) {
                	hc = conn.getHttpConnection();
                    if (hc == null) {
                        try {
                            System.out.println(url);
                            hc = (HttpConnection) Connector.open(url, Connector.READ_WRITE, true);
                            hc.setRequestMethod(HttpConnection.GET);
                            Hashtable headers = cb.getHeaderFields();
                            Enumeration en = headers.keys();
                            while (en.hasMoreElements()) {
                                String key = (String) en.nextElement();
                                String val = (String) headers.get(key);
                                hc.setRequestProperty(key, val);

                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                    cb.setConnection(hc);
                    if (!cb.prepareRequest(hc)) {
                        return;
                    }
                    int rc = hc.getResponseCode();
                    if (!cb.checkResponse(hc)) {
                        process = false;
                        break;
                    } else if (!isRedirect(rc)) {
                        break;
                    }

                    url = hc.getHeaderField("Location");
                    if (url == null) {
                        throw new IOException("No Location header");
                    }

                    if (url.startsWith("/")) {
                        StringBuffer b = new StringBuffer();
                        b.append("http://");
                        b.append(hc.getHost());
                        b.append(':');
                        b.append(hc.getPort());
                        b.append(url);
                        url = b.toString();
                    } else if (url.startsWith("ttp:")) {
                        url = "h" + url;
                    }
                    close(hc);
                }

                if (follow == 0) {
                    throw new IOException("Too many redirects");
                }

                if (process) {
                    cb.processResponse(hc);
                }

                cb.endingCall(hc);

            } catch (Throwable e) {
            } finally {
                
            }


        }

        
        public void run() {
            do {
                AsyncConnection conn = null;
                System.out.println("waiting size : " + _waiting.size() );
                synchronized (_waiting) {

                    while (!_die) {

                        if (_waiting.size() != 0) {
                            conn = (AsyncConnection) _waiting.firstElement();
                            _waiting.removeElementAt(0);
                            break;
                        }

                        try {
                            _waiting.wait(1000);
                        } catch (InterruptedException e) {
                        }
                    }
                }

                if (conn != null) {
                    if (_die) {
                        closeConn();
                    } else {
                        process(conn);
                    }
                }
            } while (!_die);
            System.out.println("EXITING WORKER");
        }
        public volatile boolean _die;
       
    }
}
