using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Threading;

namespace PubNub_Messaging
{
    	public class Pubnub_Example
	{
		static public Pubnub pubnub;
		
		static public bool deliveryStatus = false;
		static public string channel = "";
		
		static public void Main()
		{
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
			
			Console.WriteLine("ENTER 1 FOR Subscribe (not implementing connectCallback)");
			Console.WriteLine("ENTER 2 FOR Subscribe (implementing connectCallback)");
			Console.WriteLine("ENTER 3 FOR Publish");
			Console.WriteLine("ENTER 4 FOR Presence");
			Console.WriteLine("ENTER 5 FOR Detailed History");
			Console.WriteLine("ENTER 6 FOR Here_Now");
			Console.WriteLine("ENTER 7 FOR Unsubscribe");
			Console.WriteLine("ENTER 8 FOR Presence-Unsubscribe");
			Console.WriteLine("ENTER 9 FOR Time");
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
					pubnub.subscribe<string>(channel, DisplayReturnMessage);
					break;
				case "2":
					Console.WriteLine("Running subscribe() (implementing connectCallback)");
					pubnub.subscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);
					break;
				case "3":
					Console.WriteLine("Running publish()");
					Console.WriteLine("Enter the message for publish. To exit loop, enter QUIT");
					string publishMsg = Console.ReadLine();
					double doubleData;
					int intData;
					if (int.TryParse(publishMsg, out intData)) //capture numeric data
					{
						pubnub.publish<string>(channel, intData, DisplayReturnMessage);
					}
					else if (double.TryParse(publishMsg, out doubleData)) //capture numeric data
					{
						pubnub.publish<string>(channel, doubleData, DisplayReturnMessage);
					}
					else
					{
						//check whether any numeric is sent in double quotes
						if (publishMsg.IndexOf("\"") == 0 && publishMsg.LastIndexOf("\"") == publishMsg.Length - 1)
						{
							string strMsg = publishMsg.Substring(1, publishMsg.Length - 2);
							if (int.TryParse(strMsg, out intData))
							{
								pubnub.publish<string>(channel, strMsg, DisplayReturnMessage);
							}
							else if (double.TryParse(strMsg, out doubleData))
							{
								pubnub.publish<string>(channel, strMsg, DisplayReturnMessage);
							}
							else
							{
								pubnub.publish<string>(channel, publishMsg, DisplayReturnMessage);
							}
						}
						else
						{
							pubnub.publish<string>(channel, publishMsg, DisplayReturnMessage);
						}
					}
					break;
				case "4":
					Console.WriteLine("Running presence()");
					pubnub.presence<string>(channel, DisplayReturnMessage);
					break;
				case "5":
					Console.WriteLine("Running detailed history()");
					pubnub.detailedHistory<string>(channel, 100, DisplayReturnMessage);
					break;
				case "6":
					Console.WriteLine("Running Here_Now()");
					pubnub.here_now<string>(channel, DisplayReturnMessage);
					break;
				case "7":
					Console.WriteLine("Running unsubscribe()");
					pubnub.unsubscribe<string>(channel, DisplayReturnMessage);
					break;
				case "8":
					Console.WriteLine("Running presence-unsubscribe()");
					pubnub.presence_unsubscribe<string>(channel, DisplayReturnMessage);
					break;
				case "9":
					Console.WriteLine("Running time()");
					pubnub.time<string>(DisplayReturnMessage);
					break;
				default:
					Console.WriteLine("INVALID CHOICE.");
					break;
				}
			}
			
			Console.WriteLine("\nPress any key to exit.\n\n");
			Console.ReadLine();
			
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
