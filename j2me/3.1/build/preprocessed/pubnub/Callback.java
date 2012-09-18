
package pubnub;

public interface Callback {

    public abstract void publishCallback(String channel,Object message);
    public abstract void subscribeCallback(String channel,Object message);
     public abstract void historyCallback(String channel,Object message);
    public abstract void errorCallback(String channel, Object message);
    
     public abstract void connectCallback(String channel);
     public abstract void reconnectCallback(String channel);
     public abstract void disconnectCallback(String channel);
}

