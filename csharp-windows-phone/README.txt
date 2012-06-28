## ---------------------------------------------------
##
## YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
## http://www.pubnub.com/account
##
## ----------------------------------------------------

## -------------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - C#-Windows Phone 7
## -------------------------------------------------
##
## PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
## This is a cloud-based service for broadcasting Real-time messages
## to thousands of web and mobile clients simultaneously.

## This tutorial is based on .Net framework 4.0(Visual Studio 2010) and Windows phone sdk 7.1
===============================================================================
TUTORIAL: HOW TO USE
===============================================================================

## Create a new Windows Phone Application

## Add reference of 
##    Newtonsoft.Json.dll from applications root\resource directory.

## To use this API include Pubnub.cs,PubnubCrypto.cs files from applications root\src 
## directory to your project and use functions from them as follows.

##  --------------------------------------------------------------------------------
##  C#-WP7 : (Init)
##  ---------------

        //Channel name
        string channel = "hello_world";

        // Initialize pubnub state
        Pubnub pubnub = new Pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "",      // CIPHER_KEY (Cipher key is Optional)
            false    // SSL_ON?
            );
            
##  --------------------------------------------------------------------------------
##  C#-WP7 : (Publish)
##  ------------------

        Pubnub.ResponseCallback respCallback = delegate(object response)
        {
            List<object> result = (List<object>)response;

            if (result != null && result.Count() > 0)
            {  
                System.Diagnostics.Debug.WriteLine("[" + result[0].ToString() + "," + result[1].ToString() + "," + result[2].ToString() + "]");
            }
        };

        // Publish string  message            
        Dictionary<string, object> strArgs = new Dictionary<string, object>();
        string message = "Hello Windows Phone 7";
        strArgs.Add("channel", channel);
        strArgs.Add("message", message);
        strArgs.Add("callback", respCallback);
        pubnub.Publish(strArgs);

        // Publish message in array format
        Dictionary<string, object> arrArgs = new Dictionary<string, object>();
        JArray jarr = new JArray();
        jarr.Add("Sunday");
        jarr.Add("Monday");
        jarr.Add("Tuesday");
        jarr.Add("Wednesday");
        jarr.Add("Thursday");
        jarr.Add("Friday");
        jarr.Add("Saturday");

        arrArgs.Add("channel", channel);
        arrArgs.Add("message", jarr);
        arrArgs.Add("callback", respCallback);
        pubnub.Publish(arrArgs);

        // Publish message in Dictionary format
        Dictionary<string, object> objArgs = new Dictionary<string, object>();
        JObject obj = new JObject();
        obj.Add("Name", "John");
        obj.Add("age", "25");
        
        objArgs.Add("channel", channel);
        objArgs.Add("message", obj);
        objArgs.Add("callback", respCallback);
        pubnub.Publish(objArgs);    
    
##  ------------------------------------------------------------------------------------
##  C#-WP7 : (Subscribe)
##  --------------------
        //Subscribe messages of type string,json array and json object
        System.Diagnostics.Debug.WriteLine("Subscribed to channel " + channel);
        Pubnub.ResponseCallback respCallback = delegate(object message)
        {
            object[] messages = (object[])message;

            if (messages != null && messages.Count() > 0)
            {
                for (int i = 0; i < messages.Count(); i++)
                {
                    System.Diagnostics.Debug.WriteLine(messages[i]);
                }
            }
        };
        //Subscribe messages
        Dictionary<string, object> args = new Dictionary<string, object>();
        args.Add("channel", channel);
        args.Add("callback", respCallback);
        pubnub.Subscribe(args);

##  --------------------------------------------------------------------------------
##  C#-WP7 : (History)
##  ------------------
        //Get the history of messages depending on limit. 
        
        Pubnub.ResponseCallback respCallback = delegate(object response)
        {
            List<object> result = (List<object>)response;
            
            if (result != null && result.Count() > 0)
            {
                for (int i = 0; i < result.Count(); i++)
                {
                    System.Diagnostics.Debug.WriteLine(result[i]);
                }
            }
        };
        Dictionary<string, object> args = new Dictionary<string, object>();
        args.Add("channel", channel);
        args.Add("limit", 3.ToString());
        args.Add("callback", respCallback);
        pubnub.History(args); 
        

##  --------------------------------------------------------------------------------
##  C#-WP7 : (Time)
##  ---------------
        //Get the time
        Pubnub.ResponseCallback respCallback = delegate(object response)
        {
            List<object> result = (List<object>)response;
            System.Diagnostics.Debug.WriteLine("Server Time : " + result[0]);
        };
        pubnub.Time(respCallback);
    
##  --------------------------------------------------------------------------------
##  C#-WP7 : (UUID)
##  ---------------
        // Get UUID
        System.Diagnostics.Debug.WriteLine("UUID - > " + pubnub.UUID()); 

=====================================================================================