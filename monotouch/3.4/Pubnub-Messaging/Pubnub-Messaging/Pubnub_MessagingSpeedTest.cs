
using System;
using System.Collections.Generic;
using System.Linq;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using MonoTouch.Dialog;
using PubNubMessaging.Core;
using System.Threading;
using System.Diagnostics;
using MonoTouch.CoreGraphics;
using System.Drawing;

namespace PubnubMessaging
{
	class Pubnub_MessagingSpeedTest: DialogViewController
	{
		DialogViewController dvc;
		Pubnub pubnub;
		RootElement root;

		public long startTime;
		
		bool runSpeedtest = false;
		List<double> speedTestValues;
		Thread speedTestThread;

		Section secOutput;
		Section secOutputSd;

		SdHeader sdHeader;
		PerformanceHeader perfHeader;
		GraphHeader graphHeader;

		string[] speedTestSorted;
		string[] speedTestNames;

		string Channel {
			get;set;
		}
		
		string Cipher {
			get;set;
		}
		
		bool Ssl {
			get;set;
		}

		public override void LoadView ()
		{
			base.LoadView ();
			this.Style = UITableViewStyle.Plain; 
			TableView.BackgroundView = null;
			TableView.BackgroundColor = UIColor.White;
			TableView.SeparatorColor = UIColor.Clear;
			TableView.ScrollEnabled = true;
		}

		public Pubnub_MessagingSpeedTest (string channelName, string cipher, bool enableSSL, Pubnub pubnub)
			: base (UITableViewStyle.Plain, null)
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
			
			bool bIphone = true;
			
			string hardwareVer = DeviceHardware.Version.ToString ().ToLower ();
			if (hardwareVer.IndexOf ("ipad") >= 0) {
				bIphone = false;
			}

			InitArrays();

			perfHeader = new PerformanceHeader();
			secOutput = new Section(perfHeader.View);

			sdHeader = new SdHeader(speedTestNames, speedTestSorted);
			sdHeader.View.Tag = 101;

			graphHeader = new GraphHeader();
			graphHeader.View.Tag = 102;

			UISegmentedControl segmentedControl = new UISegmentedControl();
			segmentedControl.HorizontalAlignment = UIControlContentHorizontalAlignment.Center;

			segmentedControl.Frame = new RectangleF(10, 20, UIScreen.MainScreen.Bounds.Width - 20, 40);
			segmentedControl.InsertSegment("Graph", 0, false);
			segmentedControl.InsertSegment("SD", 1, false);
			segmentedControl.AutoresizingMask = UIViewAutoresizing.FlexibleWidth;

			segmentedControl.AddSubview(graphHeader.View);

			segmentedControl.ValueChanged += (sender, e) => {
				var selectedSegmentId = (sender as UISegmentedControl).SelectedSegment;
				if (segmentedControl.SelectedSegment == 0)
				{
					if(segmentedControl.ViewWithTag(101) != null)
					{
						segmentedControl.ViewWithTag(101).RemoveFromSuperview();
					}
					graphHeader.View.AutoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth;
					segmentedControl.AddSubview(graphHeader.View);

				}
				else if (segmentedControl.SelectedSegment == 1)
				{
					if(segmentedControl.ViewWithTag(102) != null)
					{
						segmentedControl.ViewWithTag(102).RemoveFromSuperview();
					}

					sdHeader.View.AutoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth;
					segmentedControl.AddSubview(sdHeader.View);
				}
			};
			segmentedControl.SelectedSegment = 0;
			segmentedControl.ControlStyle = UISegmentedControlStyle.Plain;
			secOutput.Add(segmentedControl);

			Section sectionSegmentedControl = new Section();
			//sectionSegmentedControl.Add(segmentedControl);

			root = new RootElement (head) {
				new Section("PubNub speed test"),
				secOutput,
				//sectionSegmentedControl
			};

			Root = root;
			this.Root.UnevenRows = true;
			dvc = new DialogViewController (UITableViewStyle.Plain, root, true);
			dvc.NavigationItem.RightBarButtonItem = new UIBarButtonItem(UIBarButtonSystemItem.Cancel, delegate {
				pubnub.EndPendingRequests ();
				runSpeedtest = false;
				speedTestThread.Join(1000);
				AppDelegate.navigation.PopToRootViewController(true);
			});
			dvc.TableView.ScrollEnabled = true;
			dvc.TableView.SeparatorColor = UIColor.Clear;
			dvc.TableView.SeparatorStyle = UITableViewCellSeparatorStyle.None;
			dvc.TableView.BackgroundView = null;
			dvc.TableView.BackgroundColor = UIColor.White;
			AppDelegate.navigation.PushViewController (dvc, true);

			LaunchSpeedTest ();

		}

		void InitArrays ()
		{
			speedTestSorted = new string[17];
			speedTestNames = new string[17];
			speedTestNames[0] = "Fastest";
			speedTestNames[1] = "2%";
			speedTestNames[2] = "5%";
			speedTestNames[3] = "10%";
			speedTestNames[4] = "20%";
			speedTestNames[5] = "25%";
			speedTestNames[6] = "30%";
			speedTestNames[7] = "40%";
			speedTestNames[8] = "45%";
			speedTestNames[9] = "50%";
			speedTestNames[10] = "66%";
			speedTestNames[11] = "75%";
			speedTestNames[12] = "80%";
			speedTestNames[13] = "90%";
			speedTestNames[14] = "95%";
			speedTestNames[15] = "98%";
			speedTestNames[16] = "Slowest";
		}

