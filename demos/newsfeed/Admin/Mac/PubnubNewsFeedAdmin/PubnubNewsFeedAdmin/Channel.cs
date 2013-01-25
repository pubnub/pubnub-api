using System;
using System.Collections.Generic;

namespace PubnubNewsFeedAdmin
{
	public class Channel
	{
		public string ChannelName;
		public string ChannelUrl;
		public bool IsActive;
		public List<Rss.RssNews> NewsFeed;

		public Channel(string channelName, string channelUrl, bool isActive)
		{
			this.ChannelName = channelName;
			this.ChannelUrl = channelUrl;
			this.IsActive = isActive;
		}
	}

}

