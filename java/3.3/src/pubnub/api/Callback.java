package pubnub.api;

public interface Callback {

	public abstract boolean subscribeCallback(String channel, Object message);

	public abstract boolean presenceCallback(String channel, Object message);
	
	public abstract void errorCallback(String channel, Object message);

	public abstract void connectCallback(String channel);

	public abstract void reconnectCallback(String channel);

	public abstract void disconnectCallback(String channel);
}
