package com.pubnub.api;

public interface Callback {

	public abstract boolean successCallback(String channel, Object message);

	public abstract void errorCallback(String channel, Object message);

	public abstract void connectCallback(String channel);

	public abstract void reconnectCallback(String channel);

	public abstract void disconnectCallback(String channel);

}
