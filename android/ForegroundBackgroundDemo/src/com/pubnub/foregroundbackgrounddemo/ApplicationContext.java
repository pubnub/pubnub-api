package com.pubnub.foregroundbackgrounddemo;
import android.app.Application;
import android.content.Context;
import android.util.Log;

public class ApplicationContext extends Application
{

    public static boolean isSubscribed() {
        return subscribed;
    }

    public static void justSubscribed() {
        subscribed = true;
    }

    public static boolean isActivityVisible() {
        return activityVisible;
    }

    public static void activityResumed() {
        activityVisible = true;
    }

    public static void activityPaused() {
        activityVisible = false;
    }

    private static boolean activityVisible;
    private static boolean subscribed = false;


    private static ApplicationContext instance = null;
    private static Pubnub pubnub = null;

    @Override
    public void onCreate() {
        // TODO Auto-generated method stub
        
        super.onCreate();
         instance = this;
         pubnub = new Pubnub("demo", // PUBLISH_KEY
                 "demo",             // SUBSCRIBE_KEY
                 "demo",             // SECRET_KEY
                 "",                 // CIPHER_KEY (Cipher key is Optional)
                 true );
    }
    
    public static Pubnub getPubnub() {
         return pubnub;
    }
    
    public static void setPubnub(Pubnub pubnub) {
        ApplicationContext.pubnub = pubnub;
    }
    
    public static Context getInstance()
    {
        if (null == instance)
        {
            instance = new ApplicationContext();
        }

        return instance;
    }
}