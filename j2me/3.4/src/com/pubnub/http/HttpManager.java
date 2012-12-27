package com.pubnub.http;

import java.io.IOException;
import java.util.Vector;

import javax.microedition.io.HttpConnection;

import com.pubnub.httpclient.HttpClient;
import com.pubnub.httpclient.HttpResponse;

public class HttpManager {

	private static int _maxWorkers = 1;
	private Vector _waiting = new Vector();
	private Worker _workers[];
	private static Network network;

	private class Network {
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
		new Thread(new Heartbeat(url, interval), "heartbeat").start();
	}

	public static int getWorkerCount() {
		return _maxWorkers;
	}

	private void init(int maxCalls, String name) {
		if (maxCalls < 1) {
			maxCalls = 1;
		}
		_workers = new Worker[maxCalls];
		for (int i = 0; i < maxCalls; ++i) {
			Worker w = new Worker();
			_workers[i] = w;
			new Thread(w, name).start();
		}
		if (network == null) {
			network = new Network();
		}
	}

	public HttpManager(String name) {
		init(_maxWorkers, name);
	}

	public void queue(HttpRequest hreq) {

		if (!network.isAvailable()) {
			hreq.getResponseHandler().handleError("[0,'Network Error']");
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

	private static class Heartbeat implements Runnable {
		private boolean runHeartbeat = true;
		private String heartbeatUrl;
		private int heartbeatInterval;

		public Heartbeat(String url, int interval) {
			this.heartbeatUrl = url;
			this.heartbeatInterval = interval;
		}

		public void run() {
			while (runHeartbeat) {
				try {
					HttpClient hcl = HttpClient.getClient();
					HttpResponse hresp = hcl.fetch(heartbeatUrl);

					int rc = hresp.getStatusCode();
					if (rc == HttpConnection.HTTP_OK) {
						network.available();
					} else {
						network.unavailable();
					}

				} catch (IOException e) {
					network.unavailable();

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
			HttpClient hcl = HttpClient.getClient();
			HttpResponse hresp = null;
			try {
				hresp = hcl.fetch(hreq.getUrl(), hreq.getHeaders());
			} catch (IOException e) {
				hreq.getResponseHandler().handleError(e.toString());
				return;
			}
			hreq.getResponseHandler().handleResponse(hresp.getResponse());
		}

		public void run() {
			do {
				HttpRequest hreq = null;

				synchronized (_waiting) {

					while (!_die) {

						if (!network.isAvailable()) {
							synchronized (network) {
								try {
									network.wait(5000);
								} catch (InterruptedException e1) {

								}
							}
						}
						if (_waiting.size() != 0) {
							hreq = (HttpRequest) _waiting.firstElement();
							_waiting.removeElementAt(0);
							break;
						}

						try {
							_waiting.wait(5000);
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
