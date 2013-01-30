package com.pubnub.httpclient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Hashtable;

import org.apache.http.HttpEntity;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DecompressingHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.DefaultHttpRequestRetryHandler;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;

import com.pubnub.api.PubnubException;


public class HttpClientCore extends HttpClient {
	private int requestTimeout = 310000;
	private int connectionTimeout = 5000;
	private DefaultHttpClient defaultHttpClient;
	private DecompressingHttpClient httpClient;
    private Hashtable _headers;
    private HttpGet httpGet;
    private HttpParams httpParams;

    public void abortCurrentRequest(){
    	if (httpGet != null)
    		httpGet.abort();
    }
	public HttpClientCore() {
		DefaultHttpRequestRetryHandler retryHandler = new DefaultHttpRequestRetryHandler(0, false);
		defaultHttpClient = new DefaultHttpClient();
	    defaultHttpClient.setHttpRequestRetryHandler(retryHandler);
		httpClient = new DecompressingHttpClient(defaultHttpClient);
		_headers = new Hashtable();
	    _headers.put("User-Agent", "Java");
	    httpParams = httpClient.getParams();
	    HttpConnectionParams.setSoTimeout(httpParams, requestTimeout);
	    HttpConnectionParams.setConnectionTimeout(httpParams, connectionTimeout);
	    
	    System.setProperty("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.SimpleLog");
		System.setProperty("org.apache.commons.logging.simplelog.log.org.apache.http", "error");
	}

	public void setHeader(String key, String value) {
		_headers.put(key, value);
	}
	
	public HttpClientCore(int requestTimeout, int connTimeout) {
		this();
		this.setRequestTimeout(requestTimeout);
		this.setConnectionTimeout(connTimeout);
		HttpConnectionParams.setSoTimeout(httpParams, requestTimeout);
		HttpConnectionParams.setConnectionTimeout(httpParams, connectionTimeout);
	}

	public HttpClientCore(int requestTimeout) {
		this();
		this.setRequestTimeout(requestTimeout);
		HttpConnectionParams.setSoTimeout(httpParams, requestTimeout);
	}
	
	public int getRequestTimeout() {
		return requestTimeout;
	}

	public void setRequestTimeout(int requestTimeout) {
		this.requestTimeout = requestTimeout;
		HttpConnectionParams.setSoTimeout(httpParams, requestTimeout);
	}

	public int getConnectionTimeout() {
		return connectionTimeout;
	}

	public void setConnectionTimeout(int connectionTimeout) {
		this.connectionTimeout = connectionTimeout;
		HttpConnectionParams.setConnectionTimeout(httpParams, connectionTimeout);
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

	public HttpResponse fetch(String url) throws IOException, PubnubException {
		return fetch(url, null);
	}

	public synchronized HttpResponse fetch(String url, Hashtable headers) throws IOException, PubnubException {
		httpGet = new HttpGet(url);
		if (_headers != null) {
			Enumeration en = _headers.keys();
			while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			String val = (String) _headers.get(key);
			httpGet.addHeader(key, val);
			}
		}
		if (headers != null) {
			Enumeration en = headers.keys();
			while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			String val = (String) headers.get(key);
			httpGet.addHeader(key, val);
			}
		}
		org.apache.http.HttpResponse response = httpClient.execute(httpGet);
		HttpEntity entity = response.getEntity();
        String page = readInput(entity.getContent());
        EntityUtils.consume(response.getEntity());	
		if (httpGet.isAborted()) {
			throw new PubnubException("Request Aborted");
		}
		return new HttpResponse(response.getStatusLine().getStatusCode(), page);
	}

	public boolean isOk(int rc) {
		return (rc == HttpStatus.SC_OK );
	}
	public void shutdown() {
		defaultHttpClient.getConnectionManager().shutdown();
	}
}
