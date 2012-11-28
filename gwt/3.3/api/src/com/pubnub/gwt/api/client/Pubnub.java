/**
 * 
 */
package com.pubnub.gwt.api.client;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONObject;
import com.pubnub.gwt.api.client.Callback;

/**
 * @author Pubnub
 *
 */
public class Pubnub extends JavaScriptObject {
    protected Pubnub() {
    }
    private native void alert(String message) /*-{
    alert(message);
    }-*/;
    private static native Pubnub _init(String origin, String pubkey, String subkey, boolean ssl) /*-{
        if (ssl)
            ssl_setting = "on";
        else
            ssl_setting = "off";

        p = $wnd.PUBNUB.init({
            'publish_key'   : pubkey,
            'subscribe_key' : subkey,
            'ssl'           : ssl_setting,
            'origin'        : origin,
            });
        return p;

    }-*/;

    private static native void _time(Callback cb) /*-{
        $wnd.PUBNUB.time(
            function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)("", message.toString());
            }
        );
    }-*/;

    private final native void _uuid(Callback cb) /*-{
        this.uuid(
            function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)("", message);
            }
        );
    }-*/;
    private final native String _uuid() /*-{
        return this.uuid();
    }-*/;

    private final native void _publish(String channel, String obj, Callback cb) /*-{


        this.publish({
            "channel" : channel,
            "message" : eval("(" + obj + ")"),
            "callback" : function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            }
        });    
    }-*/;

    private final native void _publishStr(String channel, String obj, Callback cb) /*-{
            this.publish({
            "channel" : channel,
            "message" : obj, 
            "callback" : function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            }
        });    

}-*/;

    private final native void _subscribe(String channel, Callback cb)/*-{
        this.subscribe({
            "channel" : channel, 
            "callback" :   function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            },
            "error" :   function(message){
                cb.@com.pubnub.gwt.api.client.Callback::error(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            },
            "connect" : function(){
                cb.@com.pubnub.gwt.api.client.Callback::connect(Ljava/lang/String;)(channel);
            },
            "reconnect" : function(){
                cb.@com.pubnub.gwt.api.client.Callback::reconnect(Ljava/lang/String;)(channel);
            },
            "disconnect" : function(){
                cb.@com.pubnub.gwt.api.client.Callback::disconnect(Ljava/lang/String;)(channel);
            },
        });
    }-*/;

    private native final void _history(String channel, int limit, Callback cb) /*-{
        return this.history({
            "channel" : channel,
            "limit"   : limit,
            "callback" : function(message) {
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            }
        });
    }-*/;

    private native final void _unsubscribe(String channel) /*-{
        this.unsubscribe({
            "channel" : channel
        });
    }-*/;

    private native final void _here_now(String channel, Callback cb) /*-{
        this.here_now({
            "channel" : channel, 
            "callback" : function(message){
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            }
        });
    }-*/;

    private native final void _detailedHistory(String channel, String start, String end, int count, boolean reverse, Callback cb) /*-{
        param = {"channel" : channel};
        if ( start != "-1") 
            param["start"] = start;
        if ( end != "-1") 
            param["end"] = end;

        if (count > -1)
            param["count"] = count;

        param["reverse"] = reverse;

        param["callback"] = function(message) {
                cb.@com.pubnub.gwt.api.client.Callback::callback(Ljava/lang/String;Ljava/lang/Object;)(channel, message);
            };

        this.detailedHistory(param);
    }-*/;

    //=================== Public Methods

    public static Pubnub init() {
        return _init("pubsub.pubnub.com", "demo", "demo", true);
    }

    public static Pubnub init(String pubkey, String subkey, boolean ssl) {
        return _init("pubsub.pubnub.com", pubkey, subkey, ssl);
    }
    public static Pubnub init(String origin, String pubkey, String subkey, boolean ssl) {
        return _init(origin, pubkey, subkey, ssl);
    }
    public final void time(Callback cb) {
        _time(cb);
    }

    public final void uuid(Callback cb) {
        _uuid(cb);
    }
    public final String uuid() {
        return _uuid();
    }

    public final void publish(String channel, JSONObject obj, Callback cb) {
        _publish(channel, obj.toString(), cb);
    }

    public final void publish(String channel, String obj, Callback cb) {
        _publishStr(channel, obj, cb);
    }

    public final void publish(String channel, JSONArray obj, Callback cb) {
        _publish(channel, obj.toString(), cb);
    }

    public final void subscribe(String channel, Callback cb) {
        _subscribe(channel, cb);
    }

    public final void unsubscribe(String channel) {
        _unsubscribe(channel);
    }

    public final void presence(String channel, Callback cb) {
        _subscribe(channel + "-pnpres", cb);
    }

    public final void here_now(String channel, Callback cb) {
        _here_now(channel, cb);
    }

    public final void history(String channel, int limit, Callback cb) {
        _history(channel, limit, cb);
    }

    public final void detailedHistory(String channel, long start, long end, int count, boolean reverse, Callback cb) {
        _detailedHistory(channel, String.valueOf(start), String.valueOf(end), count, reverse, cb);
    }

    public final void detailedHistory(String channel, long start, boolean reverse, Callback cb) {
        _detailedHistory(channel, String.valueOf(start), "-1", -1, reverse, cb);

    }

    public final void detailedHistory(String channel, int count, Callback cb) {
        _detailedHistory(channel, "-1", "-1", count, false, cb);

    }
}
