package com.aimx.androidpubnub;

import org.json.*;

public interface Callback {
    public abstract boolean execute(JSONObject message);
}