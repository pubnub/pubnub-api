
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
		Pubnub _pubnub;
		string _Channel {
			get;set;
		}

		string _Cipher {
			get;set;
		}

		bool _Ssl {
			get;set;
		}

		DialogViewController _dvc;
		RootElement _root;
		Section _secOutput;
		UIFont _font12 = UIFont.SystemFontOfSize (12);
		UIFont _font13 = UIFont.SystemFontOfSize (13);

		public Pubnub_MessagingSub (string strChannelName, string strCipher, bool bEnableSSL) : base (UITableViewStyle.Grouped, null)
		{
			_Channel = strChannelName;
			_Ssl = bEnableSSL;
			_Cipher = strCipher;

			string strSsl = "";
			if (_Ssl) {
				strSsl = ", SSL";
			}
			
			string strCip = "";
			if (!String.IsNullOrWhiteSpace (_Cipher)) {
				strCip = ", Cipher";
			}
			
			string strHead = String.Format ("Ch: {0} {1} {2}", _Channel, strSsl, strCip);
			_pubnub = new Pubnub ("demo", "demo", "", _Cipher, _Ssl);
			
			Section secAction = new Section ();
			
			bool bIphone = true;
			
			string strHardwareVer = DeviceHardware.Version.ToString ().ToLower ();
			if (strHardwareVer.IndexOf ("ipad") >= 0) {
				bIphone = false;
			}
			
			Dictionary<string, RectangleF> dictRect = null;
			int iViewHeight = 140;
			
			if (bIphone) {
				dictRect = GetRectanglesForIphone();
				iViewHeight = 140;
			} else {
				dictRect = GetRectanglesForIpad();
				iViewHeight = 85;
			}
			
			secAction.HeaderView = CreateHeaderView(dictRect, iViewHeight);
			
			_secOutput = new Section("Output");
			
			_root = new RootElement (strHead) {
				secAction,
				_secOutput
			};
			Root = _root;
			_dvc = new DialogViewController (_root, true);
			_dvc.NavigationItem.RightBarButtonItem = new UIBarButtonItem(UIBarButtonSystemItem.Cancel, delegate {
				_pubnub.EndPendingRequests ();
				AppDelegate.navigation.PopToRootViewController(true);
			});
			AppDelegate.navigation.PushViewController (_dvc, true);
		}

		Dictionary<string, RectangleF> GetRectanglesForIphone ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int iButtonHeight = 30;
			int iSpacingX = 5;

			int iRow1Y = 10;
			int iRow2Y = iRow1Y + iButtonHeight + 5;
			int iRow3Y = iRow2Y + iButtonHeight + 5;
			int iRow4Y = iRow3Y + iButtonHeight + 5;

			//row1
			int iSubsX = iSpacingX;
			int iSubsWidth = 100;
			dicRect.Add("subscribe", new RectangleF (iSubsX, iRow1Y, iSubsWidth, iButtonHeight));

			int iSubsCX = iSubsX + iSubsWidth + iSpacingX;
			int iSubsCWidth = 205;
			dicRect.Add("subscribeconncallback", new RectangleF (iSubsCX, iRow1Y, iSubsCWidth, iButtonHeight));

			//row2
			int iPubX = iSpacingX;
			int iPubWidth = 100;
			dicRect.Add("publish", new RectangleF (iPubX, iRow2Y, iPubWidth, iButtonHeight));

			int iPresX = iPubX + iPubWidth + iSpacingX;
			int iPresWidth = 105;
			dicRect.Add("presence", new RectangleF (iPresX, iRow2Y, iPresWidth, iButtonHeight));

			int iTimeX = iPresX + iPresWidth + iSpacingX;
			int iTimeWidth = 95;
			dicRect.Add("time", new RectangleF (iTimeX, iRow2Y, iTimeWidth, iButtonHeight));

			//row3
			int iHistX = iSpacingX;
			int iHistWidth = 150;
			dicRect.Add("detailedhis", new RectangleF (iHistX, iRow3Y, iHistWidth, iButtonHeight));

			int iHerenowX = iHistX + iHistWidth + iSpacingX * 2;
			int iHerenowWidth = 150;
			dicRect.Add("herenow", new RectangleF (iHerenowX, iRow3Y, iHerenowWidth, iButtonHeight));

			//row4
			int iUnsubX = iSpacingX;
			int iUnsubWidth = 150;
			dicRect.Add("unsub", new RectangleF (iUnsubX, iRow4Y, iUnsubWidth, iButtonHeight));

			int iUnsubPresX = iUnsubX + iUnsubWidth + iSpacingX * 2;
			int iUnsubPresWidth = 150;
			dicRect.Add("unsubpres", new RectangleF (iUnsubPresX, iRow4Y, iUnsubPresWidth, iButtonHeight));

			return dicRect;
		}

		Dictionary<string, RectangleF> GetRectanglesForIpad ()
		{
			Dictionary<string, RectangleF> dicRect = new Dictionary<string, RectangleF>();
			int iButtonHeight = 30;
			int iSpacingX = 5;

			int iRow1Y = 10;
			int iRow2Y = iRow1Y + iButtonHeight + 5;

			int iSubsX = iSpacingX;
			int iSubsWidth = 150;
			dicRect.Add("subscribe", new RectangleF (iSubsX, iRow1Y, iSubsWidth, iButtonHeight));

			int iSubsCX = iSubsX + iSubsWidth + iSpacingX;
			int iSubsCWidth = 205;
			dicRect.Add("subscribeconncallback", new RectangleF (iSubsCX, iRow1Y, iSubsCWidth, iButtonHeight));

			int iPubX = iSubsCX + iSubsCWidth + iSpacingX;
			int iPubWidth = 140;
			dicRect.Add("publish", new RectangleF (iPubX, iRow1Y, iPubWidth, iButtonHeight));

			int iPresX = iPubX + iPubWidth + iSpacingX;
			int iPresWidth = 140;
			dicRect.Add("presence", new RectangleF (iPresX, iRow1Y, iPresWidth, iButtonHeight));

			int iTimeX = iPresX + iPresWidth + iSpacingX;
			int iTimeWidth = 100;
			dicRect.Add("time", new RectangleF (iTimeX, iRow1Y, iTimeWidth, iButtonHeight));

			int iHistX = iSpacingX;
			int iHistWidth = 180;
			dicRect.Add("detailedhis", new RectangleF (iHistX, iRow2Y, iHistWidth, iButtonHeight));

			int iHerenowX = iHistX + iHistWidth + iSpacingX;
			int iHerenowWidth = 180;
			dicRect.Add("herenow", new RectangleF (iHerenowX, iRow2Y, iHerenowWidth, iButtonHeight));

			int iUnsubX = iHerenowX + iHerenowWidth + iSpacingX;;
			int iUnsubWidth = 180;
			dicRect.Add("unsub", new RectangleF (iUnsubX, iRow2Y, iUnsubWidth, iButtonHeight));

			int iUnsubPresX = iUnsubX + iUnsubWidth + iSpacingX;
			int iUnsubPresWidth = 200;
			dicRect.Add("unsubpres", new RectangleF (iUnsubPresX, iRow2Y, iUnsubPresWidth, iButtonHeight));

			return dicRect;
		}

		UIView CreateHeaderView (Dictionary<string, RectangleF> dicRect, int iViewHeight)
		{
			UIView uiView = new UIView (new RectangleF (0, 0, this.View.Bounds.Width, iViewHeight));
			uiView.MultipleTouchEnabled = true;
			
			//subscribe
			GlassButton gbSubs = new GlassButton (dicRect["subscribe"]);
			gbSubs.Font = _font13;
			gbSubs.SetTitle ("Subscribe", UIControlState.Normal);
			gbSubs.Enabled = true;
			gbSubs.Tapped += delegate{Subscribe();};
			uiView.AddSubview (gbSubs);

			//subscribe
			GlassButton gbSubsConnect = new GlassButton (dicRect["subscribeconncallback"]);
			gbSubsConnect.Font = _font13;
			gbSubsConnect.SetTitle ("Subscribe - Connect Callback", UIControlState.Normal);
			gbSubsConnect.Enabled = true;
			gbSubsConnect.Tapped += delegate{SubscribeConnectCallback();};
			uiView.AddSubview (gbSubsConnect);

			//publish
			GlassButton gbPublish = new GlassButton (dicRect["publish"]);
			gbPublish.Font = _font13;
			gbPublish.SetTitle ("Publish", UIControlState.Normal);
			gbPublish.Enabled = true;
			gbPublish.Tapped += delegate{Publish();};
			uiView.AddSubview (gbPublish);

			//presence
			GlassButton gbPresence = new GlassButton (dicRect["presence"]);
			gbPresence.Font = _font13;
			gbPresence.SetTitle ("Presence", UIControlState.Normal);
			gbPresence.Enabled = true;
			gbPresence.Tapped += delegate{Presence();};
			uiView.AddSubview (gbPresence);
			
			//Detailed History
			GlassButton gbDetailedHis = new GlassButton (dicRect["detailedhis"]);
			gbDetailedHis.Font = _font13;
			gbDetailedHis.SetTitle ("Detailed History", UIControlState.Normal);
			gbDetailedHis.Enabled = true;
			gbDetailedHis.Tapped += delegate{DetailedHistory();};
			uiView.AddSubview (gbDetailedHis);

			//Here Now
			GlassButton gbHereNow = new GlassButton (dicRect["herenow"]);
			gbHereNow.Font = _font13;
			gbHereNow.SetTitle ("Here Now", UIControlState.Normal);
			gbHereNow.Enabled = true;
			gbHereNow.Tapped += delegate{HereNow();};
			uiView.AddSubview (gbHereNow);
			
			//Time
			GlassButton gbTime = new GlassButton (dicRect["time"]);
			gbTime.Font = _font13;
			gbTime.SetTitle ("Time", UIControlState.Normal);
			gbTime.Enabled = true;
			gbTime.Tapped += delegate{GetTime();};
			uiView.AddSubview (gbTime);
			
			//Unsubscribe
			GlassButton gbUnsub = new GlassButton (dicRect["unsub"]);
			gbUnsub.Font = _font13;
			gbUnsub.SetTitle ("Unsubscribe", UIControlState.Normal);
			gbUnsub.Enabled = true;
			gbUnsub.Tapped += delegate{Unsub();};
			uiView.AddSubview (gbUnsub);
			
			//Unsubscribe-Presence
			GlassButton gbUnsubPres = new GlassButton (dicRect["unsubpres"]);
			gbUnsubPres.Font = _font13;
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
			_pubnub.subscribe<string>(_Channel, DisplayReturnMessage);
		}

		public void SubscribeConnectCallback()
		{
			//dvc.ReloadData();
			Display("Running Subscribe with Connect Callback");
			_pubnub.subscribe<string>(_Channel, DisplayReturnMessage, DisplayConnectStatusMessage);
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
				_pubnub.publish<string> (_Channel, iav.EnteredText, DisplayReturnMessage);
			}
		}
		
		public void Presence()
		{
			Display("Running Presence");
			_pubnub.presence<string>(_Channel, DisplayReturnMessage);
		}
		
		public void DetailedHistory()
		{
			Display("Running Detailed History");
			_pubnub.detailedHistory<string>(_Channel, 100, DisplayReturnMessage);
		}
		
		public void HereNow()
		{
			Display("Running Here Now");
			_pubnub.here_now<string>(_Channel, DisplayReturnMessage);
		}
		
		public void Unsub()
		{
			Display("Running unsubscribe");
			_pubnub.unsubscribe<string>(_Channel, DisplayReturnMessage);
		}

		public void UnsubPresence()
		{
			Display("Running presence-unsubscribe");
			_pubnub.presence_unsubscribe<string>(_Channel, DisplayReturnMessage);
		}

		public void GetTime()
		{
			Display("Running Time");
			_pubnub.time<string>(DisplayReturnMessage);
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
				Font = _font12
			};
			ThreadPool.QueueUserWorkItem (delegate {
				
				System.Threading.Thread.Sleep(2000);
				
				AppDelegate.navigation.BeginInvokeOnMainThread(delegate {
					//this.Animating = false;
					if(_secOutput.Count > 20)
					{
						_secOutput.RemoveRange(0, 10);
					}
					if (_secOutput.Count > 0) {
						_secOutput.Insert (_secOutput.Count, sme);					}
					else
					{
						_secOutput.Add (sme);
					}
					this.TableView.ReloadData();
					var lastIndexPath = this._root.Last()[this._root.Last().Count-1].IndexPath;
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
