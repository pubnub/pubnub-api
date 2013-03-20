
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNubMessaging.Core;
using System.Drawing;

namespace PubnubMessaging
{
	public partial class Pubnub_MessagingMain : DialogViewController
	{
		PubnubProxy proxy =  null;
		Pubnub pubnub = null;

		public override void ViewDidAppear (bool animated)
		{
			AppDelegate.navigation.ToolbarHidden = true;
			base.ViewDidAppear (animated);
		}

		public Pubnub_MessagingMain () : base (UITableViewStyle.Grouped, null)
		{
            UIView labelView = new UIView(new RectangleF (0, 0, this.View.Bounds.Width, 24));
            int left = 20;
            string hardwareVer = DeviceHardware.Version.ToString ().ToLower ();
            if (hardwareVer.IndexOf ("ipad") >= 0) {
                left = 55;
            }

            labelView.AddSubview(new UILabel (new RectangleF (left, 10, this.View.Bounds.Width - left, 24)){
                Font = UIFont.BoldSystemFontOfSize(16),
                BackgroundColor = UIColor.Clear,
                TextColor = UIColor.FromRGB(76, 86, 108),
                Text = "Basic Settings"
            });

            var headerMultipleChannels = new UILabel (new RectangleF (0, 0, this.View.Bounds.Width, 24)){
                Font = UIFont.SystemFontOfSize(12),
                TextColor = UIColor.Brown,
                BackgroundColor = UIColor.Clear,
                TextAlignment = UITextAlignment.Center
            };
            headerMultipleChannels.Text = "Enter multiple channel names separated by comma";

			EntryElement entryChannelName = new EntryElement("Channel(s)", "Enter Channel Name", "");
			entryChannelName.AutocapitalizationType = UITextAutocapitalizationType.None;
			entryChannelName.AutocorrectionType = UITextAutocorrectionType.No;

			EntryElement entryCipher = new EntryElement("Cipher", "Enter Cipher", "");
			entryCipher.AutocapitalizationType = UITextAutocapitalizationType.None;
			entryCipher.AutocorrectionType = UITextAutocorrectionType.No;

			EntryElement entryProxyServer = new EntryElement("Server", "Enter Server", "");
			entryProxyServer.AutocapitalizationType = UITextAutocapitalizationType.None;
			entryProxyServer.AutocorrectionType = UITextAutocorrectionType.No;

			EntryElement entryProxyPort = new EntryElement("Port", "Enter Port", "");

			EntryElement entryProxyUser = new EntryElement("Username", "Enter Username", "");
			entryProxyUser.AutocapitalizationType = UITextAutocapitalizationType.None;
			entryProxyUser.AutocorrectionType = UITextAutocorrectionType.No;

			EntryElement entryProxyPassword = new EntryElement("Password", "Enter Password", "", true);

			EntryElement entryCustonUuid = new EntryElement("CustomUuid", "Enter Custom UUID", "");
			entryCustonUuid.AutocapitalizationType = UITextAutocapitalizationType.None;
			entryCustonUuid.AutocorrectionType = UITextAutocorrectionType.No;

			BooleanElement proxyEnabled = new BooleanElement ("Proxy", false);

			BooleanElement sslEnabled = new BooleanElement ("Enable SSL", false);
			Root = new RootElement ("Pubnub Messaging") {
                new Section(labelView)
                {
                },
                new Section(headerMultipleChannels)
                {
                },
				new Section ()
				{
					entryChannelName,
					sslEnabled
				},
				new Section ("Enter cipher key for encryption. Leave blank for unencrypted transfer.")
				{
					entryCipher
				},
				new Section ("Enter custom UUID or leave blank to use the default UUID")
				{
					entryCustonUuid
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
					new StyledStringElement ("Launch Example", () => {
						bool errorFree = true;
						errorFree = ValidateAndInitPubnub(entryChannelName.Value, entryCipher.Value, sslEnabled.Value, 
						                                  entryCustonUuid.Value, proxyEnabled.Value, entryProxyPort.Value,
						                                  entryProxyUser.Value, entryProxyServer.Value, entryProxyPassword.Value
						                                  );

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
				},
				/*new Section()
				{
					new StyledStringElement ("Launch Speed Test", () => {
						bool errorFree = true;
						errorFree = ValidateAndInitPubnub(entryChannelName.Value, entryCipher.Value, sslEnabled.Value, 
						                                  entryCustonUuid.Value, proxyEnabled.Value, entryProxyPort.Value,
						                                  entryProxyUser.Value, entryProxyServer.Value, entryProxyPassword.Value
						                                  );
						
						if(errorFree)
						{
							new Pubnub_MessagingSpeedTest(entryChannelName.Value, entryCipher.Value, sslEnabled.Value, pubnub);
						}
					})
					{
						BackgroundColor = UIColor.Blue,
						TextColor = UIColor.White,
						Alignment = UITextAlignment.Center
					},
				}*/
			};
		}

		bool ValidateAndInitPubnub (string channelName, string cipher, bool ssl, 
		                            string customUuid, bool proxyEnabled, string proxyPort,
		                            string proxyUser, string proxyServer, string proxyPass
		                            )
		{
			bool errorFree = true;
			if(String.IsNullOrWhiteSpace (channelName))
			{
				errorFree = false;
				new UIAlertView ("Error!", "Please enter a channel name", null, "OK").Show (); 
			}
			
			if(errorFree)
			{
				pubnub = new Pubnub ("demo", "demo", "", cipher, ssl);
				if(!String.IsNullOrWhiteSpace (customUuid.Trim()))
				{
					pubnub.SessionUUID = customUuid.Trim();
				}
			}
			
			if ((errorFree) && (proxyEnabled))
			{
				int port;
				if(Int32.TryParse(proxyPort, out port) && ((port >= 1) && (port <= 65535))) 
				{
					proxy = new PubnubProxy();
					proxy.ProxyServer = proxyServer;
					proxy.ProxyPort = port;
					proxy.ProxyUserName = proxyUser;
					proxy.ProxyPassword = proxyPass;
					
					try
					{
						pubnub.Proxy = proxy;
					}
					catch (MissingFieldException mse)
					{
						errorFree = false;
						proxyEnabled = false;
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
			return errorFree;
		}
	}
}
