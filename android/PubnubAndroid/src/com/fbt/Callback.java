package com.fbt;
import org.json.*;

public interface Callback {
    public abstract boolean execute(JSONObject message);
}
