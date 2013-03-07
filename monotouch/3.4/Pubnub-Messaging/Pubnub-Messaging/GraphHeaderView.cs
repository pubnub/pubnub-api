
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
	class GraphHeaderView: UITableViewCell
	{
		DrawingView dv;
		int chartHeight = 210;
		int chartWidth = 210;
		
		public GraphHeaderView ()
		{
			dv = new DrawingView(new RectangleF(0,0, chartWidth, chartHeight), 0, 0, 0);
			
			this.AddSubview(dv );
		}
		
		public void Update (int total, double min, double max, double avg, double lag)
		{
			dv.Update(lag, max, min);
		}

		public override void LayoutSubviews ()
		{
			dv.Frame = new RectangleF((Bounds.Width - chartWidth)/2, 10, chartWidth, chartHeight);
		}
	}
	
	public class DrawingView : UIView
	{
		UIFont font10 = UIFont.SystemFontOfSize (10);
		UIFont font18b = UIFont.BoldSystemFontOfSize (18);
		
		double lag;
		
		double max;

		double min;
		
		public DrawingView (RectangleF p, double lag, double max, double min) : base(p)
		{
			BackgroundColor = UIColor.White;
			this.lag = lag;
			this.max = max;
			this.min = min;
		}
		
		public void Update (double lag, double max, double min)
		{
			this.min = min;
			this.lag =  lag;
			this.max = max;
			SetNeedsDisplay();
		}

		private PointF GetCenterPoint(PointF p1, PointF p2)
		{
			return new PointF((p2.X + p1.X) / 2, (p2.Y + p1.Y) / 2);
		}
		
		private double GetSlope(PointF p1, PointF p2)
		{
			if ((p2.Y - p1.Y) != 0)
				return (p1.X - p2.X) / (p2.Y - p1.Y);
			else return double.PositiveInfinity;
		}
		
		private double GetIntersect(PointF p1, PointF p2)
		{
			double slope = GetSlope(p1, p2);
			PointF center = GetCenterPoint(p1, p2);
			if (double.IsPositiveInfinity(slope))
				return 0;
			return center.Y - (slope * center.X);
		}

		public override void Draw (RectangleF rect)
		{
			float x = 105;
			float y = 105;
			float r = 100;
			float twopi = (2f * (float)Math.PI) * -1f;
			
			CGContext ctx = UIGraphics.GetCurrentContext ();
			
			//base circle
			UIColor.FromRGB (137, 136, 133).SetColor ();
			ctx.AddArc (x, y, r + 3, 0, twopi, true);
			ctx.FillPath ();
			
			//border circle
			UIColor.FromRGB (231, 231, 231).SetColor ();
			ctx.AddArc (x, y, r, 0, twopi, true);
			ctx.FillPath ();

			//Center circle
			UIColor.White.SetColor ();
			ctx.AddArc (x, y, r / 1.2f, 0, twopi, true);
			ctx.FillPath ();

			UIColor.Black.SetFill ();
			//Slow
			SizeF stringSize = StringSize ("Fast", font10);
			DrawString ("Fast", new PointF (105 - r + 7, 105 + r / 2 - 28), stringSize.Width, font10, UILineBreakMode.TailTruncation);
			
			//fast
			stringSize = StringSize ("Slow", font10);
			DrawString ("Slow", new PointF (105 + r - 25, 105 - r / 2 + 20), stringSize.Width, font10, UILineBreakMode.TailTruncation);

			//pubnub
			UIColor.Red.SetFill ();
			stringSize = StringSize ("PubNub", font18b);
			DrawString ("PubNub", new PointF ((r * 2 - stringSize.Width) / 2 + 5, y - r / 2f), stringSize.Width, font18b, UILineBreakMode.TailTruncation);


			//needle
			//double percentFromMaxValue = max / 100.0d;
			max =1000;
			double percentFromMaxValue = max / 100.0d;

			if (lag > max) {
				lag = max;
			}

			//angle
			double invertLag = ((max - min)/2 - lag) *2 + lag;
			//Debug.WriteLine("lag: "+ lag.ToString() + " invlag:" + invLag.ToString());
			double angle = 360 - Math.Round((double)invertLag / percentFromMaxValue* (90 / 100.0f)) * Math.PI / 180.0;
			//double angle2  = 360 - Math.Round((double)lag / percentFromMaxValue* (90 / 100.0f)) * Math.PI / 180.0;;
			//Debug.WriteLine("lagangle: "+ angle.ToString() + " invLagangle" + angle2.ToString());
			//double angle = WrapValue(lag, max);
			
			float distance = 80;
			PointF p =  new PointF(distance * (float)Math.Cos(angle), distance * (float)Math.Sin(angle));
			
			UIColor.Brown.SetStroke ();
			CGPath path1 = new CGPath ();
			ctx.SetLineWidth(3);
			
			PointF newPoint = new PointF (105 - p.X, 105 - p.Y);
			
			PointF[] linePoints = new PointF[] { 
				newPoint,
				new PointF (105, 105) };
			
			path1.AddLines (linePoints);
			path1.CloseSubpath ();
			
			ctx.AddPath (path1);
			ctx.DrawPath (CGPathDrawingMode.FillStroke);

			//caliberate
			UIColor.Brown.SetColor ();
			double theta = 0.0;
			for (int i = 0; i < 360; i++)
				
			{
				float bx4= (float)(x - 4 + (r -10) * (Math.Cos(theta * Math.PI / 180)));
				float by4= (float)(y - 15 + (r - 10) * (Math.Sin(theta * Math.PI / 180)));

				if((theta > 160) && (theta <350))
				{
					UIColor.Black.SetColor ();
					DrawString (".", new PointF (bx4,by4), StringSize(".", font18b).Width, font18b, UILineBreakMode.TailTruncation);
				}
				else if (((theta >= 0) && (theta <40)) || ((theta >= 350) && (theta <= 360)))
				{
					//redline
					UIColor.Red.SetColor ();
					DrawString (".", new PointF (bx4,by4), StringSize(".", font18b).Width, font18b, UILineBreakMode.TailTruncation);
				}
				theta += 10.0;

			}

			//small circle
			UIColor.FromRGB (220, 214, 194).SetColor ();
			//ctx.AddArc (x, y+y*.33f, r/1.5f, 0, twopi, true );
			ctx.AddArc (x, y + r / 2f, r / 2f, 0, twopi, true);
			ctx.FillPath ();
			
			//speed in small circle
			UIColor.Black.SetFill ();
			stringSize = StringSize (Convert.ToInt32(lag).ToString(), font18b);
			DrawString (Convert.ToInt32(lag).ToString(), new PointF ((r * 2 - stringSize.Width) / 2 + 4, y + r / 2f - 15), stringSize.Width, font18b, UILineBreakMode.TailTruncation);

			//ms
			UIColor.Black.SetFill ();
			stringSize = StringSize ("MS", font18b);
			DrawString ("MS", new PointF ((r - stringSize.Width) / 2 + 55, y + r / 2f + 10), stringSize.Width, font18b, UILineBreakMode.TailTruncation);
		}
	}
}

