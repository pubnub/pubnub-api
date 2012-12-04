package com.pubnub.api;

/**
 * Interface to be implemented by objects to be passed to subscribe/presence as callback
 * @author Pubnub
 *
 */
public interface Callback {

    /**
     * This callback will be invoked when a message is received on the channel
     * @param channel Channel Name
     * @param message Message
     * @return True to keep listening on channel, False to stop listening on channel
     */
    public abstract boolean successCallback(String channel, Object message);

    /**
     * This callback will be invoked when an error occurs
     * @param channel Channel Name
     * @param message Message
     */
    public abstract void errorCallback(String channel, Object message);

    /**
     * This callback will be invoked on getting connected to a channel
     * @param channel Channel Name
     */
    public abstract void connectCallback(String channel);

    /**
     *  This callback is invoked on getting reconnected to a channel after getting disconnected
     * @param channel Channel Name
     */
    public abstract void reconnectCallback(String channel);

    /**
     *  This callback is invoked on getting disconnected from a channel
     * @param channel Channel Name
     */
    public abstract void disconnectCallback(String channel);

}
