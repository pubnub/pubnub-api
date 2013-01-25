
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNubMessaging.Core;
using System.Threading;
using PubnubNewsFeedAdmin;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Text;
using System.Drawing;

namespace PubnubNewsFeedClient
{
	public partial class NewsFeedMain : DialogViewController
	{
		Section secOutput;
		Pubnub pubnub = null;
		RootElement root;

		string Channel {
			get;set;
		}

		public NewsFeedMain () : base (UITableViewStyle.Plain, null)
		{
			Channel = "NewsFeed:All";
			pubnub = new Pubnub ("demo", "demo", "", "", false);

			NewsElement newsElement = new NewsElement (msgSelected)
			{
				Category = "",
				Description = "",
				Title = ""
				//Font = font12
			};

			secOutput = new Section("Pubnub News feed")
			{
				newsElement
			};


			Root = new RootElement ("Pubnub News Feed Client") {
				/*new Section()
				{
					HeaderView = CreateHeaderView(50)
				},*/
				secOutput
			};
			secOutput.Remove(0);

			NSTimer.CreateScheduledTimer (5, delegate {
				DetailedHistory();
				Subscribe();
			});
		}

		UIView CreateHeaderView (int iViewHeight)
		{
			UIView uiView = new UIView (new RectangleF (0, 0, this.View.Bounds.Width, iViewHeight));
			uiView.MultipleTouchEnabled = true;
			
			//subscribe
			GlassButton gbSubs = new GlassButton (new RectangleF (10, 10, 150, 30));
			gbSubs.Font = UIFont.SystemFontOfSize (13);
			gbSubs.SetTitle ("Subscribe to news", UIControlState.Normal);
			gbSubs.Enabled = true;
			gbSubs.Tapped += delegate{Subscribe();};
			uiView.AddSubview (gbSubs);

			return uiView;
		}

		public void DetailedHistory()
		{
			pubnub.DetailedHistory(Channel, 30, DisplayReturnMessageHistory);
		}

		public void Subscribe()
		{
			pubnub.Subscribe(Channel, DisplayReturnMessage);
		}
		
		void DisplayReturnMessageHistory (object result)
		{
			Rss.RssNews rssNews;
			if (result != null) {
				IList<object> fields = result as IList<object>;

				var myObjectArray = (from item in fields select item as object).ToArray ();
				IList<object> enumerable = myObjectArray [0] as IList<object>;
				if ((enumerable != null) && (enumerable.Count > 0)) {
					foreach (object element in enumerable) {
						rssNews = JsonConvert.DeserializeObject<Rss.RssNews> (element.ToString ());
						Display (rssNews);
					}
				}
			}
		}

		void DisplayReturnMessage (object result)
		{
			Rss.RssNews rssNews;
			if (result != null) {
				IList<object> fields = result as IList<object>;
				if (fields [0] != null) {
					try{
						rssNews = JsonConvert.DeserializeObject<Rss.RssNews>(fields[0].ToString());
						
						Display (rssNews);
					}catch(Exception ex)
					{
						Debug.WriteLine(ex.ToString());
					}
					/*lstRssNews = (from item in fields
			            select new Rss.RssNews
			            {
							Title = Strip(row.Element("title").Value),		
							Category = ((row.Element("category") == null) ? channel.ChannelName : Strip(row.Element("category").Value)),
							PublicationDate = Strip(row.Element("pubDate").Value),
							Description = Strip(row.Element("description").Value)
						}).ToList<Rss.RssNews>();*/
				}
			}

		}

		public void Display (Rss.RssNews news)
		{
			DateTime date;
			if (!DateTime.TryParse (news.PublicationDate, out date)) {
				date = DateTime.MinValue;
			}
			NewsElement newsElement = new NewsElement (msgSelected)
			{
				Category = news.Category,
				Description = news.Description,
				Date = date,
				Title = news.Title
				//Font = font12
			};

			ThreadPool.QueueUserWorkItem (delegate {
				
				AppDelegate.navigation.BeginInvokeOnMainThread(delegate {
					//this.Animating = false;
					if(secOutput.Count > 30)
					{
						secOutput.RemoveRange(0, secOutput.Count - 30);
					}
					if (secOutput.Count > 0) {
						secOutput.Insert (secOutput.Count, newsElement);					}
					else
					{
						secOutput.Add (newsElement);
					}
					this.TableView.ReloadData();
					//var lastIndexPath = this.root.Last()[this.root.Last().Count-1].IndexPath;
					//this.TableView.ScrollToRow(lastIndexPath, UITableViewScrollPosition.Middle, true);	
				});
			});
		}

		void msgSelected (DialogViewController dvc, UITableView tv, NSIndexPath path)
		{
			NewsElement.NewsCell newsCell = (NewsElement.NewsCell)tv.CellAt(path);

			StringBuilder sb = new StringBuilder();
			sb.Append("Category: ");
			sb.Append(newsCell.newsElement.Category);
			sb.Append("\n\n");
			
			sb.Append("Date: ");
			sb.Append(Common.GetDateString(newsCell.newsElement.Date));
			sb.Append("\n\n");
			
			sb.Append("Title: ");
			sb.Append(newsCell.newsElement.Title);
			sb.Append("\n\n");

			sb.Append("Description: ");
			sb.Append(newsCell.newsElement.Description);
			sb.Append("\n\n");

			var np = new DialogViewController (new RootElement ("News Details") {
				new Section () {
					new StyledMultilineElement (sb.ToString())
				}
			}, true);
			dvc.ActivateController (np);
		}
	}
}
