using System;
using Android.App;
using Android.Content;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using Android.OS;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;


namespace PubNubMessaging.Core
{
	[Activity (Label = "PubNubMessaging")]
	public class MainActivity : Activity
	{
		Pubnub pubnub;

		string channel {
			get;set;
		}


		protected override void OnCreate (Bundle bundle)
		{
			base.OnCreate (bundle);
			/*if (ApplicationContext.Resources.Configuration.ScreenLayout = Android.Content.Res.ScreenLayout.SizeLarge) {
				SetContentView (Resource.Layout.Mainlarge);
			} else {*/
				
			//}
			//Build.VERSION.Sdk

			SetContentView (Resource.Layout.Main);

			string channelName = Intent.GetStringExtra("Channel");
			channel = channelName;

			bool enableSSL = Convert.ToBoolean((Intent.GetStringExtra("SslOn")));
			string cipher = (Intent.GetStringExtra("Cipher"));

			string ssl= "";
			if (enableSSL)
				ssl = ", SSL";

			if (!String.IsNullOrWhiteSpace (cipher)) {
				cipher = ", Cipher";
			}

			string head = String.Format ("Channel: {0}{1}{2}", channelName, ssl, cipher);

			pubnub = LaunchScreen.pubnub;
			//pubnub = new Pubnub ("demo", "demo", "", cipher, enableSSL);

			Title = head;

			Button btnSubscribe = FindViewById<Button> (Resource.Id.btnSubscribe);
			btnSubscribe.Click += delegate {Subscribe();};

			Button btnSubscribeConnCallback = FindViewById<Button> (Resource.Id.btnSubscribeConnCallback);
			btnSubscribeConnCallback.Click += delegate {SubscribeConnCallback();};

			Button btnCancel = FindViewById<Button> (Resource.Id.btnCancel);
			btnCancel.Click += delegate {pubnub.EndPendingRequests();Finish();};

			Button btnPresence = FindViewById<Button> (Resource.Id.btnPresence);
			btnPresence.Click += delegate {Presence();};
			
			Button btnPublish = FindViewById<Button> (Resource.Id.btnPublish);
			btnPublish.Click += delegate {Publish();};
			
			Button btnHereNow = FindViewById<Button> (Resource.Id.btnHereNow);
			btnHereNow.Click += delegate {HereNow();};
			
			Button btnDetailedHis = FindViewById<Button> (Resource.Id.btnDetailedHis);
			btnDetailedHis.Click += delegate {DetailedHistory();};
			
			Button btnTime = FindViewById<Button> (Resource.Id.btnTime);
			btnTime.Click += delegate {GetTime();};
			
			Button btnUnsub = FindViewById<Button> (Resource.Id.btnUnsub);
			btnUnsub.Click += delegate {Unsub();};
			
			Button btnUnsubPres = FindViewById<Button> (Resource.Id.btnUnsubPres);
			btnUnsubPres.Click += delegate {UnsubPresence();};
			
		}

		public void Subscribe()
		{
			Display("Running Subscribe");
			pubnub.Subscribe<string>(channel, DisplayReturnMessage);
		}

		public void SubscribeConnCallback()
		{
			Display("Running Subscribe Connection Callback");
			pubnub.Subscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);
		}

		public void Publish()
		{
			AlertDialog.Builder alert = new AlertDialog.Builder(this);
			
			alert.SetTitle("Publish");
			alert.SetMessage("Enter message to publish");
			
			// Set an EditText view to get user input 
			EditText input = new EditText(this);
			alert.SetView(input);
			
			alert.SetPositiveButton("OK", (sender, e) =>
			                        {
				Display("Running Publish");
				pubnub.Publish<string> (channel, input.Text, DisplayReturnMessage);
			});
			
			alert.SetNegativeButton("Cancel", (sender, e) =>
			                        {
			});
			alert.Show();
			//this.RunOnUiThread(() => alert.Show());
		}
		
		public void Presence()
		{
			Display("Running Presence");
			pubnub.Presence<string>(channel, DisplayReturnMessage);
		}
		
		public void DetailedHistory()
		{
			Display("Running Detailed History");
			pubnub.DetailedHistory<string>(channel, 100, DisplayReturnMessage);
		}
		
		public void HereNow()
		{
			Display("Running Here Now");
			pubnub.HereNow<string>(channel, DisplayReturnMessage);
		}
		
		public void Unsub()
		{
			Display("Running unsubscribe");
			pubnub.Unsubscribe<string>(channel, DisplayReturnMessage);
		}
		
		public void UnsubPresence()
		{
			Display("Running presence-unsubscribe");
			pubnub.PresenceUnsubscribe<string>(channel, DisplayReturnMessage);
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
			this.RunOnUiThread(() =>
			                   {
				TextView txtViewLog = FindViewById<TextView> (Resource.Id.txtViewLog);
				txtViewLog.Append("\n");
				txtViewLog.Append(strText);			}
			                   );
		}
		
		void DisplayReturnMessage(string result)
		{
			Display (result);
		}
		
	}
}


