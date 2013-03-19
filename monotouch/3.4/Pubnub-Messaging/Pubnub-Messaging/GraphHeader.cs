
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
	public class GraphHeader: UIViewController
	{
		GraphHeaderView graphHeaderView;
		
		public GraphHeader ()
		{
			this.View.Frame = new RectangleF (0, 2, this.View.Bounds.Width, 400);
			graphHeaderView = new GraphHeaderView();
			graphHeaderView.Frame = new RectangleF(0, 40, this.View.Bounds.Width, this.View.Bounds.Height);
			graphHeaderView.AutoresizingMask = UIViewAutoresizing.FlexibleHeight |  UIViewAutoresizing.FlexibleWidth;
			this.View.AddSubviews(graphHeaderView);
		}
		
		public void Update (int total, double min, double max, double avg, double lag)
		{
			
			graphHeaderView.Update(total, min, max, avg, lag);
		}
	}


	

}
