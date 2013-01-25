using System;
using System.Collections;
using System.Collections.Generic;

namespace PubnubNewsFeedAdmin
{
	public class Rss: IComparer
	{
		[Serializable]
		public struct RssNews
		{
			public string Title;
			public string PublicationDate;
			public string Description;
			public string Category;
		}
		
		
		#region IComparer implementation
		public int Compare (object x, object y)
		{
			return 1;
		}
#endregion
	}
}

