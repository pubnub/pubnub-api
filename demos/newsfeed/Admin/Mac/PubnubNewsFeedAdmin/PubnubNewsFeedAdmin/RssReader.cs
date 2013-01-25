using System;
using System.Collections.Generic;
using System.Net;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Diagnostics;
using System.Collections;

namespace PubnubNewsFeedAdmin
{
	public class RssReader: IDisposable
	{
		private bool isDisposed;

		public static List<Rss.RssNews> Read (string url, Channel channel, Channel channel2)
		{
			List<Rss.RssNews> lstRssNews = new List<Rss.RssNews> ();
			XmlTextReader xmlReader = new XmlTextReader (url);
			XDocument xDoc = XDocument.Load (xmlReader);

			XPathNavigator navigator = xDoc.CreateNavigator ();

			try {
				string mainTitle = Strip (navigator.SelectSingleNode ("rss/channel/image/title").Value);
				string mainUrl = Strip (navigator.SelectSingleNode ("rss/channel/image/url").Value);
				string mainLink = Strip (navigator.SelectSingleNode ("rss/channel/image/link").Value);
				
				XPathNodeIterator items = navigator.Select ("rss/channel/item");

				/*lstRssNews = (from row in xDoc.Descendants("item")
			            select new Rss.RssNews
			            {
							Title = Strip(row.Element("title").Value),		
							Category = ((row.Element("category") == null) ? channel.ChannelName : Strip(row.Element("category").Value)),
							PublicationDate = Strip(row.Element("pubDate").Value),
							Description = Strip(row.Element("description").Value)
						}).ToList<Rss.RssNews>();*/
				while (items.MoveNext()) {	
					Rss.RssNews rssNewsItem = new Rss.RssNews ();

					XPathNavigator item = items.Current;
					string title = Strip (item.SelectSingleNode ("title").Value);
					string category = ((item.SelectSingleNode ("category") == null) ? channel.ChannelName : Strip (item.SelectSingleNode ("category").Value));
					string publicationDate = Strip (item.SelectSingleNode ("pubDate").Value);
					string description = Strip (item.SelectSingleNode ("description").Value);

					rssNewsItem.Category = category;
					rssNewsItem.Title = title;
					rssNewsItem.PublicationDate = publicationDate;
					rssNewsItem.Description = description;

					bool updated = false;
					int foundAt=-1;

					if(channel.NewsFeed != null)
					{
						for(int i=0; i<channel.NewsFeed.Count; i++)
						{
							if((channel.NewsFeed[i].Title.Equals(rssNewsItem.Title)) 
							   && (!channel.NewsFeed[i].Description.Equals(rssNewsItem.Description))
							   && (!channel.NewsFeed[i].PublicationDate.Equals(rssNewsItem.PublicationDate))
							   )
							{
								updated = true;
								foundAt =i;
								break;
							}
							else if((channel.NewsFeed[i].Title.Equals(rssNewsItem.Title)) 
							          && (channel.NewsFeed[i].Description.Equals(rssNewsItem.Description))
							          && (channel.NewsFeed[i].PublicationDate.Equals(rssNewsItem.PublicationDate))
							          )
							{
								updated = true;
								break;
							}
						}
					}
					if(!updated)
					{
						//channel.NewsFeed.Add(rssNewsItem);
						lstRssNews.Add (rssNewsItem);
					}

					//lstRssNews.Add (rssNewsItem);
				} 

				//List<Rss.RssNews> notInB = (from item in lstRssNews where (channel.NewsFeed.Find(function(x) x.property = item) = nothing) select item);
			} catch (Exception ex) {
				Console.WriteLine (ex.Message);
			}
			/*List<Rss.RssNews> differences = new List<Rss.RssNews> ();

			if (channel.NewsFeed != null) {
				differences = channel.NewsFeed.ExceptUsingJSonCompare (lstRssNews).ToList<Rss.RssNews> ();
			} else {
				differences = lstRssNews;
			}*/
			//return diff
			//add diff
			//send diff
			//check news feed list items, remove with the least pub date
			//return lstRssNews;
			return lstRssNews;
		}
		static string Strip(string text)
		{
			return Regex.Replace(text, @"<(.|\n)*?>", String.Empty);
		}

		#region IDisposable implementation

		private void Dispose(bool disposing)
		{
			if (disposing && !isDisposed)
			{
			}
			
			isDisposed = true;
		}

		public void Dispose ()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		#endregion

	}
}

