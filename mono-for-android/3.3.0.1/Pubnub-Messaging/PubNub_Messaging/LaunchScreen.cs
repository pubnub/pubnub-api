
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;

namespace PubNubMessaging.Core
{
	[Activity (Label = "PubNubMessaging", MainLauncher = true)]			
	public class LaunchScreen : Activity
	{
		Dialog dialog;
		TextView btnProxy;
		ToggleButton tgProxy;
		bool proxyEnabled = false;
		Button btnProxySave;
		TextView tvProxy;

		EditText proxyUsername;
		EditText proxyPassword;
		EditText proxyServer;
		EditText proxyPort;

		PubnubProxy proxy =  null;
		public static Pubnub pubnub = null;

		protected override void OnCreate (Bundle bundle)
		{
			base.OnCreate (bundle);

			SetContentView (Resource.Layout.Launch);

			Button btnLaunch = FindViewById<Button> (Resource.Id.btnLaunch);
			btnLaunch.Click += LaunchClick;

			btnProxy = FindViewById<Button> (Resource.Id.btnProxy);
			btnProxy.Click += ProxySettingsHandler;

			tvProxy = FindViewById<TextView> (Resource.Id.tvProxy);
			tvProxy.Text = SetProxyText(false);
		}

		string SetProxyText (bool on)
		{
			if(on)
			{
				return String.Format("{0} {1}", Resources.GetString (Resource.String.proxy), Resources.GetString(Resource.String.proxyOn)); 
			}
			else{
				return String.Format("{0} {1}", Resources.GetString(Resource.String.proxy), Resources.GetString(Resource.String.proxyOff)); 
			}
		}

		void ProxySettingsHandler (object sender, EventArgs e)
		{
			ShowProxySettings();
		}

		void ShowProxySettings ()
		{
			dialog = new Dialog (this);
			dialog.SetContentView (Resource.Layout.Proxy);
			dialog.SetTitle ("Proxy Settings"); 
			dialog.SetCancelable (true);

			dialog.CancelEvent += DialogDismissHandler;

			Button btnProxySave = (Button)dialog.FindViewById (Resource.Id.btnProxySave);
			Button btnProxyCancel = (Button)dialog.FindViewById (Resource.Id.btnProxyCancel);

			btnProxySave.Click += EnableProxy; 
			btnProxyCancel.Click += DisableProxy;
			
			proxyUsername = (EditText)dialog.FindViewById (Resource.Id.proxyUsername);
			proxyPassword = (EditText)dialog.FindViewById (Resource.Id.proxyPassword);
			proxyServer = (EditText)dialog.FindViewById (Resource.Id.proxyServer);
			proxyPort = (EditText)dialog.FindViewById (Resource.Id.proxyPort);
			
			tgProxy = (ToggleButton)dialog.FindViewById (Resource.Id.tbProxy);
			tgProxy.CheckedChange += ProxyCheckedChanged;
			tgProxy.Checked = true;

			if (proxy != null) {
				tgProxy.Checked = true;
				tvProxy.Text = SetProxyText(true);
			} else {
				tgProxy.Checked = false;

				tvProxy.Text = SetProxyText(false);
			}

			if ((proxy != null) && (!string.IsNullOrEmpty (proxy.ProxyServer))) {
				proxyServer.Text = proxy.ProxyServer;
			}
			if ((proxy != null) && (!string.IsNullOrEmpty (proxy.ProxyPort.ToString()))) {
				proxyPort.Text = proxy.ProxyPort.ToString();
			}
			if ((proxy != null) && (!string.IsNullOrEmpty (proxy.ProxyUserName))) {
				proxyUsername.Text = proxy.ProxyUserName;
			}
			if ((proxy != null) && (!string.IsNullOrEmpty (proxy.ProxyPassword))) {
				proxyPassword.Text = proxy.ProxyPassword;
			}

			dialog.Show();
		}

		void DialogDismissHandler (object sender, EventArgs e)
		{
			/*if (proxy == null) {
				tvProxy.Text = SetProxyText(false);
				tgProxy.Checked = false;
			}*/
		}

