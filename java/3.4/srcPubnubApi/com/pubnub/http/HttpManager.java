package com.pubnub.http;

import java.io.IOException;
import java.util.Vector;

import org.apache.log4j.Logger;

import com.pubnub.api.PubnubException;
import com.pubnub.httpclient.HttpClient;
import com.pubnub.httpclient.HttpResponse;

public class HttpManager {

	private static int _maxWorkers = 1;
	private Vector _waiting = new Vector();
	private Worker _workers[];
	private Thread _threads[];
	private static Heartbeat heartbeat;
	private static Network network;
	private HttpClient httpclient;

	private static Logger log = Logger.getLogger(
			HttpManager.class.getName());

	public static void stopHeartbeat() {
		heartbeat.stop();
	}
	private static class Network {
		private boolean available = true;

		public synchronized boolean isAvailable() {
			return available;
		}

		public synchronized void available() {
			available = true;
			this.notifyAll();
		}

		public synchronized void unavailable() {
			available = false;
		}
	}

	public static void startHeartbeat(String url, int interval) {
		init();
		heartbeat = new Heartbeat(url, interval);
		new Thread(heartbeat, "heartbeat").start();
	}

	public static int getWorkerCount() {
		return _maxWorkers;
	}

	private void initManager(int maxCalls, String name) {
		if (maxCalls < 1) {
			maxCalls = 1;
		}
		_workers = new Worker[maxCalls];
		_threads = new Thread[maxCalls];
		for (int i = 0; i < maxCalls; ++i) {
			Worker w = new Worker();
			_workers[i] = w;
			_threads[i] = new Thread(w, name);
			_threads[i].start();
		}
		if (network == null) {
			network = new Network();
		}
		httpclient = HttpClient.getClient();
	}

	public static void init() {
		if (network == null) {
			network = new Network();
		}
	}
	public HttpManager(String name) {
		init();
		initManager(_maxWorkers, name);
	}

	private void interruptWorkers() {
		for (int i = 0; i < _threads.length; i++){
			_threads[i].interrupt();
		}
	}

	public void abortCurrent(){
		//httpclient.reset();
	}
	public void abortCurrentAndClear() {
		abortCurrent();
		synchronized(_waiting) {
			_waiting.clear();
		}
	}
	private  void resetHttpClient() {
		 httpclient = httpclient.reset();

	}
	public void resetHttpManager() {
		abortCurrentAndClear();
		resetHttpClient();
	}
	public void abortClearAndQueue(HttpRequest hreq) {
		resetHttpManager();
		queue(hreq);
	}

	public void queue(HttpRequest hreq) {

		if (!network.isAvailable()) {
			return;
		}

		synchronized (_waiting) {
			_waiting.addElement(hreq);
			_waiting.notifyAll();
		}
	}

	public static void setWorkerCount(int count) {
		_maxWorkers = count;
	}

	public void setConnectionTimeout(int timeout) {
		if (httpclient != null) {
			httpclient.setConnectionTimeout(timeout);
		}
	}

	public void setRequestTimeout(int timeout) {
		if (httpclient != null) {
			httpclient.setRequestTimeout(timeout);
		}
	}

	private static class Heartbeat implements Runnable {
		private boolean runHeartbeat = true;
		private String heartbeatUrl;
		private int heartbeatInterval;
		private HttpClient httpclient;

		public Heartbeat(String url, int interval) {
			this.heartbeatUrl = url;
			this.heartbeatInterval = interval;
			this.httpclient = HttpClient.getClient();
		}
		public void stop() {
			runHeartbeat = false;
		}
		public void run() {
			while (runHeartbeat) {
				try {

					HttpResponse hresp = httpclient.fetch(heartbeatUrl);

					int rc = hresp.getStatusCode();
					if (httpclient.isOk(rc)) {
						network.available();
					} else {
						network.unavailable();
					}

				} catch (IOException e) {
					network.unavailable();

				} catch (PubnubException e) {

				}
				try {
					Thread.sleep(heartbeatInterval);
				} catch (InterruptedException e) {

				}
			}
		}

	}

	public void stop() {
		for (int i = 0; i < _maxWorkers; ++i) {
			Worker w = _workers[i];
			w.die();
		}
	}

	private class Worker implements Runnable {

		public void die() {
			_die = true;
		}

		private void process(HttpRequest hreq) {
			HttpResponse hresp = null;

				if (network.isAvailable()) {
					try {
						log.debug(hreq.getUrl());
						try {
							hresp = httpclient.fetch(hreq.getUrl(), hreq.getHeaders());
						} catch (NullPointerException e) {
							hreq.getResponseHandler().handleError("[0,'Network Error']");
							return;
						}
					} catch (IOException e) {
						hreq.getResponseHandler().handleError(e.toString());
						return;
					} catch (PubnubException e) {
						return;
					}
					hreq.getResponseHandler().handleResponse(hresp.getResponse());
				} else {
					hreq.getResponseHandler().handleError("[0,'Network Error']");
				}

		}

		public void run() {
			do {
				HttpRequest hreq = null;



				while (!_die) {

					if (!network.isAvailable()) {
						synchronized (network) {
							try {
								network.wait(5000);
							} catch (InterruptedException e1) {

							}
						}
					}
					synchronized (_waiting) {

						if (_waiting.size() != 0) {
							hreq = (HttpRequest) _waiting.firstElement();
							_waiting.removeElementAt(0);
							break;
						}

						try {
							_waiting.wait(1000);
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

		public volatile boolean _die;
	}
}
