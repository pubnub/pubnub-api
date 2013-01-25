// WARNING
//
// This file has been generated automatically by MonoDevelop to store outlets and
// actions made in the Xcode designer. If it is removed, they will be lost.
// Manual changes to this file may not be handled correctly.
//
using MonoMac.Foundation;

namespace PubnubNewsFeedAdmin
{
	[Register ("MainWindowController")]
	partial class MainWindowController
	{
		[Outlet]
		MonoMac.AppKit.NSButton btnSubscribe { get; set; }

		[Outlet]
		MonoMac.AppKit.NSButton btnStartFeeds { get; set; }

		[Outlet]
		MonoMac.AppKit.NSTableView feedDisplayTableView { get; set; }

		[Outlet]
		MonoMac.AppKit.NSButton btnSendCustomMessage { get; set; }

		[Outlet]
		MonoMac.AppKit.NSTextField txtCustomMessageDescription { get; set; }

		[Outlet]
		MonoMac.AppKit.NSTextFieldCell txtCustomMessageTitle { get; set; }

		[Outlet]
		MonoMac.AppKit.NSTableView connectedUsersTableView { get; set; }

		[Action ("btnSendCustomMessageClicked:")]
		partial void btnSendCustomMessageClicked (MonoMac.Foundation.NSObject sender);

		[Action ("btnSubscribeClicked:")]
		partial void btnSubscribeClicked (MonoMac.Foundation.NSObject sender);

		[Action ("btnStartFeedsClicked:")]
		partial void btnStartFeedsClicked (MonoMac.Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (btnSubscribe != null) {
				btnSubscribe.Dispose ();
				btnSubscribe = null;
			}

			if (btnStartFeeds != null) {
				btnStartFeeds.Dispose ();
				btnStartFeeds = null;
			}

			if (feedDisplayTableView != null) {
				feedDisplayTableView.Dispose ();
				feedDisplayTableView = null;
			}

			if (btnSendCustomMessage != null) {
				btnSendCustomMessage.Dispose ();
				btnSendCustomMessage = null;
			}

			if (txtCustomMessageDescription != null) {
				txtCustomMessageDescription.Dispose ();
				txtCustomMessageDescription = null;
			}

			if (txtCustomMessageTitle != null) {
				txtCustomMessageTitle.Dispose ();
				txtCustomMessageTitle = null;
			}

			if (connectedUsersTableView != null) {
				connectedUsersTableView.Dispose ();
				connectedUsersTableView = null;
			}
		}
	}

	[Register ("MainWindow")]
	partial class MainWindow
	{
		
		void ReleaseDesignerOutlets ()
		{
		}
	}
}
