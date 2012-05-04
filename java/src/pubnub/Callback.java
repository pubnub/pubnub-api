package pubnub;


public interface Callback {
    public abstract boolean execute(Object message) ;
}
