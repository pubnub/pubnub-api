package com.pubnub.api;

import java.io.IOException;
import java.net.SocketException;
import java.util.Vector;

import org.apache.http.conn.HttpHostConnectException;
import org.apache.log4j.Logger;

import com.pubnub.http.HttpRequest;
import com.pubnub.httpclient.HttpClient;
import com.pubnub.httpclient.HttpResponse;


abstract class Worker implements Runnable {
	private Vector _requestQueue;
	private volatile boolean _die;
	private Thread thread;
	protected HttpClient httpclient;

	protected static Logger log = Logger.getLogger(
			RequestManager.class.getName());

	public Thread getThread() {
		return thread;
	}

	void setThread(Thread thread) {
		this.thread = thread;
	}

	void startWorker() {
		thread.start();
	}

	void interruptWorker() {
		thread.interrupt();
	}

	void resetConnection() {
		httpclient.reset();
	}

	Worker(Vector _requestQueue) {
		this._requestQueue = _requestQueue;
		this.httpclient = HttpClient.getClient();
	}

	void setConnectionTimeout(int timeout) {
		if (httpclient != null) {
			httpclient.setConnectionTimeout(timeout);
		}
	}

	void setRequestTimeout(int timeout) {
		if (httpclient != null) {
			httpclient.setRequestTimeout(timeout);
		}
	}

	void die() {
		_die = true;
	}

	abstract void process(HttpRequest hreq);

	public void run() {
		do {
			HttpRequest hreq = null;
			while (!_die) {

				synchronized (_requestQueue) {
					
					if (_requestQueue.size() != 0) {
						hreq = (HttpRequest) _requestQueue.firstElement();
						_requestQueue.removeElementAt(0);
						break;
					}
					try {
						_requestQueue.wait(1000);
					} catch (InterruptedException e) {
					}
				}
			}
			if (hreq != null) {
				if (!_die) {
					process(hreq);
				}
			}
		} while (!_die);
	}
}

class NonSubscribeWorker extends Worker {

	NonSubscribeWorker(Vector _requestQueue) {
		super(_requestQueue);
	}

	@Override
	void process(HttpRequest hreq) {
		HttpResponse hresp = null;
			try {
				log.debug(hreq.getUrl());
				hresp = httpclient.fetch(hreq.getUrl(), hreq.getHeaders());
			} catch (Exception e) {
				log.debug("Exception in Fetch : " + e.toString());
				hreq.getResponseHandler().handleError("Network Error " + e.toString());
				return;
			}
		
		if (hresp == null || !httpclient.checkResponseSuccess(hresp.getStatusCode())) {
			log.debug("Error in fetching url : " + hreq.getUrl());
			hreq.getResponseHandler().handleError("Network Error");
			return;
		}
		hreq.getResponseHandler().handleResponse(hresp.getResponse());
	}

}

class SubscribeWorker extends Worker {
	private int MAX_RETRIES = 5;
	
	private int retryInterval = 5000;
	SubscribeWorker(Vector _requestQueue) {
		super(_requestQueue);
	}

	@Override
	void process(HttpRequest hreq) {
		HttpResponse hresp = null;
		int currentRetryAttempt = 1;
		while (currentRetryAttempt <= MAX_RETRIES) {
			try {
				log.debug(hreq.getUrl());
				hresp = httpclient.fetch(hreq.getUrl(), hreq.getHeaders());
				if (hresp != null && httpclient.checkResponseSuccess(hresp.getStatusCode())) {
					currentRetryAttempt = 1;
					break;
				}
			}
			catch (HttpHostConnectException e) {
				log.trace("Retry Attempt : " + currentRetryAttempt + " Exception in Fetch : " + e.toString());
				currentRetryAttempt++;
			}
			catch (IllegalStateException e) {
				log.trace("Exception in Fetch : " + e.toString());
				return;
			}
			catch (SocketException e){
				log.trace("Exception in Fetch : " + e.toString());
				return;
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
		if (hresp == null) {
			log.debug("Error in fetching url : " + hreq.getUrl());
			if (currentRetryAttempt > MAX_RETRIES) {
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


abstract class RequestManager {

	private static int _maxWorkers = 1;
	protected Vector _waiting = new Vector();
	private Worker _workers[];

	public static int getWorkerCount() {
		return _maxWorkers;
	}

	public abstract Worker getWorker();

	private void initManager(int maxCalls, String name) {
		if (maxCalls < 1) {
			maxCalls = 1;
		}
		_workers = new Worker[maxCalls];

		for (int i = 0; i < maxCalls; ++i) {
			Worker w = getWorker();
			w.setThread(new Thread(w,name));
			_workers[i] = w;
			w.startWorker();

		}
	}

	public static void init() {

	}
	public RequestManager(String name) {
		init();
		initManager(_maxWorkers, name);
	}

	private void interruptWorkers() {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].interruptWorker();
		}
	}

	private void resetWorkersConnections() {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].resetConnection();
		}
	}

	public void clearRequestQueue() {
		_waiting.clear();
	}


	public void resetHttpManager() {
		clearRequestQueue();
		resetWorkersConnections();
	}

	public void abortClearAndQueue(HttpRequest hreq) {
		resetHttpManager();
		queue(hreq);
	}

	public void queue(HttpRequest hreq) {
		synchronized (_waiting) {
			_waiting.addElement(hreq);
			_waiting.notifyAll();
		}
	}

	public static void setWorkerCount(int count) {
		_maxWorkers = count;
	}

	public void setConnectionTimeout(int timeout) {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].setConnectionTimeout(timeout);
		}
	}

	public void setRequestTimeout(int timeout) {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].setRequestTimeout(timeout);
		}
	}

	public void stop() {
		for (int i = 0; i < _maxWorkers; ++i) {
			Worker w = _workers[i];
			w.die();
		}
	}
}

class SubscribeManager extends RequestManager {

	public SubscribeManager(String name) {
		super(name);
	}

	@Override
	public Worker getWorker() {
		return new SubscribeWorker(_waiting);
	}

}

class NonSubscribeManager extends RequestManager {
	public NonSubscribeManager(String name) {
		super(name);
	}

	@Override
	public Worker getWorker() {
		return new NonSubscribeWorker(_waiting);
	}

}