		void ProxyCheckedChanged (object sender, CompoundButton.CheckedChangeEventArgs e)
		{
			if (e.IsChecked) {
				proxyUsername.Enabled = true;
				proxyPassword.Enabled = true;
				proxyServer.Enabled = true;
				proxyPort.Enabled = true;
			} else {
				proxyUsername.Enabled = false;
				proxyUsername.Text = "";
				proxyPassword.Enabled = false;
				proxyPassword.Text = "";
				proxyServer.Enabled = false;
				proxyServer.Text = "";
				proxyPort.Enabled = false;
				proxyPort.Text = "";
				proxy = null;
			}
		}

		void DisableProxy (object sender, EventArgs e)
		{
			/*if (proxy == null) {
				tvProxy.Text = SetProxyText (false);
				tgProxy.Checked = false;
			}*/
			if (!tgProxy.Checked) 
			{
				proxyEnabled = false;
				tvProxy.Text = SetProxyText(false);
			} 
			dialog.Dismiss();
		}

		void EnableProxy (object sender, EventArgs e)
		{
			int port;

			bool errorFree = true;

			if (!tgProxy.Checked) 
			{
				proxyEnabled = false;
				tvProxy.Text = SetProxyText(false);
				dialog.Dismiss ();
			} 
			else 
			{
				if (string.IsNullOrWhiteSpace (proxyServer.Text)) {
					errorFree = false;
					ShowAlert ("Please enter proxy server."); 
				}

				if ((errorFree) && (string.IsNullOrWhiteSpace (proxyUsername.Text))) {
					errorFree = false;
					ShowAlert ("Please enter proxy username."); 
				}

				if ((errorFree) && (string.IsNullOrWhiteSpace (proxyPassword.Text))) {
					errorFree = false;
					ShowAlert ("Please enter proxy password."); 
				}

				if (errorFree) {
					if (Int32.TryParse (proxyPort.Text, out port) && ((port >= 1) && (port <= 65535))) {
						proxy = new PubnubProxy ();
						proxy.ProxyServer = proxyServer.Text;
						proxy.ProxyPort = port;
						proxy.ProxyUserName = proxyUsername.Text;
						proxy.ProxyPassword = proxyPassword.Text;
						proxyEnabled = true;
						tvProxy.Text = SetProxyText (true);
						dialog.Dismiss ();
					} else {
						ShowAlert ("Proxy port must be a valid integer between 1 to 65535"); 
					}
				}
			}
		}

		void LaunchClick (object sender, EventArgs e)
		{

			EditText txtChannel = FindViewById<EditText> (Resource.Id.txtChannel);
			if (String.IsNullOrWhiteSpace (txtChannel.Text.Trim ())) {
				ShowAlert ("Please enter a channel name");
			} else {

				ToggleButton tbSsl = FindViewById<ToggleButton> (Resource.Id.tbSsl);
				EditText txtCipher = FindViewById<EditText> (Resource.Id.txtCipher);
				EditText txtCustomUuid = FindViewById<EditText> (Resource.Id.txtCustomUuid);

				var mainActivity = new Intent(this, typeof(MainActivity));

				mainActivity.PutExtra("Channel", txtChannel.Text.Trim());

				if(tbSsl.Checked)
				{
					mainActivity.PutExtra("SslOn", "true");
				}
				else{
					mainActivity.PutExtra("SslOn", "false");
				}

				mainActivity.PutExtra("Cipher", txtCipher.Text.Trim());

				pubnub = new Pubnub ("demo", "demo", "", txtCipher.Text.Trim(), tbSsl.Checked);
				if(!String.IsNullOrWhiteSpace (txtCustomUuid.Text.Trim()))
				{
					pubnub.SessionUUID = txtCustomUuid.Text.Trim();
				}

				bool errorFree = true;

				if(proxyEnabled)
				{
					try
					{
						pubnub.Proxy = proxy;
					}
					catch (MissingFieldException mse)
					{
						errorFree = false;
						Console.WriteLine(mse.Message);

						ShowAlert ("Proxy settings invalid, please re-enter the details."); 
					}
				}
				if(errorFree)
				{
					StartActivity (mainActivity);
				}
			}
		}

		void ShowAlert (string message)
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.SetTitle(Android.Resource.String.DialogAlertTitle);
			builder.SetIcon(Android.Resource.Drawable.IcDialogAlert);
			builder.SetMessage(message);
			builder.SetPositiveButton("OK", (sender, e) =>
			    {
				});
			
			builder.Show();
		}
	}
}

