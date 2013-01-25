using System;
using MonoMac.AppKit;

namespace PubnubNewsFeedAdmin
{
	public class Common
	{
		public static int FeedRefreshWaitTime {
			get;
			set;
		}

		public static void ShowAlert (string message)
		{
			NSAlert nsalert = new NSAlert();
			nsalert.MessageText = message;
			nsalert.RunModal();
		}
	}
}

