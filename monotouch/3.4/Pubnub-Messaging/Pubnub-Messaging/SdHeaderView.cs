
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
	public class SdHeaderView: UITableViewCell
	{
		UIFont font13b = UIFont.BoldSystemFontOfSize (13);

		string[] SpeedTestNames {
			get;
			set;
		}

		string[] SpeedTestSorted {
			get;
			set;
		}

		static SdHeaderView ()
		{
		}
		
		public SdHeaderView (string[] speedTestNames, string[] speedTestSorted)
		{
			BackgroundColor = UIColor.White;
			this.SpeedTestNames = speedTestNames;
			this.SpeedTestSorted = speedTestSorted;
		}


		public void Update (string[] speedTestNames, string[] speedTestSorted)
		{
			this.SpeedTestNames = speedTestNames;
			this.SpeedTestSorted = speedTestSorted;
			SetNeedsDisplay();
		}
	
		public override void Draw (RectangleF rect)
		{
			const int padright = 10;
			const int padtop = 10;
			float boxWidth = 60;
			SizeF ssize;

			this.Frame.Width = UIScreen.MainScreen.Bounds.Width;

			CGContext ctx = UIGraphics.GetCurrentContext ();

			const int offset = 5;
			float bw = Bounds.Width - offset;

			int cols = (int)(bw / boxWidth);
			int rows = (int)(SpeedTestNames.Count() / cols);
			int height = 23;
			
			UIColor.Black.SetColor ();

			int counter =0;
			int counterProg =0;
			float x=offset, y=0;
			for (int i =0; i<=rows; i++) {
				y += height;
				counterProg = counter;
				for (int j =0; j<cols; j++) {
					x=offset + j * boxWidth ;
					if(counter < SpeedTestNames.Count())
					{
						UIColor.White.SetFill ();
						ctx.SetLineWidth(1f);
						ctx.StrokeRect(new RectangleF(x-1, y, boxWidth, height));
						UIColor.FromRGB(235, 231, 213).SetFill ();
						ctx.FillRect(new RectangleF(x, y+1, boxWidth-2, height-2));
						
						UIColor.Black.SetFill ();
						DrawString ((SpeedTestSorted[counter]==null)?"":SpeedTestSorted[counter] + " MS", new PointF (x + offset, y+2), boxWidth-offset-2, font13b, UILineBreakMode.TailTruncation);
						counter++;
					}
					else
					{
						break;
					}
				}
				counter = counterProg;
				y += height;
				for (int j =0; j<cols; j++) {
					x=offset + j * boxWidth;
					
					if(counter < SpeedTestNames.Count())
					{
						UIColor.White.SetFill ();
						ctx.SetLineWidth(1f);
						ctx.StrokeRect(new RectangleF(x-1, y, boxWidth, height));
						UIColor.FromRGB(207, 197, 161).SetFill ();
						ctx.FillRect(new RectangleF(x, y+1, boxWidth-2, height-2));

						UIColor.Black.SetFill ();
						DrawString (SpeedTestNames[counter], new PointF (x+offset, y+2), boxWidth-offset, font13b, UILineBreakMode.TailTruncation);
						counter++;
					}
					else
					{
						break;
					}
				}
			}

			base.Draw (rect);
		}
	}
}
