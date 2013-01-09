package com.pubnub.httpclient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Hashtable;

import org.apache.http.HttpEntity;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;


public class HttpClientCore extends HttpClient {
	private int requestTimeout = 310000;
	private int connTimeout = 5000;
	private DefaultHttpClient httpclient = new DefaultHttpClient();
	public HttpClientCore() {

	}

	public HttpClientCore(int requestTimeout, int connTimeout) {
		this.setRequestTimeout(requestTimeout);
		this.setConnTimeout(connTimeout);
	}

	public int getRequestTimeout() {
		return requestTimeout;
	}

	public void setRequestTimeout(int requestTimeout) {
		this.requestTimeout = requestTimeout;
	}

	public int getConnTimeout() {
		return connTimeout;
	}

	public void setConnTimeout(int connTimeout) {
		this.connTimeout = connTimeout;
	}



	public boolean isRedirect(int rc) {
		return (rc == HttpStatus.SC_MOVED_PERMANENTLY
				|| rc == HttpStatus.SC_MOVED_TEMPORARILY
				|| rc == HttpStatus.SC_SEE_OTHER || rc == HttpStatus.SC_TEMPORARY_REDIRECT);
	}

	public boolean checkResponse(int rc) {

		return (rc == HttpStatus.SC_OK || isRedirect(rc));
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

	public HttpResponse fetch(String url) throws IOException {
		return fetch(url, null);
	}

	public HttpResponse fetch(String url, Hashtable headers) throws IOException {
		HttpGet httpget = new HttpGet(url);
		if (headers != null) {
			Enumeration en = headers.keys();
			while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			String val = (String) headers.get(key);
			httpget.addHeader(key, val);

			}
		}
		org.apache.http.HttpResponse response = httpclient.execute(httpget);
		HttpEntity entity = response.getEntity();
        String page = readInput(entity.getContent());
		return new HttpResponse(response.getStatusLine().getStatusCode(), page);
	}

	public boolean isOk(int rc) {
		return (rc == HttpStatus.SC_OK );
	}
}
