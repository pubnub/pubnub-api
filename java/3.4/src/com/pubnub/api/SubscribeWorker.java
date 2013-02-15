package com.pubnub.api;

import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.Vector;

import com.pubnub.http.HttpRequest;
import com.pubnub.httpclient.HttpResponse;

class SubscribeWorker extends AbstractSubscribeWorker {

	SubscribeWorker(Vector _requestQueue) {
		super(_requestQueue);
	}

	void process(HttpRequest hreq) {
		HttpResponse hresp = null;
		int currentRetryAttempt = 1;
		while (currentRetryAttempt <= maxRetries) {
			try {
				log.debug(hreq.getUrl());
				hresp = httpclient.fetch(hreq.getUrl(), hreq.getHeaders());
				if (hresp != null && httpclient.checkResponseSuccess(hresp.getStatusCode())) {
					currentRetryAttempt = 1;
					break;
				}
			}
			catch (Exception e) {
				log.trace("Retry Attempt : " + currentRetryAttempt + " Exception in Fetch : " + e.toString());
				currentRetryAttempt++;
			}

			try {
				Thread.sleep(retryInterval);
			} catch (InterruptedException e) {
			}
		}
		if (!_die) {
			if (hresp == null) {
				log.debug("Error in fetching url : " + hreq.getUrl());
				if (currentRetryAttempt > maxRetries) {
					log.trace("Exhausted number of retries");
					hreq.getResponseHandler().handleTimeout();
				} else
					hreq.getResponseHandler().handleError("Network Error");
				return;
			}
			log.debug(hresp.getResponse());
			hreq.getResponseHandler().handleResponse(hresp.getResponse());
		}

	}
}