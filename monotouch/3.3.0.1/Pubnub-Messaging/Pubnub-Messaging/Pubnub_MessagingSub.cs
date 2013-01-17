using System;
using System.Collections.Generic;
using System.Linq;
using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using System.Threading;
using System.Drawing;
using MonoTouch.ObjCRuntime;
using PubNubMessaging.Core;

namespace PubnubMessaging
{
	public partial class Pubnub_MessagingSub : DialogViewController
	{
		Pubnub pubnub;
		string Channel {
			get;set;
		}

		string Cipher {
			get;set;
		}

		bool Ssl {
			get;set;
		}

		DialogViewController dvc;
		RootElement root;
		Section secOutput;
		UIFont font12 = UIFont.SystemFontOfSize (12);
		UIFont font13 = UIFont.SystemFontOfSize (13);

		public Pubnub_MessagingSub (string channelName, string cipher, bool enableSSL, Pubnub pubnub) 
			: base (UITableViewStyle.Grouped, null)
		{
			Channel = channelName;
			Ssl = enableSSL;
			Cipher = cipher;
			this.pubnub = pubnub;

			string strSsl = "";
			if (Ssl) {
				strSsl = ", SSL";
			}
			
			string strCip = "";
			if (!String.IsNullOrWhiteSpace (Cipher)) {
				strCip = ", Cipher";
			}
			
			string head = String.Format ("Ch: {0} {1} {2}", Channel, strSsl, strCip);

			//pubnub = new Pubnub ("demo", "demo", "", Cipher, Ssl);
			
			Section secAction = new Section ();
			
			bool bIphone = true;
			
			string hardwareVer = DeviceHardware.Version.ToString ().ToLower ();
			if (hardwareVer.IndexOf ("ipad") >= 0) {
				bIphone = false;
			}
			
			Dictionary<string, RectangleF> dictRect = null;
			int viewHeight = 140;
			
			if (bIphone) {
				dictRect = GetRectanglesForIphone();
				viewHeight = 140;
			} else {
				dictRect = GetRectanglesForIpad();
				viewHeight = 85;
			}
			
			secAction.HeaderView = CreateHeaderView(dictRect, viewHeight);
			
			secOutput = new Section("Output");
			
			root = new RootElement (head) {
				secAction,
				secOutput
			};
			Root = root;
			dvc = new DialogViewController (root, true);
			dvc.NavigationItem.RightBarButtonItem = new UIBarButtonItem(UIBarButtonSystemItem.Cancel, delegate {
				pubnub.EndPendingRequests ();
				AppDelegate.navigation.PopToRootViewController(true);
			});
			AppDelegate.navigation.PushViewController (dvc, true);
		}

		Dictionary<string, RectangleF> GetRectanglesForIphone ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int buttonHeight = 30;
			int spacingX = 5;

			int row1Y = 10;
			int row2Y = row1Y + buttonHeight + 5;
			int row3Y = row2Y + buttonHeight + 5;
			int row4Y = row3Y + buttonHeight + 5;

			//row1
			int subsX = spacingX;
			int subsWidth = 100;
			dicRect.Add("subscribe", new RectangleF (subsX, row1Y, subsWidth, buttonHeight));

			int subsCX = subsX + subsWidth + spacingX;
			int subsCWidth = 205;
			dicRect.Add("subscribeconncallback", new RectangleF (subsCX, row1Y, subsCWidth, buttonHeight));

			//row2
			int pubX = spacingX;
			int pubWidth = 100;
			dicRect.Add("publish", new RectangleF (pubX, row2Y, pubWidth, buttonHeight));

			int presX = pubX + pubWidth + spacingX;
			int presWidth = 105;
			dicRect.Add("presence", new RectangleF (presX, row2Y, presWidth, buttonHeight));

			int timeX = presX + presWidth + spacingX;
			int timeWidth = 95;
			dicRect.Add("time", new RectangleF (timeX, row2Y, timeWidth, buttonHeight));

			//row3
			int histX = spacingX;
			int histWidth = 150;
			dicRect.Add("detailedhis", new RectangleF (histX, row3Y, histWidth, buttonHeight));

			int herenowX = histX + histWidth + spacingX * 2;
			int herenowWidth = 150;
			dicRect.Add("herenow", new RectangleF (herenowX, row3Y, herenowWidth, buttonHeight));

			//row4
			int unsubX = spacingX;
			int unsubWidth = 150;
			dicRect.Add("unsub", new RectangleF (unsubX, row4Y, unsubWidth, buttonHeight));

			int unsubPresX = unsubX + unsubWidth + spacingX * 2;
			int unsubPresWidth = 150;
			dicRect.Add("unsubpres", new RectangleF (unsubPresX, row4Y, unsubPresWidth, buttonHeight));

			return dicRect;
		}

		Dictionary<string, RectangleF> GetRectanglesForIpad ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int buttonHeight = 30;
			int spacingX = 5;

			int row1Y = 10;
			int row2Y = row1Y + buttonHeight + 5;

