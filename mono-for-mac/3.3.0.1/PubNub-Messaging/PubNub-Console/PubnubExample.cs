using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using System.Diagnostics;

namespace PubNubMessaging.Core
{
	public class PubnubExample
	{
		static public Pubnub pubnub;
		
		static public bool deliveryStatus = false;
		static public string channel = "";
		static public long startTime;

		static bool runSpeedtest = false;
		static List<double> speedTestValues;
		static Thread speedTestThread;

		static int consoleLeft;

		static int consoleTop;

		static public void Main()
		{
			PubnubProxy proxy = null;

			Console.WriteLine("HINT: TO TEST RE-CONNECT AND CATCH-UP,");
			Console.WriteLine("      DISCONNECT YOUR MACHINE FROM NETWORK/INTERNET AND ");
			Console.WriteLine("      RE-CONNECT YOUR MACHINE AFTER SOMETIME.");
			Console.WriteLine();
			Console.WriteLine("      IF NO NETWORK BEFORE MAX RE-TRY CONNECT,");
			Console.WriteLine("      NETWORK ERROR MESSAGE WILL BE SENT");
			Console.WriteLine();
			
			Console.WriteLine("ENTER Channel Name");
			channel = Console.ReadLine();
			
			Console.WriteLine(string.Format("Channel = {0}",channel));
			Console.WriteLine();
			
			Console.WriteLine("Enable SSL? ENTER Y for Yes, else N");
			string enableSSL = Console.ReadLine();
			if (enableSSL.Trim().ToLower() == "y")
			{
				Console.WriteLine("SSL Enabled");
			}
			else
			{
				Console.WriteLine("SSL NOT Enabled");
			}
			Console.WriteLine();
			
			Console.WriteLine("ENTER cipher key for encryption feature.");
			Console.WriteLine("If you don't want to avail at this time, press ENTER.");
			string cipheryKey = Console.ReadLine();
			if (cipheryKey.Trim().Length > 0)
			{
				Console.WriteLine("Cipher key provided.");
			}
			else
			{
				Console.WriteLine("No Cipher key provided");
			}
			Console.WriteLine();
			
			pubnub = new Pubnub("demo", "demo", "", cipheryKey,
			                    (enableSSL.Trim().ToLower() == "y") ? true : false);

			Console.WriteLine("Use Custom Session UUID? ENTER Y for Yes, else N");
			string enableCustomUUID = Console.ReadLine();
			if (enableCustomUUID.Trim().ToLower() == "y")
			{
				Console.WriteLine("ENTER Session UUID.");
				string sessionUUID = Console.ReadLine();
				pubnub.SessionUUID = sessionUUID;
				Console.WriteLine("Accepted Custom Session UUID.");
			}
			else
			{
				Console.WriteLine("Default Session UUID opted.");
			}
			Console.WriteLine();

			Console.WriteLine("Proxy Server exists? ENTER Y for Yes, else N");
			string enableProxy = Console.ReadLine();
			if (enableProxy.Trim().ToLower() == "y")
			{
				bool proxyAccepted = false;
				while (!proxyAccepted)
				{
					Console.WriteLine("ENTER proxy server name or IP.");
					string proxyServer = Console.ReadLine();
					Console.WriteLine("ENTER port number of proxy server.");
					string proxyPort = Console.ReadLine();
					int port;
					Int32.TryParse(proxyPort, out port);
					Console.WriteLine("ENTER user name for proxy server authentication.");
					string proxyUsername = Console.ReadLine();
					Console.WriteLine("ENTER password for proxy server authentication.");
					string proxyPassword = Console.ReadLine();
					
					proxy = new PubnubProxy();
					proxy.ProxyServer = proxyServer;
					proxy.ProxyPort = port;
					proxy.ProxyUserName = proxyUsername;
					proxy.ProxyPassword = proxyPassword;
					try
					{
						pubnub.Proxy = proxy;
						proxyAccepted = true;
						Console.WriteLine("Proxy details accepted");
					}
					catch (MissingFieldException mse)
					{
						Console.WriteLine(mse.Message);
						Console.WriteLine("Please RE-ENTER Proxy Server details.");
					}
				}
			}
			else
			{
				Console.WriteLine("No Proxy");
			}
			Console.WriteLine();

			Console.WriteLine("ENTER 1 FOR Subscribe (not implementing connectCallback)");
			Console.WriteLine("ENTER 2 FOR Subscribe (implementing connectCallback)");
			Console.WriteLine("ENTER 3 FOR Publish");
			Console.WriteLine("ENTER 4 FOR Presence");
			Console.WriteLine("ENTER 5 FOR Detailed History");
			Console.WriteLine("ENTER 6 FOR Here_Now");
			Console.WriteLine("ENTER 7 FOR Unsubscribe");
			Console.WriteLine("ENTER 8 FOR Presence-Unsubscribe");
			Console.WriteLine("ENTER 9 FOR Time");
			Console.WriteLine("ENTER s FOR Speed Test");
			Console.WriteLine("ENTER 0 FOR EXIT OR QUIT");
			
			bool exitFlag = false;
			
			Console.WriteLine("");
			while (!exitFlag)
			{
				string userinput = Console.ReadLine();
				switch (userinput)
				{
				case "0":
					exitFlag = true;
					pubnub.EndPendingRequests();
					break;
				case "1":
					Console.WriteLine("Running subscribe() (not implementing connectCallback)");
					pubnub.Subscribe<string>(channel, DisplayReturnMessage);
					break;
				case "2":
					Console.WriteLine("Running subscribe() (implementing connectCallback)");
					pubnub.Subscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);
					break;
				case "3":
					Console.WriteLine("Running publish()");
					Console.WriteLine("Enter the message for publish. To exit loop, enter QUIT");
					string publishMsg = Console.ReadLine();
					double doubleData;
					int intData;

					if (int.TryParse(publishMsg, out intData)) //capture numeric data
					{
						pubnub.Publish<string>(channel, intData, DisplayReturnMessage);
					}
					else if (double.TryParse(publishMsg, out doubleData)) //capture numeric data
					{
						pubnub.Publish<string>(channel, doubleData, DisplayReturnMessage);
					}
					else
					{
						//check whether any numeric is sent in double quotes
						if (publishMsg.IndexOf("\"") == 0 && publishMsg.LastIndexOf("\"") == publishMsg.Length - 1)
						{
							string strMsg = publishMsg.Substring(1, publishMsg.Length - 2);
							if (int.TryParse(strMsg, out intData))
							{
								pubnub.Publish<string>(channel, strMsg, DisplayReturnMessage);
							}
							else if (double.TryParse(strMsg, out doubleData))
							{
								pubnub.Publish<string>(channel, strMsg, DisplayReturnMessage);
							}
							else
							{
								pubnub.Publish<string>(channel, publishMsg, DisplayReturnMessage);
							}
						}
						else
						{
							pubnub.Publish<string>(channel, publishMsg, DisplayReturnMessage);
						}
					}
					break;
				case "4":
					Console.WriteLine("Running presence()");
					pubnub.Presence<string>(channel, DisplayReturnMessage);
					break;
				case "5":
					Console.WriteLine("Running detailed history()");
					pubnub.DetailedHistory<string>(channel, 100, DisplayReturnMessage);
					break;
				case "6":
					Console.WriteLine("Running Here_Now()");
					pubnub.HereNow<string>(channel, DisplayReturnMessage);
					break;
				case "7":
					Console.WriteLine("Running unsubscribe()");
					pubnub.Unsubscribe<string>(channel, DisplayReturnMessage);
					break;
				case "8":
					Console.WriteLine("Running presence-unsubscribe()");
					pubnub.PresenceUnsubscribe<string>(channel, DisplayReturnMessage);
					break;
				case "9":
					Console.WriteLine("Running time()");
					pubnub.Time<string>(DisplayReturnMessage);
					break;
				case "s":
				case "S":
					Console.WriteLine("Running speed test. Enter 'q' to end the speed test");
					LaunchSpeedTest();
					break;
				case "q":
				case "Q":
					Console.WriteLine("Ending speed test");
					runSpeedtest = false;
					if((speedTestThread!=null) && (speedTestThread.IsAlive))
					{
						speedTestThread.Join(1000);
					}
					if(speedTestValues!=null)
					{
						speedTestValues.Clear();
					}

					break;
				default:
					Console.WriteLine("INVALID CHOICE.");
					break;
				}
			}
			
