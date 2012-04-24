package pubnub;

import org.json.JSONObject;

public interface Callback {
    public abstract boolean execute(JSONObject message) ;
}