			int subsX = spacingX;
			int subsWidth = 150;
			dicRect.Add("subscribe", new RectangleF (subsX, row1Y, subsWidth, buttonHeight));

			int subsCX = subsX + subsWidth + spacingX;
			int subsCWidth = 205;
			dicRect.Add("subscribeconncallback", new RectangleF (subsCX, row1Y, subsCWidth, buttonHeight));

			int pubX = subsCX + subsCWidth + spacingX;
			int pubWidth = 140;
			dicRect.Add("publish", new RectangleF (pubX, row1Y, pubWidth, buttonHeight));

			int presX = pubX + pubWidth + spacingX;
			int presWidth = 140;
			dicRect.Add("presence", new RectangleF (presX, row1Y, presWidth, buttonHeight));

			int timeX = presX + presWidth + spacingX;
			int timeWidth = 100;
			dicRect.Add("time", new RectangleF (timeX, row1Y, timeWidth, buttonHeight));

			int histX = spacingX;
			int histWidth = 180;
			dicRect.Add("detailedhis", new RectangleF (histX, row2Y, histWidth, buttonHeight));

			int herenowX = histX + histWidth + spacingX;
			int herenowWidth = 180;
			dicRect.Add("herenow", new RectangleF (herenowX, row2Y, herenowWidth, buttonHeight));

			int unsubX = herenowX + herenowWidth + spacingX;;
			int unsubWidth = 180;
			dicRect.Add("unsub", new RectangleF (unsubX, row2Y, unsubWidth, buttonHeight));

			int unsubPresX = unsubX + unsubWidth + spacingX;
			int unsubPresWidth = 200;
			dicRect.Add("unsubpres", new RectangleF (unsubPresX, row2Y, unsubPresWidth, buttonHeight));

