using System;
using PubNubMessaging.Core;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace PubnubNewsFeedAdmin
{
	public class PubNubMessagingClass
	{
		public static event MessageReceivedHandler MessageReceived;
		public delegate void MessageReceivedHandler(Channel channel, string message);

		public static event HereNowMessageReceivedHandler HereNowMessageReceived;
		public delegate void HereNowMessageReceivedHandler(Channel channel, List<string> connectedUsers);

		Channel channel;
		Pubnub pubnub;

		public PubNubMessagingClass (Channel channel)
		{
			this.channel = channel;
			channel.ChannelName = "NewsFeed:All";
			pubnub = new Pubnub ("demo", "demo", "", "", false);
		}
		
		public void SendFeedToPubNubChannel (List<Rss.RssNews> newsFeed)
		{
			foreach (var news in newsFeed) {
				//"NewsFeed:" + channel.ChannelName
				pubnub.Publish<string>(channel.ChannelName, news, DisplayReturnMessage);
			}
		}
		
		void DisplayReturnMessage(string result)
		{
			Console.WriteLine(result);
		}
		void DisplayReturnMessage(object result)
		{
			Console.WriteLine(result.ToString());
		}

		public void Publish (Rss.RssNews customNews)
		{
			if (channel.NewsFeed == null) {
				channel.NewsFeed = new List<Rss.RssNews>();
			}
			channel.NewsFeed.Add (customNews);

			pubnub.Publish(channel.ChannelName, customNews, DisplayReturnMessage);
		}

		public void SubscribeToFeedFromPubNubChannel ()
		{
			pubnub.Subscribe(channel.ChannelName, SubscribeHandler);
		}

		public void UnsubscribeToFeedFromPubNubChannel ()
		{
			pubnub.Unsubscribe(channel.ChannelName, DisplayReturnMessage);
		}

		public void HereNow ()
		{
			pubnub.HereNow(channel.ChannelName, HereNowHandler);
		}

		public void Presence ()
		{
			pubnub.Presence(channel.ChannelName, PresenceHandler);
		}

		void HereNowHandler (object result)
		{
			IList<object> responseFields = result as IList<object>;
			if ((responseFields [0] != null) && (responseFields [0].ToString() != "0"))
			{
				Dictionary<string, object> message = (Dictionary<string, object>)responseFields [0];
				if(message["uuids"]!=null)
				{
					List<string> connectedUsers = new List<string>();
					string[] uuids = JsonConvert.DeserializeObject<string[]>(message["uuids"].ToString());
					foreach (string uuid in uuids)
					{
						connectedUsers.Add(uuid);
					}
					HereNowMessageReceived (channel, connectedUsers);
				}
			}
		}

		void PresenceHandler (object result)
		{
			HereNow();
		}

		void SubscribeHandler(object result)
		{
			/*Rss.RssNews rssNews;
			if (result != null) {
				IList<object> fields = result as IList<object>;
				if (fields [0] != null) {
					try{
						rssNews = JsonConvert.DeserializeObject<Rss.RssNews>(fields[0].ToString());
						
					}catch(Exception ex)
					{
						Debug.WriteLine(ex.ToString());
					}
				}
			}*/
			MessageReceived(channel, result.ToString());
		}
	}
}

