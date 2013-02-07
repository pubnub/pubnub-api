package com.pubnub.api;

class SubscribeManager extends AbstractSubscribeManager {

	public SubscribeManager(String name) {
		super(name);
	}

	public void resetWorkersConnections() {
		for (int i = 0; i < _workers.length; i++){
			_workers[i].resetConnection();
		}
	}

	public void clearRequestQueue() {
		_waiting.clear();
	}
}
