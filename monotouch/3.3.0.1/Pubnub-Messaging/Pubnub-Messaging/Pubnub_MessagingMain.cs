
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;

namespace PubnubMessaging
{
	public partial class Pubnub_MessagingMain : DialogViewController
	{
		public override void ViewDidAppear (bool animated)
		{
			AppDelegate.navigation.ToolbarHidden = true;
			base.ViewDidAppear (animated);
		}

		public Pubnub_MessagingMain () : base (UITableViewStyle.Grouped, null)
		{
			EntryElement entryChannelName = new EntryElement("Channel Name", "Enter Channel Name", "");
			EntryElement entryCipher = new EntryElement("Cipher", "Enter Cipher", "");
			BooleanElement bSsl = new BooleanElement ("Enable SSL", false);
			Root = new RootElement ("Pubnub Messaging") {
				new Section ("Basic Settings")
				{
					entryChannelName,
					bSsl
				},
				new Section ("Enter cipher key for encryption. Leave blank for unencrypted transfer.")
				{
					entryCipher
				},
				new Section()
				{
					new StyledStringElement ("Launch", () => {
						if(String.IsNullOrWhiteSpace (entryChannelName.Value.Trim()))
						{
							new UIAlertView ("Error!", "Please enter a channel name", null, "OK").Show (); 
						}
						else
						{
							new Pubnub_MessagingSub(entryChannelName.Value, entryCipher.Value, bSsl.Value);
						}
					})
					{
						BackgroundColor = UIColor.Blue,
						TextColor = UIColor.White,
						Alignment = UITextAlignment.Center
					},
				}
			};
		}
	}
}
