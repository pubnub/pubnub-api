## ---------------------------------------------------
##
## YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
## http://www.pubnub.com/account
##
## ----------------------------------------------------

## -------------------------------------------------
## PubNub 3.1 Real-time Cloud Push API - C#-IIS
## -------------------------------------------------
##
## PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
## This is a cloud-based service for broadcasting Real-time messages
## to thousands of web and mobile clients simultaneously.

## This tutorial is based on .Net Framework 4.0 (Visual Studio 2010)
## and this application is tested on IIS 7.

===============================================================================
TUTORIAL: HOW TO USE
===============================================================================

## Create a new web application

## Add reference of Newtonsoft.Json.dll from applications root\resource directory. 

## To use this API include Pubnub.cs, PubnubCrypto.cs files from applications root\src
## directory to your project and use functions from there as follows.

##  --------------------------------------------------------------------------------
## 	C#-IIS : (Init)
## 	---------------

		//set the channel
		string channel = "hello-world";

        // Initialize pubnub state
        pubnub objPubnub = new pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "demo",  // SECRET_KEY
            "",  	 // CIPHER_KEY (Cipher key is Optional)
            false    // SSL_ON?
            );
			
##  --------------------------------------------------------------------------------
##  C#-IIS : (Publish)
##  ------------------

		List<object> info = null;
		Dictionary<string, object> args = new Dictionary<string, object>();
		// Publish string  message
		args.Add("channel", channel);
		args.Add("message", "Hello Csharp - IIS");
		info = objPubnub.Publish(args);
		// Print response
		Debug.WriteLine("Published messages - >");
		Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

		// Publish message in array format
		args = new Dictionary<string, object>();
		JArray jarr = new JArray();
		jarr.Add("Sunday");
		jarr.Add("Monday");
		jarr.Add("Tuesday");
		jarr.Add("Wednesday");
		jarr.Add("Thursday");
		jarr.Add("Friday");
		jarr.Add("Saturday");
		
		args.Add("channel", channel);
		args.Add("message", jarr);
		info = objPubnub.Publish(args);
		// Print response
		Debug.WriteLine("[ " + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");

		// Publish message in object (key - val) format
		args = new Dictionary<string, object>();
		JObject jObj = new JObject();
		jObj.Add("Name", "John");
		jObj.Add("age", "25");

		args.Add("channel", channel);
		args.Add("message", jObj);
		info = objPubnub.Publish(args);
		// Print response
		Debug.WriteLine("[" + info[0].ToString() + ", " + info[1] + ", " + info[2] + "]");			
##  ------------------------------------------------------------------------------------
##  C#-IIS : (Subscribe)
##  --------------------
		// Subscribe to channel
		pubnub.Procedure Receiver = delegate(object message)
		{
			Debug.WriteLine("[Subscribed data] - " + message);
			return true;
		};
		pubnub.Procedure ConnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};
		pubnub.Procedure DisconnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};
		pubnub.Procedure ReconnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};
		pubnub.Procedure ErrorCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};

		Dictionary<string, object> args = new Dictionary<string, object>();
		args.Add("channel", channel);
		args.Add("callback", Receiver);                 // callback to get response
		args.Add("connect_cb", ConnectCallback);        // callback to get connect event
		args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
		args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
		args.Add("error_cb", ErrorCallback);            // callback to get error event

		// Subscribe
		objPubnub.Subscribe(args);

##  --------------------------------------------------------------------------------
##  C#-IIS : (History)
##  ------------------
		//Get the history of messages 
		
		Dictionary<string, string> args = new Dictionary<string, string>();
		args.Add("channel", channel);
		args.Add("limit", 3.ToString());
		List<object> history = objPubnub.History(args);
		Debug.WriteLine("History messages - > ");
		foreach (object history_message in history)
		{
			Debug.WriteLine(history_message);
		}
        

##  --------------------------------------------------------------------------------
##  C#-IIS : (Time)
##  ---------------
		//Get the time
		Debug.WriteLine("Server Time - > " + objPubnub.Time());
	
##  --------------------------------------------------------------------------------
##  C#-IIS : (UUID)
##  ---------------
		// Get UUID
		Debug.WriteLine("Generated UUID - > " + objPubnub.UUID());

##  ------------------------------------------------------------------------------------
##  C#-IIS : (Unsubscribe)
##  ----------------------
		// Unsubscribe to channel
		pubnub.Procedure Receiver = delegate(object message)
		{
			Debug.WriteLine("[Subscribed data] - " + message);
			Dictionary<string, object> arg = new Dictionary<string, object>();
            arg.Add("channel", channel);
            //Unsubscribe messages
            objPubnub.Unsubscribe(arg); 
			return true;
		};
		pubnub.Procedure ConnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			// Publish String Message
            Dictionary<string, object> publish = new Dictionary<string, object>();
            publish.Add("channel", channel);
            publish.Add("message", "Hello World!!!!");

            // publish Response
            objPubnub.Publish(publish);
			return true;
		};
		pubnub.Procedure DisconnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};
		pubnub.Procedure ReconnectCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};
		pubnub.Procedure ErrorCallback = delegate(object message)
		{
			Debug.WriteLine(message);
			return true;
		};

		Dictionary<string, object> args = new Dictionary<string, object>();
		args.Add("channel", channel);
		args.Add("callback", Receiver);                 // callback to get response
		args.Add("connect_cb", ConnectCallback);        // callback to get connect event
		args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
		args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
		args.Add("error_cb", ErrorCallback);            // callback to get error event

		// Subscribe
		objPubnub.Subscribe(args);

=====================================================================================