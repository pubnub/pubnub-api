using System;
using MonoMac.AppKit;
using MonoMac.Foundation;
using System.Collections.Generic;

namespace PubnubNewsFeedAdmin
{
	[Register ("FeedsTableViewDataSource")]
	public class FeedsTableViewDataSource : NSTableViewDataSource
	{
		List<Rss.RssNews> NewsFeed {
			get;
			set;
		}

		public FeedsTableViewDataSource (List<Rss.RssNews> newsFeed)
		{
			this.NewsFeed = newsFeed;
		}
		
		[Export ("numberOfRowsInTableView:")]
		public int NumberOfRowsInTableView(NSTableView table)
		{
			return NewsFeed.Count;
		}
		
		[Export ("tableView:objectValueForTableColumn:row:")]
		public NSObject ObjectValueForTableColumn(NSTableView table, NSTableColumn col, int row)
		{
			return new NSString(NewsFeed[row].Title);
		}
	}//class
}

