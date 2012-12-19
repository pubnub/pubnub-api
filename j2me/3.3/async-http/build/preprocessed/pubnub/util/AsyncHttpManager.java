package pubnub.util;

import java.io.DataOutputStream;
import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import javax.microedition.io.StreamConnection;

// Manages a series of asynchronous HTTP requests.
// To make a request, call the queue method and pass an
// object that implements AsyncHttpCallback and an optional
// cookie. The request will be queued and executed on a
// separate thread. At any point you can cancel all pending
// and executing requests by calling the cancelAll method.
public class AsyncHttpManager {

    private AsyncHttpManager() {
    }

    public void cancel(HttpCallback cb) {
        for (int i = 0; i < _workers.length; ++i) {
            if (_workers[i].asyncConnection != null) {
                if (cb.getRequestFor().equals(_workers[i].asyncConnection._callback.getRequestFor())) {
                  if(!_workers[i].asyncConnection._callback.getChannel().endsWith("-pnpres"))
                  {                   
                    cancel(_workers[i].asyncConnection, null);
                    _workers[i].asyncConnection=null;
                  }
                   // _workers[i].isUnsuscribe=true;
                }
            }
        }
       
    }
    // Cancels a single connection, invoking the
    // appropriate callback.

    private void cancel(AsyncConnection conn, Throwable e) {
        AsyncHttpCallback cb = conn.getCallback();

        try {
          
            close(conn);
            cb.cancelingCall(conn.getHttpConnection(),conn.getCallback().getChannel(),
                    conn.getCookie(),
                    e);
        } catch (IOException ignore) {
        } finally {
            close(conn);
          
        }
    }

    // Cancels all pending requests. Those currently
    // being executed are cancelled as soon as possible,
    // the pending ones are cancelled immediately.
    public void cancelAll() {
        synchronized (_waiting) {

            // Signal each worker thread to end at the
            // earliest opportunity. We don't kill them,
            // we just forget about them and leave them
            // to die.

            for (int i = 0; i < _workers.length; ++i) {
                _workers[i].die();
            }

            // Now run through the queue of waiting
            // requests and cancel each HTTP operation.
            // Cancelling is done by closing each
            // HttpConnection, though whether the call
            // is cancelled immediately or not is up to
            // the system.

            while (_waiting.size() != 0) {
                AsyncConnection conn = (AsyncConnection) _waiting.firstElement();
                _waiting.removeElementAt(0);

                cancel(conn, null);
            }

            // Clean up

            _workers = null; // clear out workers
            _waiting.notifyAll(); // wakes all the workers

        }
    }

    // Close an asynchronous connection. A simple
    // convenience method useful for cleanup.
    private void close(AsyncConnection conn) {
        if (conn != null) {
            close(conn.getHttpConnection());
            conn.setHttpConnection(null);
        }
    }