			return dicRect;
		}

		UIView CreateHeaderView (Dictionary<string, RectangleF> dicRect, int iViewHeight)
		{
			UIView uiView = new UIView (new RectangleF (0, 0, this.View.Bounds.Width, iViewHeight));
			uiView.MultipleTouchEnabled = true;
			
			//subscribe
			GlassButton gbSubs = new GlassButton (dicRect["subscribe"]);
			gbSubs.Font = font13;
			gbSubs.SetTitle ("Subscribe", UIControlState.Normal);
			gbSubs.Enabled = true;
			gbSubs.Tapped += delegate{Subscribe();};
			uiView.AddSubview (gbSubs);

			//subscribe
			GlassButton gbSubsConnect = new GlassButton (dicRect["subscribeconncallback"]);
			gbSubsConnect.Font = font13;
			gbSubsConnect.SetTitle ("Subscribe - Connect Callback", UIControlState.Normal);
			gbSubsConnect.Enabled = true;
			gbSubsConnect.Tapped += delegate{SubscribeConnectCallback();};
			uiView.AddSubview (gbSubsConnect);

			//publish
			GlassButton gbPublish = new GlassButton (dicRect["publish"]);
			gbPublish.Font = font13;
			gbPublish.SetTitle ("Publish", UIControlState.Normal);
			gbPublish.Enabled = true;
			gbPublish.Tapped += delegate{Publish();};
			uiView.AddSubview (gbPublish);

			//presence
			GlassButton gbPresence = new GlassButton (dicRect["presence"]);
			gbPresence.Font = font13;
			gbPresence.SetTitle ("Presence", UIControlState.Normal);
			gbPresence.Enabled = true;
			gbPresence.Tapped += delegate{Presence();};
			uiView.AddSubview (gbPresence);
			
			//Detailed History
			GlassButton gbDetailedHis = new GlassButton (dicRect["detailedhis"]);
			gbDetailedHis.Font = font13;
			gbDetailedHis.SetTitle ("Detailed History", UIControlState.Normal);
			gbDetailedHis.Enabled = true;
			gbDetailedHis.Tapped += delegate{DetailedHistory();};
			uiView.AddSubview (gbDetailedHis);

			//Here Now
			GlassButton gbHereNow = new GlassButton (dicRect["herenow"]);
			gbHereNow.Font = font13;
			gbHereNow.SetTitle ("Here Now", UIControlState.Normal);
			gbHereNow.Enabled = true;
			gbHereNow.Tapped += delegate{HereNow();};
			uiView.AddSubview (gbHereNow);
			
			//Time
			GlassButton gbTime = new GlassButton (dicRect["time"]);
			gbTime.Font = font13;
			gbTime.SetTitle ("Time", UIControlState.Normal);
			gbTime.Enabled = true;
			gbTime.Tapped += delegate{GetTime();};
			uiView.AddSubview (gbTime);
			
			//Unsubscribe
			GlassButton gbUnsub = new GlassButton (dicRect["unsub"]);
			gbUnsub.Font = font13;
			gbUnsub.SetTitle ("Unsubscribe", UIControlState.Normal);
			gbUnsub.Enabled = true;
			gbUnsub.Tapped += delegate{Unsub();};
			uiView.AddSubview (gbUnsub);
			
			//Unsubscribe-Presence
			GlassButton gbUnsubPres = new GlassButton (dicRect["unsubpres"]);
			gbUnsubPres.Font = font13;
			gbUnsubPres.SetTitle ("Unsubscribe-Presence", UIControlState.Normal);
			gbUnsubPres.Enabled = true;
			gbUnsubPres.Tapped += delegate{UnsubPresence();};
			uiView.AddSubview (gbUnsubPres);
			
			return uiView;
		}

		public void Subscribe()
		{
			//dvc.ReloadData();
			Display("Running Subscribe");
			pubnub.Subscribe<string>(Channel, DisplayReturnMessage);
		}

		public void SubscribeConnectCallback()
		{
			//dvc.ReloadData();
			Display("Running Subscribe with Connect Callback");
			pubnub.Subscribe<string>(Channel, DisplayReturnMessage, DisplayConnectStatusMessage);
		}

		public void Publish()
		{
			InputAlertView iav = new InputAlertView("Publish", "Enter message to publish", "Cancel", new String[]{"Ok"});
			iav.Dismissed += PublishAlertDismissed;
			iav.Show();
		}

		void PublishAlertDismissed (object sender, UIButtonEventArgs e)
		{
			InputAlertView iav = (InputAlertView)sender;
			if ((iav != null) && (!String.IsNullOrWhiteSpace (iav.EnteredText))) {
				Display("Running Publish");
				pubnub.Publish<string> (Channel, iav.EnteredText, DisplayReturnMessage);
			}
		}
		
		public void Presence()
		{
			Display("Running Presence");
			pubnub.Presence<string>(Channel, DisplayReturnMessage);
		}
		
		public void DetailedHistory()
		{
			Display("Running Detailed History");
			pubnub.DetailedHistory<string>(Channel, 100, DisplayReturnMessage);
		}
		
		public void HereNow()
		{
			Display("Running Here Now");
			pubnub.HereNow<string>(Channel, DisplayReturnMessage);
		}
		
		public void Unsub()
		{
			Display("Running unsubscribe");
			pubnub.Unsubscribe<string>(Channel, DisplayReturnMessage);
		}

		public void UnsubPresence()
		{
			Display("Running presence-unsubscribe");
			pubnub.PresenceUnsubscribe<string>(Channel, DisplayReturnMessage);
		}

		public void GetTime()
		{
			Display("Running Time");
			pubnub.Time<string>(DisplayReturnMessage);
		}

		/// <summary>
		/// Callback method to provide the connect status of Subscribe call
		/// </summary>
		/// <param name="result"></param>
		void DisplayConnectStatusMessage(string result)
		{
			Display(String.Format("Connect Callback - {0}", result));
		}
		
		public void Display (string strText)
		{
			StyledMultilineElement sme = new StyledMultilineElement (strText)
			{
				Font = font12
			};
			ThreadPool.QueueUserWorkItem (delegate {
				
				System.Threading.Thread.Sleep(2000);
				
				AppDelegate.navigation.BeginInvokeOnMainThread(delegate {
					//this.Animating = false;
					if(secOutput.Count > 20)
					{
						secOutput.RemoveRange(0, 10);
					}
					if (secOutput.Count > 0) {
						secOutput.Insert (secOutput.Count, sme);					}
					else
					{
						secOutput.Add (sme);
					}
					this.TableView.ReloadData();
					var lastIndexPath = this.root.Last()[this.root.Last().Count-1].IndexPath;
					this.TableView.ScrollToRow(lastIndexPath, UITableViewScrollPosition.Middle, true);	
				});
			});
		}

		void DisplayReturnMessage(string result)
		{
			Display (result);
		}
		
		/*void DisplayReturnMessage(object result)
		{
			IList<object> message = result as IList<object>;
			
			if (message != null && message.Count >= 1)
			{
				for (int index = 0; index < message.Count; index++)
				{
					ParseObject(message[index], 1);
				}
			}
			else
			{
				Display ("unable to parse data");
			}
		}
		
		void ParseObject(object result, int loop)
		{
			if (result is object[])
			{
				object[] arrResult = (object[])result;
				foreach (object item in arrResult)
				{
					if (item != null)
					{
						if (!item.GetType().IsGenericType)
						{
							if (!item.GetType().IsArray)
							{
								Display(item.ToString());
							}
							else
							{
								ParseObject(item, loop + 1);
							}
						}
						else
						{
							ParseObject(item, loop + 1);
						}
					}
					else
					{
						Display("");
					}
				}
			}
			else if (result.GetType().IsGenericType && (result.GetType().Name == typeof(Dictionary<,>).Name))
			{
				Dictionary<string, object> itemList = (Dictionary<string, object>)result;
				foreach (KeyValuePair<string, object> pair in itemList)
				{
					Display(string.Format("key = {0}", pair.Key));
					if (pair.Value is object[])
					{
						Display("value = ");
						ParseObject(pair.Value, loop);
					}
					else
					{
						Display (string.Format("value = {0}", pair.Value));
					}
				}
			}
			else
			{
				Display(result.ToString());
			}			
		}*/
	}
}
