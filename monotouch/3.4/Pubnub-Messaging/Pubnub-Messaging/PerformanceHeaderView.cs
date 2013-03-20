
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
	class PerformanceHeaderView: UITableViewCell
	{
		UIFont font13b = UIFont.BoldSystemFontOfSize (13);
		UILabel labelTotal;
		UILabel labelMinMax;
		UILabel labelAvgCurr;

		float height = 15;
 
		public PerformanceHeaderView ()
		{
			BackgroundColor = UIColor.White;

			labelTotal = new UILabel();
			labelTotal.TextColor = UIColor.Brown;
			labelTotal.Font = font13b;

			this.AddSubview(labelTotal);

			labelMinMax = new UILabel();
			labelMinMax.TextColor = UIColor.Brown;
			labelMinMax.Font = font13b;

			this.AddSubview(labelMinMax);

			labelAvgCurr = new UILabel();
			labelAvgCurr.TextColor = UIColor.Brown;
			labelAvgCurr.Font = font13b;

			this.AddSubview(labelAvgCurr);
		}

		public void Update (string total, string min, string max, string avg, string lag)
		{
			labelTotal.Text = string.Format("Total Messages Sent: {0}", total);
			labelMinMax.Text = string.Format("Min: {0} MS, Max: {1} MS", min, max);
			labelAvgCurr.Text = string.Format("Avg: {0} MS, Current: {1} MS", avg, lag);
		}

		public override void LayoutSubviews ()
		{
			labelTotal.Frame = new RectangleF(10, 3, Bounds.Width - 10, height);
			labelMinMax.Frame = new RectangleF(10, labelTotal.Frame.Top + labelTotal.Frame.Height+ 3, Bounds.Width - 10, height);
			labelAvgCurr.Frame = new RectangleF(10, labelMinMax.Frame.Top + labelMinMax.Frame.Height+ 3, Bounds.Width -10, height);
		}
	}
}
