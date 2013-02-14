package com.pubnub.httpclient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Enumeration;
import java.util.Hashtable;


import com.pubnub.api.PubnubException;


public class HttpClientCore extends HttpClient {
	private int requestTimeout = 310000;
	private int connectionTimeout = 5000;
	HttpURLConnection connection;


    public void abortCurrentRequest(){

    }

    private void init() {
    	HttpURLConnection.setFollowRedirects(true);
    }
	public HttpClientCore() {
		init();
	}

	public HttpClientCore(int requestTimeout, int connTimeout) {
		this();
		this.setRequestTimeout(requestTimeout);
		this.setConnectionTimeout(connTimeout);
	}

	public HttpClientCore(int requestTimeout) {
		this();
		this.setRequestTimeout(requestTimeout);
	}

	public int getRequestTimeout() {
		return requestTimeout;
	}

	public void setRequestTimeout(int requestTimeout) {
		this.requestTimeout = requestTimeout;
	}

	public int getConnectionTimeout() {
		return connectionTimeout;
	}

	public void setConnectionTimeout(int connectionTimeout) {
		this.connectionTimeout = connectionTimeout;
	}

	public boolean isRedirect(int rc) {
		return (rc == HttpURLConnection.HTTP_MOVED_PERM
				|| rc == HttpURLConnection.HTTP_MOVED_TEMP
				|| rc == HttpURLConnection.HTTP_SEE_OTHER  );
	}

	public boolean checkResponse(int rc) {
		return (rc == HttpURLConnection.HTTP_OK || isRedirect(rc));
	}

	public boolean checkResponseSuccess(int rc) {
		return (rc == HttpURLConnection.HTTP_OK);
	}

	private static String readInput(InputStream in) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte bytes[] = new byte[1024];

        int n = in.read(bytes);

        while (n != -1) {
            out.write(bytes, 0, n);
            n = in.read(bytes);
        }

        return new String(out.toString());
    }

	public HttpResponse fetch(String url) throws IOException, PubnubException {
		return fetch(url, null);
	}

	public synchronized HttpResponse fetch(String url, Hashtable headers) throws IOException, PubnubException {
		System.out.println(url);
		URL urlobj = new URL(url);
		 connection = (HttpURLConnection) urlobj.openConnection();
		 connection.setRequestMethod("GET");
		if (_headers != null) {
			Enumeration en = _headers.keys();
			while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			String val = (String) _headers.get(key);
			connection.addRequestProperty(key, val);
			}
		}
		if (headers != null) {
			Enumeration en = headers.keys();
			while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			String val = (String) headers.get(key);
			connection.addRequestProperty(key, val);
			}
		}
		connection.setReadTimeout(requestTimeout);
		connection.setConnectTimeout(connectionTimeout);
		connection.connect();

		String page = readInput(connection.getInputStream());

		return new HttpResponse(connection.getResponseCode(), page);
	}

	public boolean isOk(int rc) {
		return (rc == HttpURLConnection.HTTP_OK );
	}
	public void shutdown() {
		connection.disconnect();
	}
}
