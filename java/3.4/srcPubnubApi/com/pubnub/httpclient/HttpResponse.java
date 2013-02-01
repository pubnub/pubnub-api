package com.pubnub.httpclient;

public class HttpResponse {
	private int statusCode;
	private String response;

	public String getResponse() {
		return response;
	}

	public void setResposnse(String resposnse) {
		this.response = resposnse;
	}

	public int getStatusCode() {
		return statusCode;
	}

	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
	}

	public HttpResponse(int statusCode, String response) {
		this.setResposnse(response);
		this.setStatusCode(statusCode);
	}

}
