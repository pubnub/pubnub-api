package com.pubnub.api;

class NonSubscribeManager extends AbstractNonSubscribeManager {

	public NonSubscribeManager(String name) {
		super(name);
	}

	public void clearRequestQueue() {
		_waiting.clear();
	}
}