			Console.WriteLine("\nPress any key to exit.\n\n");
			Console.ReadLine();
		}

		static void LaunchSpeedTest ()
		{
			speedTestThread = new Thread(new ParameterizedThreadStart(RunSpeedTest));
			runSpeedtest = true;
			pubnub.Unsubscribe<string>(channel, SpeedTestPublishReturnMessage);
			pubnub.Subscribe<string>(channel, SpeedTestSubscribeReturnMessage);
			speedTestThread.Name = "Pubnub Speedtest";
			speedTestThread.Start();
		}

		static void RunSpeedTest (object obj)
		{
			Console.CursorVisible=false;
			consoleTop = Console.CursorTop;
			consoleLeft = 0;
			while (runSpeedtest) 
			{
				startTime = DateTime.Now.Ticks;
				pubnub.Publish<string>(channel, "Speed test message", SpeedTestPublishReturnMessage);
				Thread.Sleep(200);
			}
			Console.CursorVisible=true;
		}

		static void SpeedTestPublishReturnMessage (string result)
		{
			//Console.WriteLine(result);
		}

		static void SpeedTestSubscribeReturnMessage (string result)
		{
			long endTime = DateTime.Now.Ticks;
			double lag = Math.Round(((endTime - startTime) / 10000f), 2);

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
					string disp = string.Format ("Total messages: {0}" 
						+", Max: {1} MS, Min: {2} MS, Avg: {3} MS, Curr: {4} MS", 
				         total.ToString (), min.ToString (), max.ToString (), avg.ToString ()
					                             , lag.ToString ());

					OverwriteConsoleMessage(disp);
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.ToString());
				}
			}
		}

		public static void OverwriteConsoleMessage(string message)
		{
			int maxCharacterWidth = Console.WindowWidth - 1;
			/*int diff = Console.CursorTop - consoleTop;
			if(diff >= 0)
			{
				for(int i=0; i<=diff; i++)
				{
					Console.SetCursorPosition(consoleLeft, consoleTop+i);
				}
			}*/

			Console.SetCursorPosition(consoleLeft, consoleTop);
			if (message.Length > maxCharacterWidth)
			{
				message = message.Substring(0, maxCharacterWidth - 3) + "...";
			}
			message = message + new string(' ', (maxCharacterWidth>message.Length) ? maxCharacterWidth - message.Length: 0);
			Console.Write (message);
		}
		
		/// <summary>
		/// Callback method captures the response in JSON string format for all operations
		/// </summary>
		/// <param name="result"></param>
		static void DisplayReturnMessage(string result)
		{
			Console.WriteLine(result);
		}
		
		/// <summary>
		/// Callback method to provide the connect status of Subscribe call
		/// </summary>
		/// <param name="result"></param>
		static void DisplayConnectStatusMessage(string result)
		{
			Console.WriteLine(result);
		}
	}
}

