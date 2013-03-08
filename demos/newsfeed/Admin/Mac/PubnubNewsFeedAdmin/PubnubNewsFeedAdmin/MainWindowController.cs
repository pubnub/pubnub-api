using System;
using System.Linq;
using MonoMac.Foundation;
using MonoMac.AppKit;
using System.Net;
using System.Collections.Generic;

namespace PubnubNewsFeedAdmin
{
	public partial class MainWindowController : MonoMac.AppKit.NSWindowController
	{
		FeedsFetcher feedsFetcher;
		List<Channel> channelList;
		List<string> connectedUsers;

		PubNubMessagingClass pubnub;
		#region Constructors
		
		// Called when created from unmanaged code
		public MainWindowController (IntPtr handle) : base (handle)
		{
			Initialize ();
		}
		
		// Called when created directly from a XIB file
		[Export ("initWithCoder:")]
		public MainWindowController (NSCoder coder) : base (coder)
		{
			Initialize ();
		}
		
		// Call to load from the XIB/NIB file
		public MainWindowController () : base ("MainWindow")
		{
			Initialize ();
		}
		
		// Shared initialization code
		void Initialize ()
		{
			FeedsFetcher.SendNewMessages += SendNewMessagesToClientsAndRefreshList;
			FeedsFetcher.FetchComplete += FetchCompleteHandler;
			PubNubMessagingClass.MessageReceived += HandleMessageReceived;
			PubNubMessagingClass.HereNowMessageReceived += HandleHereNowMessageReceived;

			Common.FeedRefreshWaitTime = 60000;

			feedsFetcher= new FeedsFetcher();

			channelList = new List<Channel>();
			connectedUsers = new List<string>();

			Channel channel0 = new Channel("All", "https://news.google.com/news/feeds?cf=all&ned=us&hl=en&output=rss", true);
			channelList.Add(channel0);
			Channel channel1 = new Channel("Sports", "https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&topic=s&output=rss", true);
			channelList.Add(channel1);
            Channel channel2 = new Channel("Technology", "https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&topic=tc&output=rss", true);
			channelList.Add(channel2);

			
			pubnub = new PubNubMessagingClass(channel0);
			pubnub.HereNow();
			pubnub.Presence();
		}

		void HandleHereNowMessageReceived (Channel channel, List<string> connectedUsers)
		{
			//if (!string.IsNullOrWhiteSpace (message)) {
				//connectedUsers.Add(message);
			if(connectedUsers.Count>0)
			{
				InvokeOnMainThread (delegate {
					connectedUsersTableView.DataSource = new ConnectedUsersTableViewDataSource (connectedUsers);
				});
			}
		}

		partial void btnSendCustomMessageClicked (MonoMac.Foundation.NSObject sender)
		{
			if((!string.IsNullOrWhiteSpace(txtCustomMessageTitle.StringValue)) 
			   && (!string.IsNullOrWhiteSpace(txtCustomMessageDescription.StringValue)))
			{
				Rss.RssNews customNews = new Rss.RssNews();
				customNews.Category = "Custom";
				customNews.Title = txtCustomMessageTitle.StringValue;
				customNews.Description = txtCustomMessageDescription.StringValue;
				customNews.PublicationDate = DateTime.Now.ToString();

				pubnub.Publish(customNews);
			}
		}

		partial void btnSubscribeClicked (MonoMac.Foundation.NSObject sender)
		{
			if(btnSubscribe.Title.Equals("Subscribe"))
			{
				pubnub.SubscribeToFeedFromPubNubChannel();
				btnSubscribe.Title = "Unsubscribe";
			}
			else
			{
				pubnub.UnsubscribeToFeedFromPubNubChannel();
				btnSubscribe.Title = "Subscribe";
			}
		}

		void HandleMessageReceived (Channel channel, string message)
		{
			InvokeOnMainThread(delegate {
				feedDisplayTableView.DataSource = new FeedsTableViewDataSource(channel.NewsFeed);
			});
		}

		void FetchCompleteHandler ()
		{
			//ChangeStateStartFeedButton(true, "Start fetching all feeds");
		}

		void SendNewMessagesToClientsAndRefreshList (Channel channel, List<Rss.RssNews> newsFeed)
		{
			InvokeOnMainThread(delegate {
				PubNubMessagingClass pubnub = new PubNubMessagingClass(channel);
				pubnub.SendFeedToPubNubChannel(newsFeed);
			});
		}

		void ChangeStateStartFeedButton (bool enable, string title)
		{
			//btnStartFeeds.Enabled= enable;
			btnStartFeeds.Title = title;
		}

		partial void btnStartFeedsClicked (MonoMac.Foundation.NSObject sender)
		{
			if(btnStartFeeds.Title.Contains("Start"))
			{
				try
				{
					ChangeStateStartFeedButton(false, "Stop fetching all feeds");
					feedsFetcher.Fetch(channelList);
				}
				catch (WebException we)
				{
					Common.ShowAlert("Couldn't connect to the internet!");
				}
			}
			else
			{
				feedsFetcher.StopFetch();
				ChangeStateStartFeedButton(true, "Start fetching all feeds");
			}
		}

		#endregion
		
		//strongly typed window accessor
		public new MainWindow Window {
			get {
				return (MainWindow)base.Window;
			}
		}
	}
}

