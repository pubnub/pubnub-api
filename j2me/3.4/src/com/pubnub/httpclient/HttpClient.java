package com.pubnub.httpclient;

import java.io.IOException;
import java.util.Hashtable;


public abstract class HttpClient {
	private int requestTimeout = 310000;
	private int connTimeout = 5000;

	public static HttpClient getClient() {
		return new HttpClientCore();
	}
	public static HttpClient getClient(int requestTimeout, int connTimeout) {
		return new HttpClientCore(requestTimeout, connTimeout);
	}
	public HttpClient() {

	}
	public HttpClient(int requestTimeout, int connTimeout) {
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

	public abstract boolean isRedirect(int rc);

	public abstract boolean checkResponse(int rc);

	public abstract HttpResponse fetch(String url) throws IOException;

	public abstract HttpResponse fetch(String url, Hashtable headers) throws IOException;
}

