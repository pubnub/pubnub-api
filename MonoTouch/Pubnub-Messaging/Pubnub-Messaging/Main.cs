using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;

namespace PubnubMessaging
{
	public class Application
	{
		// This is the main entry point of the application.
		static void Main (string[] args)
		{
			string strLogLevel = "3";
			int iLogLevel;
			if (!Int32.TryParse (strLogLevel, out iLogLevel)) 
			{
				iLogLevel =0;
			}
			//PubNub_Messaging.CommonMethods.LogLevel= (PubNub_Messaging.CommonMethods.Level)iLogLevel;

			//Console.WriteLine(PubNub_Messaging.CommonMethods.LevelError);
			// if you want to use a different Application Delegate class from "AppDelegate"
			// you can specify it here.
			UIApplication.Main (args, null, "AppDelegate");

			PubNub_Messaging.Pubnub_Example.Main2();
		}
	}
}
