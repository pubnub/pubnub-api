using System;
using System.Drawing;
using MonoTouch.UIKit;
using MonoTouch.Foundation;
using MonoTouch.CoreGraphics;
using MonoTouch.Dialog;

namespace PubnubNewsFeedClient
{
	internal static class LocalizationExtensions
	{
		/// <summary>
		/// Gets the localized text for the specified string.
		/// </summary>
		public static string GetText (this string text)
		{
			if (String.IsNullOrEmpty (text))
				return text;
			return NSBundle.MainBundle.LocalizedString (text, String.Empty, String.Empty);
		}
	}
	public class NewsSummaryView : UIView {
		static UIFont SenderFont = UIFont.BoldSystemFontOfSize (14);
		static UIFont SubjectFont = UIFont.SystemFontOfSize (14);
		static UIFont TextFont = UIFont.SystemFontOfSize (13);
		static UIFont CountFont = UIFont.BoldSystemFontOfSize (13);
		public string Category { get; private set; }
		public string Description { get; private set; }
		public string Title { get; private set; }
		public DateTime Date { get; private set; }
		public bool NewFlag  { get; private set; }
		public int MessageCount  { get; private set; }
		
		static CGGradient gradient;
		
		static NewsSummaryView ()
		{
			using (var colorspace = CGColorSpace.CreateDeviceRGB ()){
				gradient = new CGGradient (colorspace, new float [] { /* first */ .52f, .69f, .96f, 1, /* second */ .12f, .31f, .67f, 1 }, null); //new float [] { 0, 1 });
			}
		}


		public NewsSummaryView ()
		{
			BackgroundColor = UIColor.White;
		}
		
		public void Update (string category, string description, string title, DateTime date, bool newFlag)
		{
			Category = category;
			Description = description;
			Title = title;
			Date = date;
			NewFlag = newFlag;
			SetNeedsDisplay ();
		}
		
		public override void Draw (RectangleF rect)
		{
			const int padright = 21;
			var ctx = UIGraphics.GetCurrentContext ();
			float boxWidth=0;
			SizeF ssize;

			if (MessageCount > 0){
				var ms = MessageCount.ToString ();
				ssize = StringSize (ms, CountFont);
				boxWidth = Math.Min (22 + ssize.Width, 18);
				var crect = new RectangleF (Bounds.Width-20-boxWidth, 32, boxWidth, 16);
				
				UIColor.Gray.SetFill ();
				GraphicsUtil.FillRoundedRect (ctx, crect, 3);
				UIColor.White.SetColor ();
				crect.X += 5;
				DrawString (ms, crect, CountFont);
				
				boxWidth += padright;
			} else
				boxWidth = 0;
			
			UIColor.FromRGB (36, 112, 216).SetColor ();

			string label = Common.GetDateString(Date);

			ssize = StringSize (label, SubjectFont);
			float dateSize = ssize.Width + padright + 5;
			DrawString (label, new RectangleF (Bounds.Width-dateSize, 6, dateSize, 14), SubjectFont, UILineBreakMode.Clip, UITextAlignment.Left);
			
			const int offset = 10;
			float bw = Bounds.Width-offset;
			
			UIColor.Black.SetColor ();
			DrawString (Category, new PointF (offset, 2), bw-dateSize, SenderFont, UILineBreakMode.TailTruncation);
			DrawString (Title, new PointF (offset, 23), bw-offset-boxWidth, SubjectFont, UILineBreakMode.TailTruncation);
			
			UIColor.Gray.SetColor ();
			DrawString (Description, new RectangleF (offset, 40, bw-boxWidth, 34), TextFont, UILineBreakMode.TailTruncation, UITextAlignment.Left);
			
			if (NewFlag){
				ctx.SaveState ();
				ctx.AddEllipseInRect (new RectangleF (10, 32, 12, 12));
				ctx.Clip ();
				ctx.RestoreState ();
			}

		}
	}

	public class NewsElement : Element, IElementSizing {
		static NSString mKey = new NSString ("NewsElement");
		
		public string Category, Description, Title;
		public DateTime Date;
		public bool NewFlag;
		public int MessageCount;
		
		public class NewsCell : UITableViewCell {
			NewsSummaryView view;
			public NewsElement newsElement;

			public NewsCell () : base (UITableViewCellStyle.Default, mKey)
			{
				view = new NewsSummaryView ();
				ContentView.Add (view);
				Accessory = UITableViewCellAccessory.DisclosureIndicator;
			}
			
			public void Update (NewsElement newsElement)
			{
				this.newsElement = newsElement;
				view.Update (newsElement.Category, newsElement.Description, newsElement.Title, newsElement.Date, newsElement.NewFlag);
			}
			
			public override void LayoutSubviews ()
			{
				base.LayoutSubviews ();
				view.Frame = ContentView.Bounds;
				view.SetNeedsDisplay ();
			}
		}
		
		public NewsElement () : base ("")
		{
		}
		
		public NewsElement (Action<DialogViewController,UITableView,NSIndexPath> tapped) : base ("")
		{
			Tapped += tapped;
		}
		
		public override UITableViewCell GetCell (UITableView tv)
		{
			var cell = tv.DequeueReusableCell (mKey) as NewsCell;
			if (cell == null)
				cell = new NewsCell ();
			cell.Update (this);

			return cell;
		}
		
		public float GetHeight (UITableView tableView, NSIndexPath indexPath)
		{
			return 78;
		}
		
		public event Action<DialogViewController, UITableView, NSIndexPath> Tapped;
		
		public override void Selected (DialogViewController dvc, UITableView tableView, NSIndexPath path)
		{
			if (Tapped != null)
				Tapped (dvc, tableView, path);
		}
	}
}

