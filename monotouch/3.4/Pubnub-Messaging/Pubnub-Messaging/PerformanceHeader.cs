
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNubMessaging.Core;
using System.Threading;
using System.Diagnostics;
using MonoTouch.CoreGraphics;
using System.Drawing;

namespace PubnubMessaging
{
	public class PerformanceHeader: UIViewController
	{
		PerformanceHeaderView performanceHeaderView;
		
		public PerformanceHeader ()
		{
			this.View.Frame = new RectangleF (0, 2, UIScreen.MainScreen.Bounds.Width, 55);
			performanceHeaderView = new PerformanceHeaderView();
			performanceHeaderView.Frame = new RectangleF(0, 0, UIScreen.MainScreen.Bounds.Width, this.View.Bounds.Height);
			performanceHeaderView.AutoresizingMask = UIViewAutoresizing.FlexibleHeight |  UIViewAutoresizing.FlexibleWidth;
			this.View.AddSubviews(performanceHeaderView);
		}
		
		public void Update (string total, string min, string max, string avg, string lag)
		{

			performanceHeaderView.Update(total, min, max, avg, lag);
		}
	}

	

}
