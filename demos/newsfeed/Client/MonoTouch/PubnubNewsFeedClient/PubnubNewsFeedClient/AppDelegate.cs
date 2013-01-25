using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;

namespace PubnubNewsFeedClient
{
	// The UIApplicationDelegate for the application. This class is responsible for launching the 
	// User Interface of the application, as well as listening (and optionally responding) to 
	// application events from iOS.
	[Register ("AppDelegate")]
	public partial class AppDelegate : UIApplicationDelegate
	{
		// class-level declarations
		UINavigationController navigationController;
		UISplitViewController splitViewController;

		UIWindow window;
		public static UINavigationController navigation;

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
			
			var dv = new NewsFeedMain (){
				Autorotate = true
			};
			dv.Style = UITableViewStyle.Plain;
			
			navigation = new UINavigationController ();
			navigation.PushViewController (dv, true);
			
			window = new UIWindow (UIScreen.MainScreen.Bounds);
			window.MakeKeyAndVisible ();
			window.RootViewController = navigation;	

			return true;
			// create a new window instance based on the screen size
			/*window = new UIWindow (UIScreen.MainScreen.Bounds);
			
			// load the appropriate UI, depending on whether the app is running on an iPhone or iPad
			if (UIDevice.CurrentDevice.UserInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
				var controller = new RootViewController ();
				navigationController = new UINavigationController (controller);
				window.RootViewController = navigationController;
			} else {
				var masterViewController = new RootViewController ();
				var masterNavigationController = new UINavigationController (masterViewController);
				var detailViewController = new DetailViewController ();
				var detailNavigationController = new UINavigationController (detailViewController);
				
				splitViewController = new UISplitViewController ();
				splitViewController.WeakDelegate = detailViewController;
				splitViewController.ViewControllers = new UIViewController[] {
					masterNavigationController,
					detailNavigationController
				};
				
				window.RootViewController = splitViewController;*/

		}
	}
}

