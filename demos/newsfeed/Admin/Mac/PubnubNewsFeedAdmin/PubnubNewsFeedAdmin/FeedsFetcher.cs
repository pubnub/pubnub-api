using System;
using System.Threading;
using System.Collections.Generic;
using System.Diagnostics;

namespace PubnubNewsFeedAdmin
{
	public class FeedsFetcher
	{
		public static event SendNewMessagesHandler SendNewMessages;
		public delegate void SendNewMessagesHandler(Channel channel, List<Rss.RssNews> newsFeed);

		public static event FetchCompleteHandler FetchComplete;
		public delegate void FetchCompleteHandler();

		Thread feedFetchThread;

		bool fetchFeeds;

		public List<Channel> ChannelList
		{
			get;set;
		}

		public void Fetch (List<Channel> channelList)
		{
			this.ChannelList = channelList;
			feedFetchThread = new Thread(new ParameterizedThreadStart(LoadFeedDelegate));
			feedFetchThread.Name = "Feed fetcher thread";
			fetchFeeds = true;
			feedFetchThread.Start();
		}

		public void StopFetch ()
		{
			fetchFeeds = false;
			if ((feedFetchThread != null) && (feedFetchThread.IsAlive)) {
				feedFetchThread.Join (1000);
			}
		}

		void LoadFeedDelegate (object objState)
		{
			while (fetchFeeds) {
				foreach (var channel in ChannelList) {
					ParseFeed (channel);
				}
				Thread.Sleep(Common.FeedRefreshWaitTime);
				FetchComplete();
			}
		}

		void ParseFeed (Channel channel)
		{
			if (channel.IsActive) {
				try
				{
					List<Rss.RssNews> newRssNews = RssReader.Read (channel.ChannelUrl, channel, ChannelList[1]);
					if(newRssNews.Count >0)
					{
						if (channel.NewsFeed != null) 
						{
							if(channel.NewsFeed.Count >30)
							{
								channel.NewsFeed.RemoveRange(0, channel.NewsFeed.Count - 30 - newRssNews.Count);
							}
							channel.NewsFeed.AddRange(newRssNews);
						}
						else
						{
							channel.NewsFeed = newRssNews;
						}

						SendNewMessages(channel, newRssNews);
					}
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.Message);
				}
			}
		}
	}
}