		void LaunchSpeedTest ()
		{
			speedTestThread = new Thread(new ParameterizedThreadStart(RunSpeedTest));
			runSpeedtest = true;
            pubnub.Unsubscribe<string>(Channel, SpeedTestPublishReturnMessage, SpeedTestPublishReturnMessage, SpeedTestPublishReturnMessage);
            pubnub.Subscribe<string>(Channel, SpeedTestSubscribeReturnMessage, SpeedTestPublishReturnMessage);
			speedTestThread.Name = "Pubnub Speedtest";
			speedTestThread.Start();
		}
		
		void RunSpeedTest (object obj)
		{
			while (runSpeedtest) 
			{
				startTime = DateTime.Now.Ticks;
				pubnub.Publish<string>(Channel, "Speed test message", SpeedTestPublishReturnMessage);
				Thread.Sleep(200);
			}
		}
		
		void SpeedTestPublishReturnMessage (string result)
		{
		}
		
		void SpeedTestSubscribeReturnMessage (string result)
		{
			long endTime = DateTime.Now.Ticks;
			double lag =  Math.Round(((endTime - startTime) / 10000f),2);
			
			if (lag > 0) {
				if(speedTestValues == null)
					speedTestValues = new List<double>();
				
				speedTestValues.Add (lag);
				try
				{
					double max = Math.Round(speedTestValues.Max (), 2);
					double min = Math.Round(speedTestValues.Min (), 2); 
					double avg = Math.Round(speedTestValues.Average (), 2);
					int total = speedTestValues.Count;
					speedTestValues.Sort();

					foreach (double value in speedTestValues)
					{
						//Console.WriteLine(value);
					}
					speedTestSorted[0] = ((int)speedTestValues[0]).ToString();
					speedTestSorted[1] = ((int)GetMedianLow(speedTestValues, 0.02)).ToString();
					speedTestSorted[2] = ((int)GetMedianLow(speedTestValues, 0.05)).ToString();
					speedTestSorted[3] = ((int)GetMedianLow(speedTestValues, 0.1)).ToString();
					speedTestSorted[4] = ((int)GetMedianLow(speedTestValues, 0.2)).ToString();
					speedTestSorted[5] = ((int)GetMedianLow(speedTestValues, 0.25)).ToString();
					speedTestSorted[6] = ((int)GetMedianLow(speedTestValues, 0.30)).ToString();
					speedTestSorted[7] = ((int)GetMedianLow(speedTestValues, 0.40)).ToString();
					speedTestSorted[8] = ((int)GetMedianLow(speedTestValues, 0.45)).ToString();
					speedTestSorted[9] = ((int)GetMedianLow(speedTestValues, 0.50)).ToString();
					speedTestSorted[10] = ((int)GetMedianLow(speedTestValues, 0.66)).ToString();
					speedTestSorted[11] = ((int)GetMedianLow(speedTestValues, 0.75)).ToString();
					speedTestSorted[12] = ((int)GetMedianLow(speedTestValues, 0.80)).ToString();
					speedTestSorted[13] = ((int)GetMedianLow(speedTestValues, 0.90)).ToString();
					speedTestSorted[14] = ((int)GetMedianLow(speedTestValues, 0.95)).ToString();
					speedTestSorted[15] = ((int)GetMedianLow(speedTestValues, 0.98)).ToString();
					speedTestSorted[16] = ((int)speedTestValues[speedTestValues.Count - 1]).ToString();


					DisplayHeader(total, min, max, avg, lag);
					DisplaySd();
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.ToString());
				}
			}
		}

		/*private void UpdateMedian(List<double> valueList)
		{
			int length = valueList.Count - 1;
			Medlen = (int)Math.Floor(length / 2.0d);
			valueList.Sort();
		}
		
		public double GetMedian(List<double> valueList, double value)
		{
			int lenght = valueList.Count - 1;
			return valueList[Medlen + (int)Math.Floor(lenght * value)];
		}*/

		public double GetMedianLow(List<double> valueList, double value)
		{
			int length = valueList.Count - 1;
			//double medlen = Math.Floor(length/2d);
			return valueList[(int)Math.Floor(length * value)];
		}

		/*public double GetMedian(List<long> valueList, double value)
		{
			int length = valueList.Count - 1;
			double medlen = Math.Floor(length/2d);
			return valueList[medlen + Math.Floor(length * value)];
		}*/

		void DisplayHeader (int total, double min, double max, double avg, double lag)
		{
			ThreadPool.QueueUserWorkItem (delegate {
				AppDelegate.navigation.BeginInvokeOnMainThread(delegate {
					perfHeader.Update(total.ToString(), min.ToString(), max.ToString(), avg.ToString(), lag.ToString());
					graphHeader.Update(total, min, max, avg, lag);
				});
			});
		}

		public void DisplaySd ()
		{
			ThreadPool.QueueUserWorkItem (delegate {
				AppDelegate.navigation.BeginInvokeOnMainThread(delegate {
					sdHeader.Update(speedTestNames, speedTestSorted);
				});
			});
		}
	}
}
