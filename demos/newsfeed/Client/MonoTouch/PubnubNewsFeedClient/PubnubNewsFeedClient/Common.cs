using System;

namespace PubnubNewsFeedClient
{
	public class Common
	{
		public static string GetDateString (DateTime date)
		{
			string label;
			var diff = DateTime.Now - date;

			if (DateTime.Now.Day == date.Day)
				label = "Today: " + date.ToShortTimeString ();
			else if (diff <= TimeSpan.FromHours (24))
				label = "Yesterday".GetText ();
			else if (diff < TimeSpan.FromDays (6))
				label = date.ToString ("dddd");
			else
				label = date.ToShortDateString ();

			return label;
		}

	}
}

