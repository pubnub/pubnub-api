package com.pubnub.api;

import java.util.Vector;

import com.pubnub.http.HttpRequest;
import com.pubnub.httpclient.HttpClient;
import com.pubnub.httpclient.HttpResponse;


abstract class Worker implements Runnable {
	private Vector _requestQueue;
	protected volatile boolean _die;
	private Thread thread;
	protected HttpClient httpclient;

	protected static Logger log = new Logger(
			RequestManager.class);

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

	public void setHeader(String key, String value) {
		httpclient.setHeader(key, value);
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

		if (!_die) {
			if (hresp == null) {
				log.debug("Error in fetching url : " + hreq.getUrl());
				hreq.getResponseHandler().handleError("Network Error");
				return;
			}
			hreq.getResponseHandler().handleResponse(hresp.getResponse());
		}
	}

}




abstract class RequestManager {

	private static int _maxWorkers = 1;
	protected Vector _waiting = new Vector();
	protected Worker _workers[];
	protected String name;

	public static int getWorkerCount() {
		return _maxWorkers;
	}

	public abstract Worker getWorker();

	private void initManager(int maxCalls, String name) {
		if (maxCalls < 1) {
			maxCalls = 1;
		}
		this.name = name;
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

	public void resetWorkersConnections() {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].resetConnection();
		}
	}

	public void setHeader(String key, String value){
		for (int i = 0; i < _workers.length; i++){
			_workers[i].setHeader(key, value);
		}
	}

	public abstract void clearRequestQueue();


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


abstract class  AbstractSubscribeManager extends RequestManager {

	public AbstractSubscribeManager(String name) {
		super(name);
	}

	public Worker getWorker() {
		return new SubscribeWorker(_waiting);
	}

	public void setMaxRetries(int maxRetries) {
		for (int i = 0; i < _workers.length; i++){
			((SubscribeWorker)_workers[i]).setMaxRetries(maxRetries);
		}
	}

	public void setRetryInterval(int retryInterval) {
		for (int i = 0; i < _workers.length; i++){
			((SubscribeWorker)_workers[i]).setRetryInterval(retryInterval);
		}
	}

}

abstract class AbstractNonSubscribeManager extends RequestManager {
	public AbstractNonSubscribeManager(String name) {
		super(name);
	}

	public Worker getWorker() {
		return new NonSubscribeWorker(_waiting);
	}
}

abstract class AbstractSubscribeWorker extends Worker {
	protected int maxRetries = 5;
	protected int retryInterval = 5000;

	AbstractSubscribeWorker(Vector _requestQueue) {
		super(_requestQueue);
	}

	public void setMaxRetries(int maxRetries) {
		this.maxRetries = maxRetries;
	}

	public void setRetryInterval(int retryInterval) {
		this.retryInterval = retryInterval;
	}


}