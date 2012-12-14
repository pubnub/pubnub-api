using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;

namespace PubnubMessaging
{
	// The UIApplicationDelegate for the application. This class is responsible for launching the 
	// User Interface of the application, as well as listening (and optionally responding) to 
	// application events from iOS.
	[Register ("AppDelegate")]
	public partial class AppDelegate : UIApplicationDelegate
	{
		// class-level declarations
		UIWindow window;
		public static UINavigationController navigation;
		Pubnub_MessagingMain viewController;

		//
		// This method is invoked when the application has loaded and is ready to run. In this 
		// method you should instantiate the window, load the UI into it and then make the window
		// visible.
		//
		// You have 17 seconds to return from this method, or iOS will terminate your application.
		//
		public override bool FinishedLaunching (UIApplication app, NSDictionary options)
		{

			UITabBarController tabBarController;

			window = new UIWindow (UIScreen.MainScreen.Bounds);

			viewController = new Pubnub_MessagingMain();

			var dv = new Pubnub_MessagingMain (){
				Autorotate = true
			};

			navigation = new UINavigationController ();
			navigation.PushViewController (dv, true);

			window = new UIWindow (UIScreen.MainScreen.Bounds);
			window.MakeKeyAndVisible ();
			window.RootViewController = navigation;	
			/*if (UIDevice.CurrentDevice.CheckSystemVersion (5, 0))
				window.RootViewController = navigation;	
			else
				window.AddSubview (navigation.View);*/

			return true;
		}
	}
}

