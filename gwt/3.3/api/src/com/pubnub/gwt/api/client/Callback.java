/**
 * 
 */
package com.pubnub.gwt.api.client;

/**
 * @author Pubnub 
 *
 */
public abstract class Callback {
    public void callback(String channel, Object message){}

    public void error(String channel, Object message){}

    public void connect(String channel){}

    public void reconnect(String channel){}

    public void disconnect(String channel){}
}
