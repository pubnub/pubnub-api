package com.pubnub.http;

import java.util.Hashtable;

public class HttpRequest {
	private ResponseHandler responseHandler;
	private String url;
	private Hashtable headers;

	public HttpRequest(String url, Hashtable headers, ResponseHandler rh){
		this.setUrl(url);
		this.setHeaders(headers);
		this.setResponseHandler(rh);
	}
	HttpRequest(String url, ResponseHandler rh){
		this.setUrl(url);
		this.setResponseHandler(rh);
	}
	public ResponseHandler getResponseHandler() {
		return responseHandler;
	}
	public void setResponseHandler(ResponseHandler responseHandler) {
		this.responseHandler = responseHandler;
	}
	public Hashtable getHeaders() {
		return headers;
	}
	public void setHeaders(Hashtable headers) {
		this.headers = headers;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
}
