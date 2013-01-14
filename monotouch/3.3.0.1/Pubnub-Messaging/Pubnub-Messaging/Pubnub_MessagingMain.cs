
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNubMessaging.Core;

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
			PubnubProxy proxy =  null;
			Pubnub pubnub = null;

			EntryElement entryChannelName = new EntryElement("Channel Name", "Enter Channel Name", "");
			EntryElement entryCipher = new EntryElement("Cipher", "Enter Cipher", "");

			EntryElement entryProxyServer = new EntryElement("Server", "Enter Server", "");
			EntryElement entryProxyPort = new EntryElement("Port", "Enter Port", "");

			EntryElement entryProxyUser = new EntryElement("Username", "Enter Username", "");
			EntryElement entryProxyPassword = new EntryElement("Password", "Enter Password", "", true);

			BooleanElement proxyEnabled = new BooleanElement ("Proxy", false);

			BooleanElement sslEnabled = new BooleanElement ("Enable SSL", false);
			Root = new RootElement ("Pubnub Messaging") {
				new Section ("Basic Settings")
				{
					entryChannelName,
					sslEnabled
				},
				new Section ("Enter cipher key for encryption. Leave blank for unencrypted transfer.")
				{
					entryCipher
				},
				new Section()
				{
					new RootElement ("Proxy Settings", 0, 0){
						new Section (){
							proxyEnabled
						},
						new Section ("Configuration"){
							entryProxyServer,
							entryProxyPort,
							entryProxyUser,
							entryProxyPassword
						},
					}
				},
				new Section()
				{
					new StyledStringElement ("Launch", () => {
						bool errorFree = true;
						if(String.IsNullOrWhiteSpace (entryChannelName.Value.Trim()))
						{
							errorFree = false;
							new UIAlertView ("Error!", "Please enter a channel name", null, "OK").Show (); 
						}

						if(errorFree)
						{
							pubnub = new Pubnub ("demo", "demo", "", entryCipher.Value, sslEnabled.Value);
						}

						if ((errorFree) && (proxyEnabled.Value))
						{
							int port;
							if(Int32.TryParse(entryProxyPort.Value, out port) && ((port >= 1) && (port <= 65535))) 
							{
								proxy = new PubnubProxy();
								proxy.ProxyServer = entryProxyServer.Value;
								proxy.ProxyPort = port;
								proxy.ProxyUserName = entryProxyUser.Value;
								proxy.ProxyPassword = entryProxyPassword.Value;

								try
								{
									pubnub.Proxy = proxy;
								}
								catch (MissingFieldException mse)
								{
									errorFree = false;
									proxyEnabled.Value = false;
									Console.WriteLine(mse.Message);
									new UIAlertView ("Error!", "Proxy settings invalid, please re-enter the details.", null, "OK").Show (); 
								}
							}
							else
							{
								errorFree = false;
								new UIAlertView ("Error!", "Proxy port must be a valid integer between 1 to 65535", null, "OK").Show (); 
							}
						}

						if(errorFree)
						{
							new Pubnub_MessagingSub(entryChannelName.Value, entryCipher.Value, sslEnabled.Value, pubnub);
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
