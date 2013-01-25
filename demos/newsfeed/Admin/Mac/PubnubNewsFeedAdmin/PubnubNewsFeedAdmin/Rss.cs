using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

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
	
	
	public class JSonEqualityComparer<T> : IEqualityComparer<T>
	{   
		public bool Equals(T x, T y)
		{           
			return String.Equals
				( 
				 Newtonsoft.Json.JsonConvert.SerializeObject(x), 
				 Newtonsoft.Json.JsonConvert.SerializeObject(y)
				 );                  
		}
		
		public int GetHashCode(T obj)
		{                           
			return Newtonsoft.Json.JsonConvert.SerializeObject(obj).GetHashCode();          
		}               
	}       
	
	
	public static partial class LinqExtensions
	{
		public static IEnumerable<T> ExceptUsingJSonCompare<T>
			(this IEnumerable<T> first, IEnumerable<T> second)
		{   
			return first.Except(second, new JSonEqualityComparer<T>());
		}
	}
}

