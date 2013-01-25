using System;
using MonoMac.Foundation;
using MonoMac.AppKit;
using System.Collections.Generic;

namespace PubnubNewsFeedAdmin
{
	[Register ("ConnectedUsersTableViewDataSource")]
	public class ConnectedUsersTableViewDataSource : NSTableViewDataSource
	{
		List<string> connectedUsers;

		public ConnectedUsersTableViewDataSource (List<string> connectedUsers)
		{
			this.connectedUsers = connectedUsers;
		}

		[Export ("numberOfRowsInTableView:")]
		public int NumberOfRowsInTableView(NSTableView table)
		{
			return connectedUsers.Count;
		}
		
		[Export ("tableView:objectValueForTableColumn:row:")]
		public NSObject ObjectValueForTableColumn(NSTableView table, NSTableColumn col, int row)
		{
			return new NSString(connectedUsers[row]);
		}
	}//class
}

