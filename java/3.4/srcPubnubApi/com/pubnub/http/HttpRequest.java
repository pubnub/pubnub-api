package com.pubnub.http;

import java.util.Enumeration;
import java.util.Hashtable;

import com.pubnub.api.PubnubUtil;

public class HttpRequest {
	private ResponseHandler responseHandler;
	private Hashtable headers;
    private String[] urlComponents;
    private Hashtable params;
    private String url;

	public HttpRequest(String[] urlComponents, Hashtable params, Hashtable headers, ResponseHandler rh){
		this.setUrlComponents(urlComponents);
		this.setParams(params);
		this.setHeaders(headers);
		this.setResponseHandler(rh);
	}
	
	public HttpRequest(String[] urlComponents, Hashtable params, ResponseHandler rh){
		this.setUrlComponents(urlComponents);
		this.setParams(params);
		this.setResponseHandler(rh);
	}
	
	public HttpRequest(String[] urlComponents, ResponseHandler rh){
		this.setUrlComponents(urlComponents);
		this.setResponseHandler(rh);
	}
	
	public String[] getUrlComponents() {
		return urlComponents;
	}

	public void setUrlComponents(String[] urlComponents) {
		this.urlComponents = urlComponents;
	}

	public Hashtable getParams() {
		return params;
	}

	public void setParams(Hashtable params) {
		this.params = params;
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

        if (url != null) {
            return url;
        }
        
        String url = PubnubUtil.joinString(urlComponents, "/");

        if (this.params != null) {
            StringBuffer sb = new StringBuffer();
            sb.append(url).append("?");

            Enumeration paramsKeys = this.params.keys();
            boolean first = true;
            while (paramsKeys.hasMoreElements()) {
                if (!first) {
                    sb.append("&");
                } else
                    first = false;

                String key = (String) paramsKeys.nextElement();
                sb.append(PubnubUtil.urlEncode((String) key))
                        .append("=")
                        .append(PubnubUtil.urlEncode((String) this.params
                                .get(key)));
            }

            url = sb.toString();
        }
        this.url = url;

        return this.url;
	}
}
