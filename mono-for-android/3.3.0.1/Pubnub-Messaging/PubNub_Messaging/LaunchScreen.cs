
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

namespace PubNub_Messaging
{
	[Activity (Label = "PubNub_Messaging", MainLauncher = true)]			
	public class LaunchScreen : Activity
	{
		protected override void OnCreate (Bundle bundle)
		{
			base.OnCreate (bundle);

			SetContentView (Resource.Layout.Launch);

			Button btnLaunch = FindViewById<Button> (Resource.Id.btnLaunch);
			
			btnLaunch.Click += LaunchClick;
		}

		void LaunchClick (object sender, EventArgs e)
		{
			EditText txtChannel = FindViewById<EditText> (Resource.Id.txtChannel);
			if (String.IsNullOrWhiteSpace (txtChannel.Text.Trim ())) {
				ShowEmptyChannelAlert ();
			} else {
				ToggleButton tbSsl = FindViewById<ToggleButton> (Resource.Id.tbSsl);
				EditText txtCipher = FindViewById<EditText> (Resource.Id.txtCipher);

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
				StartActivity (mainActivity);
			}
		}

		void ShowEmptyChannelAlert ()
		{
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.SetTitle(Android.Resource.String.DialogAlertTitle);
			builder.SetIcon(Android.Resource.Drawable.IcDialogAlert);
			builder.SetMessage("Please enter a channel name");
			builder.SetPositiveButton("OK", (sender, e) =>
			    {
				});
			
			builder.Show();
		}
	}
}

