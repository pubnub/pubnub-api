package com.pubnub.api;

import java.util.UUID;

public class Pubnub extends PubnubCore {
	public Pubnub(String publish_key, String subscribe_key, String secret_key,
			String cipher_key, boolean ssl_on) {
		super(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
	}

	public Pubnub(String publish_key, String subscribe_key, String secret_key,
			boolean ssl_on) {
		super(publish_key, subscribe_key, secret_key, "", ssl_on);
	}


	public Pubnub(String publish_key, String subscribe_key) {
		super(publish_key, subscribe_key, "", "", false);
	}

	public Pubnub(String publish_key, String subscribe_key, boolean ssl) {
		super(publish_key, subscribe_key, "", "", ssl);
	}

	public Pubnub(String publish_key, String subscribe_key, String secret_key) {
		super(publish_key, subscribe_key, secret_key, "", false);
	}

	@Override
	public String uuid() {
		return UUID.randomUUID().toString();
	}
}
