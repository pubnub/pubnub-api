
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNub_Messaging;
using System.Threading;
using System.Drawing;
using MonoTouch.ObjCRuntime;

namespace PubnubMessaging
{
	public partial class Pubnub_MessagingSub : DialogViewController
	{
		Pubnub pubnub;
		string channel {
			get;set;
		}

		DialogViewController dvc;
		RootElement root;
		Section secOutput;
		UIFont font12 = UIFont.SystemFontOfSize (12);
		UIFont font13 = UIFont.SystemFontOfSize (13);

		public Pubnub_MessagingSub (string strChannelName, string strCipher, bool bEnableSSL) : base (UITableViewStyle.Grouped, null)
		{
			channel = strChannelName;
			string strSsl = "";
			if (bEnableSSL)
				strSsl = ", SSL";

			string strCip = "";
			if (!String.IsNullOrWhiteSpace (strCipher)) {
				strCip = ", Cipher";
			}

			string strHead = String.Format ("Ch: {0} {1} {2}", strChannelName, strSsl, strCip);
			pubnub = new Pubnub ("demo", "demo", "", strCipher, bEnableSSL);

			Section secAction = new Section ();

			bool bIphone = true;

			string strHardwareVer = DeviceHardware.Version.ToString ().ToLower ();
			if (strHardwareVer.IndexOf ("ipad") >= 0) {
				bIphone = false;
			}

			Dictionary<string, RectangleF> dictRect = null;
			int iViewHeight = 100;

			if (bIphone) {
				dictRect = GetRectanglesForIphone();
				iViewHeight = 100;
			} else {
				dictRect = GetRectanglesForIpad();
				iViewHeight = 40;
			}

			secAction.HeaderView = CreateHeaderView(dictRect, iViewHeight);

			secOutput = new Section("Output");

			root = new RootElement (strHead) {
				secAction,
				secOutput
			};
			Root = root;
			dvc = new DialogViewController (root, true);
			AppDelegate.navigation.PushViewController (dvc, true);
		}

		Dictionary<string, RectangleF> GetRectanglesForIphone ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int iButtonHeight = 30;
			int iSpacingX = 5;

			int iRow1Y = 10;
			int iRow2Y = iRow1Y + iButtonHeight + 5;
			int iRow3Y = iRow2Y + iButtonHeight + 5;

			int iSubsX = iSpacingX;
			int iSubsWidth = 110;
			dicRect.Add("subscribe", new RectangleF (iSubsX, iRow1Y, iSubsWidth, iButtonHeight));

			int iPubX = iSubsX + iSubsWidth + iSpacingX;
			int iPubWidth = 95;
			dicRect.Add("publish", new RectangleF (iPubX, iRow1Y, iPubWidth, iButtonHeight));

			int iPresX = iPubX + iPubWidth + iSpacingX;
			int iPresWidth = 95;
			dicRect.Add("presence", new RectangleF (iPresX, iRow1Y, iPresWidth, iButtonHeight));

			int iHistX = iSpacingX;
			int iHistWidth = 110;
			dicRect.Add("detailedhis", new RectangleF (iHistX, iRow2Y, iHistWidth, iButtonHeight));

			int iHerenowX = iHistX + iHistWidth + iSpacingX;
			int iHerenowWidth = 100;
			dicRect.Add("herenow", new RectangleF (iHerenowX, iRow2Y, iHerenowWidth, iButtonHeight));

			int iTimeX = iHerenowX + iHerenowWidth + iSpacingX;
			int iTimeWidth = 90;
			dicRect.Add("time", new RectangleF (iTimeX, iRow2Y, iTimeWidth, iButtonHeight));

			int iUnsubX = iSpacingX;
			int iUnsubWidth = 150;
			dicRect.Add("unsub", new RectangleF (iUnsubX, iRow3Y, iUnsubWidth, iButtonHeight));

			int iUnsubPresX = iUnsubX + iUnsubWidth + iSpacingX * 2;
			int iUnsubPresWidth = 150;
			dicRect.Add("unsubpres", new RectangleF (iUnsubPresX, iRow3Y, iUnsubPresWidth, iButtonHeight));

			return dicRect;
		}

		Dictionary<string, RectangleF> GetRectanglesForIpad ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int iButtonHeight = 30;
			int iSpacingX = 5;

			int iRow1Y = 10;

			int iSubsX = iSpacingX;
			int iSubsWidth = 85;
			dicRect.Add("subscribe", new RectangleF (iSubsX, iRow1Y, iSubsWidth, iButtonHeight));

			int iPubX = iSubsX + iSubsWidth + iSpacingX;
			int iPubWidth = 70;
			dicRect.Add("publish", new RectangleF (iPubX, iRow1Y, iPubWidth, iButtonHeight));

			int iPresX = iPubX + iPubWidth + iSpacingX;
			int iPresWidth = 80;
			dicRect.Add("presence", new RectangleF (iPresX, iRow1Y, iPresWidth, iButtonHeight));

			int iHistX = iPresX + iPresWidth + iSpacingX;
			int iHistWidth = 110;
			dicRect.Add("detailedhis", new RectangleF (iHistX, iRow1Y, iHistWidth, iButtonHeight));

			int iHerenowX = iHistX + iHistWidth + iSpacingX;
			int iHerenowWidth = 80;
			dicRect.Add("herenow", new RectangleF (iHerenowX, iRow1Y, iHerenowWidth, iButtonHeight));

			int iTimeX = iHerenowX + iHerenowWidth + iSpacingX;
			int iTimeWidth = 55;
			dicRect.Add("time", new RectangleF (iTimeX, iRow1Y, iTimeWidth, iButtonHeight));

			int iUnsubX = iTimeX + iTimeWidth + iSpacingX;;
			int iUnsubWidth = 100;
			dicRect.Add("unsub", new RectangleF (iUnsubX, iRow1Y, iUnsubWidth, iButtonHeight));

			int iUnsubPresX = iUnsubX + iUnsubWidth + iSpacingX;
			int iUnsubPresWidth = 145;
			dicRect.Add("unsubpres", new RectangleF (iUnsubPresX, iRow1Y, iUnsubPresWidth, iButtonHeight));

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
			pubnub.subscribe<string>(channel, DisplayReturnMessage);
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
				pubnub.publish<string> (channel, iav.EnteredText, DisplayReturnMessage);
			}
		}
		
		public void Presence()
		{
			Display("Running Presence");
			pubnub.presence<string>(channel, DisplayReturnMessage);
		}
		
		public void DetailedHistory()
		{
			Display("Running Detailed History");
			pubnub.detailedHistory<string>(channel, 100, DisplayReturnMessage);
		}
		
		public void HereNow()
		{
			Display("Running Here Now");
			pubnub.here_now<string>(channel, DisplayReturnMessage);
		}
		
		public void Unsub()
		{
			Display("Running unsubscribe");
			pubnub.unsubscribe<string>(channel, DisplayReturnMessage);
		}

		public void UnsubPresence()
		{
			Display("Running presence-unsubscribe");
			pubnub.presence_unsubscribe<string>(channel, DisplayReturnMessage);
		}

		public void GetTime()
		{
			Display("Running Time");
			pubnub.time<string>(DisplayReturnMessage);
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
		
		void DisplayReturnMessage(object result)
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
		}
	}
}
