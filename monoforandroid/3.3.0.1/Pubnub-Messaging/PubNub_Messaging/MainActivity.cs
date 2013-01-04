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


namespace PubNub_Messaging
{
	[Activity (Label = "PubNub_Messaging")]
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

			string strChannelName = Intent.GetStringExtra("Channel");
			channel = strChannelName;

			bool bEnableSSL = Convert.ToBoolean((Intent.GetStringExtra("SslOn")));
			string strCipher = (Intent.GetStringExtra("Cipher"));

			string strSsl= "";
			if (bEnableSSL)
				strSsl = ", SSL";

			if (!String.IsNullOrWhiteSpace (strCipher)) {
				strCipher = ", Cipher";
			}

			string strHead = String.Format ("Channel: {0}{1}{2}", strChannelName, strSsl, strCipher);
			pubnub = new Pubnub ("demo", "demo", "", strCipher, bEnableSSL);

			Title = strHead;

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
			pubnub.subscribe<string>(channel, DisplayReturnMessage);
		}

		public void SubscribeConnCallback()
		{
			Display("Running Subscribe Connection Callback");
			pubnub.subscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);
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
				pubnub.publish<string> (channel, input.Text, DisplayReturnMessage);
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