    // Close an HttpConnection. Convenience method. 
    // We don't care about any I/O exceptions.
    private void close(HttpConnection hc) {
        if (hc != null) {
            try {
                hc.close();
              } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    // Return the singleton instance of the manager,
    // creating it if necessary. All interaction will
    // be through this instance.
    public static synchronized AsyncHttpManager getInstance() {
        if (_singleton == null) {
            _singleton = new AsyncHttpManager();
        }

        return _singleton;
    }

    // Returns number of worker threads to create. The
    // number obviously depends on what the underlying
    // platform supports. If the platform only supports
    // two simultaneous HTTP connections, don't set this
    // value any higher than 2.
    public static int getWorkerCount() {
        return _maxWorkers;
    }

    // Initialize the worker threads. Creates and starts
    // a new thread for each worker.
    private void init(int maxCalls) {
        if (maxCalls < 1) {
            maxCalls = 1;
        }

        _workers = new Worker[maxCalls];

        for (int i = 0; i < maxCalls; ++i) {
            Worker w = new Worker();
            _workers[i] = w;
            new Thread(w).start();

        }
    }

    // Is HTTP Return code a redirection? Convenience
    // method.
    public static boolean isRedirect(int rc) {
        return (rc == HttpConnection.HTTP_MOVED_PERM
                || rc == HttpConnection.HTTP_MOVED_TEMP
                || rc == HttpConnection.HTTP_SEE_OTHER
                || rc == HttpConnection.HTTP_TEMP_REDIRECT);
    }

    // Queues a request for processing. A unique cookie
    // will be generated for each request.
    public void queue(AsyncHttpCallback request) {
        queue(request, null, null);
    }

    // Queues a request for processing. The given
    // cookie will be passed back to the callback
    // methods unchanged. If the cookie is null,
    // a unique cookie will be generated.
    public void queue(AsyncHttpCallback request,
            Object cookie) {
        queue(request, cookie, null);
    }

    // Queues a request for processing with an initial
    // HttpConnection already defined. The given cookie
    // will be passed back to the callback methods. If
    // the cookie is null, a unique cookie will be
    // generated.
    public void queue(AsyncHttpCallback cb,
            Object cookie,
            HttpConnection hc) {

        // Synchronize on the queue of waiting
        // requests. If there are no worker threads
        // available, create them. Queue a new call
        // request and then wake the worker threads
        // to let them process the request.

        synchronized (_waiting) {
            if (_workers == null) {
                init(_maxWorkers);
            }

            AsyncConnection conn =
                    new AsyncConnection(cb, cookie, hc);

            _waiting.addElement(conn);
            _waiting.notifyAll(); // wake the workers
        }
    }

    // Sets the maximum worker count. Adjust this
    // as appropriate for the device.
    public static void setWorkerCount(int count) {
        _maxWorkers = count;
    }
    private static int _maxWorkers = 4;
    private static AsyncHttpManager _singleton;
    private Vector _waiting = new Vector();
    private Worker _workers[];

    // AsyncConnection Class --------------------------------
    //
    // Holds the information about a request needed to invoke
    // the callbacks.
    private static class AsyncConnection {

        // Initialize a connection with the given
        // callback and cookie. If cookie is null,
        // creates a new one.
        AsyncConnection(AsyncHttpCallback cb,
                Object cookie) {
            this(cb, cookie, null);
        }

        // Initialize a connection with the given
        // callback, connection and cookie. If cookie
        // is null, creates a new one.
        AsyncConnection(AsyncHttpCallback cb,
                Object cookie,
                HttpConnection hc) {
            _callback = cb;
            _cookie = cookie;
            _httpconn = hc;

            if (_cookie == null) {
                _cookie = new Object();
            }
        }

        AsyncHttpCallback getCallback() {
            return _callback;
        }

        Object getCookie() {
            return _cookie;
        }

        HttpConnection getHttpConnection() {
            return _httpconn;
        }

        void setHttpConnection(HttpConnection hc) {
            _httpconn = hc;
        }
        private AsyncHttpCallback _callback;
        private Object _cookie;
        private HttpConnection _httpconn;
    }

    // Worker Class ----------------------------------------
    //
    // Worker waits for a new connection request to be
    // queued and then processes it.
    private class Worker implements Runnable {

        // Tells worker to stop what it's doing and exit
        // as soon as possible.
        public void die() {
            _die = true;
        }

        // Processes a connection request. Implicitly
        // handles HTTP redirections unless checkResponse
        // indicates otherwise.
        private void process(AsyncConnection conn) {

            AsyncHttpCallback cb = conn.getCallback();
            String url = null;
            try {
                HttpConnection hc = conn.getHttpConnection();
                Object cookie = conn.getCookie();

                boolean process = true;

                // Get the starting URL

                if (hc == null) {
                    url = cb.startingCall(cookie);

                    if (url == null) {

                        cancel(conn, null);
                        return;
                    }
                }

                // Prepare the connection and then check
                // the response, handling redirects as
                // necessary.

                int follow = 5;

                while (follow-- > 0) {
                    hc = conn.getHttpConnection();

                    if (hc == null) {

                        try {

                            hc = (HttpConnection) Connector.open(url,Connector.READ_WRITE,true);
                            hc.setRequestMethod(HttpConnection.GET);
                            Hashtable headers = cb.getHeaderFields();
                            Enumeration en = headers.keys();
                            while (en.hasMoreElements()) {
                                String key = (String) en.nextElement();
                                String val = (String) headers.get(key);
                                hc.setRequestProperty(key, val);
                                
                            }
                           
                            conn.setHttpConnection(hc);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                    cb.setConnection(hc);
                    if (!cb.prepareRequest(hc, cookie)) {
                        cancel(conn, null);
                        return;
                    }
                    int rc = hc.getResponseCode();
                    if (!cb.checkResponse(hc, cookie)) {
                        process = false;
                        break;
                    } else if (!isRedirect(rc)) {
                        break;
                    }

                    // Handle redirects here

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

                    conn.setHttpConnection(null);
                    close(hc);
                }

                // Ooops, can't actually get it...

                if (follow == 0) {
                    throw new IOException("Too many redirects");
                }

                // Now we can process the data

                if (process) {
                    cb.processResponse(hc, cookie);
                }

                cb.endingCall(hc, cookie, cb.getRequestFor(),cb.getChannel());
                asyncConnection = null;
                close(conn);
            } catch (Throwable e) {
            e.printStackTrace();   
            }finally
            {
                close(conn);
            }


        }

        // Worker thread main logic. Pulls a single
        // request off the queue and processes it.
        public void run() {
            do {
                AsyncConnection conn = null;

                // Wait for a request to arrive on the
                // queue. When a request is queued, the
                // manager will wake all the threads.

                synchronized (_waiting) {

                    while (!_die) {

                        if (_waiting.size() != 0) {
                            conn = (AsyncConnection) _waiting.firstElement();
                            _waiting.removeElementAt(0);
                            break;
                        }

                        try {
                            _waiting.wait();
                        } catch (InterruptedException e) {
                        }
                    }
                }

                // If we have a connection request,
                // we must either cancel it or
                // process it....

                if (conn != null) {
                    asyncConnection = conn;
                    if (_die) {
                        cancel(conn, null);
                    } else {
                        process(conn);
                    }
                }
            } while (!_die);

        }
        private volatile boolean _die;
        public AsyncConnection asyncConnection;
    }
}
