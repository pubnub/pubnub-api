using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Threading;

namespace PubNubMessaging.Core
{
    public class PubnubExample
    {
        static public Pubnub pubnub;

        static public bool deliveryStatus = false;
        static public string channel = "";

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

            Console.WriteLine("Enable SSL? ENTER Y for Yes, else N");
            string enableSSL = Console.ReadLine();
            Console.ForegroundColor = ConsoleColor.Blue;
            if (enableSSL.Trim().ToLower() == "y")
            {
                Console.WriteLine("SSL Enabled");
            }
            else
            {
                Console.WriteLine("SSL NOT Enabled");
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("ENTER cipher key for encryption feature.");
            Console.WriteLine("If you don't want to avail at this time, press ENTER.");
            string cipheryKey = Console.ReadLine();
            Console.ForegroundColor = ConsoleColor.Blue;
            if (cipheryKey.Trim().Length > 0)
            {
                Console.WriteLine("Cipher key provided.");
            }
            else
            {
                Console.WriteLine("No Cipher key provided");
            }
            Console.ResetColor();
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
                Console.ForegroundColor = ConsoleColor.Blue;
                Console.WriteLine("Accepted Custom Session UUID.");
                Console.ResetColor();
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Blue;
                Console.WriteLine("Default Session UUID opted.");
                Console.ResetColor();
            }
            Console.WriteLine();

            Console.WriteLine("By default Resume On Reconnect is enabled. Do you want to disable it? ENTER Y for Yes, else N");
            string disableResumeOnReconnect = Console.ReadLine();
            Console.ForegroundColor = ConsoleColor.Blue;
            if (disableResumeOnReconnect.Trim().ToLower() == "y")
            {
                Console.WriteLine("Resume On Reconnect Disabled");
                pubnub.EnableResumeOnReconnect = false;
            }
            else
            {
                Console.WriteLine("Resume On Reconnect Enabled by default");
                pubnub.EnableResumeOnReconnect = true;
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("Subscribe Timeout = 310 seconds (default). Enter the value to change, else press ENTER");
            string subscribeTimeoutEntry = Console.ReadLine();
            int subscribeTimeout;
            Int32.TryParse(subscribeTimeoutEntry, out subscribeTimeout);
            Console.ForegroundColor = ConsoleColor.Blue;
            if (subscribeTimeout > 0)
            {
                Console.WriteLine("Subscribe Timeout = {0}",subscribeTimeout);
                pubnub.SubscribeTimeout = subscribeTimeout;
            }
            else
            {
                Console.WriteLine("Subscribe Timeout = {0} (default)", pubnub.SubscribeTimeout);
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("Non Subscribe Timeout = 15 seconds (default). Enter the value to change, else press ENTER");
            string nonSubscribeTimeoutEntry = Console.ReadLine();
            int nonSubscribeTimeout;
            Int32.TryParse(nonSubscribeTimeoutEntry, out nonSubscribeTimeout);
            Console.ForegroundColor = ConsoleColor.Blue;
            if (nonSubscribeTimeout > 0)
            {
                Console.WriteLine("Non Subscribe Timeout = {0}", nonSubscribeTimeout);
                pubnub.NonSubscribeTimeout = nonSubscribeTimeout;
            }
            else
            {
                Console.WriteLine("Non Subscribe Timeout = {0} (default)", pubnub.NonSubscribeTimeout);
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("Network Check MAX retries = 50 (default). Enter the value to change, else press ENTER");
            string networkCheckMaxRetriesEntry = Console.ReadLine();
            int networkCheckMaxRetries;
            Int32.TryParse(networkCheckMaxRetriesEntry, out networkCheckMaxRetries);
            Console.ForegroundColor = ConsoleColor.Blue;
            if (networkCheckMaxRetries > 0)
            {
                Console.WriteLine("Network Check MAX retries = {0}", networkCheckMaxRetries);
                pubnub.NetworkCheckMaxRetries = networkCheckMaxRetries;
            }
            else
            {
                Console.WriteLine("Network Check MAX retries = {0} (default)", pubnub.NetworkCheckMaxRetries);
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("Network Check Retry Interval = 10 seconds (default). Enter the value to change, else press ENTER");
            string networkCheckRetryIntervalEntry = Console.ReadLine();
            int networkCheckRetryInterval;
            Int32.TryParse(networkCheckRetryIntervalEntry, out networkCheckRetryInterval);
            Console.ForegroundColor = ConsoleColor.Blue;
            if (networkCheckRetryInterval > 0)
            {
                Console.WriteLine("Network Check Retry Interval = {0} seconds", networkCheckRetryInterval);
                pubnub.NetworkCheckRetryInterval = networkCheckRetryInterval;
            }
            else
            {
                Console.WriteLine("Network Check Retry Interval = {0} seconds (default)", pubnub.NetworkCheckRetryInterval);
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("Heartbeat Interval = 15 seconds (default). Enter the value to change, else press ENTER");
            string heartbeatIntervalEntry = Console.ReadLine();
            int heartbeatInterval;
            Int32.TryParse(heartbeatIntervalEntry, out heartbeatInterval);
            Console.ForegroundColor = ConsoleColor.Blue;
            if (heartbeatInterval > 0)
            {
                Console.WriteLine("Heartbeat Interval = {0} seconds", heartbeatInterval);
                pubnub.HeartbeatInterval = heartbeatInterval;
            }
            else
            {
                Console.WriteLine("Heartbeat Interval = {0} seconds (default)", pubnub.HeartbeatInterval);
            }
            Console.ResetColor();
            Console.WriteLine();

            Console.WriteLine("HTTP Proxy Server with NTLM authentication(IP + username/pwd) exists? ENTER Y for Yes, else N");
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("NOTE: Pubnub example is being tested with CCProxy 7.3 Demo version");
            Console.ResetColor();
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
                    Console.ForegroundColor = ConsoleColor.Blue;
                    try
                    {
                        pubnub.Proxy = proxy;
                        proxyAccepted = true;
                        Console.WriteLine("Proxy details accepted");
                        Console.ResetColor();
                    }
                    catch (MissingFieldException mse)
                    {
                        Console.WriteLine(mse.Message);
                        Console.WriteLine("Please RE-ENTER Proxy Server details.");
                    }
                    Console.ResetColor();
                }
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Blue;
                Console.WriteLine("No Proxy");
                Console.ResetColor();
            }
            Console.WriteLine();


            Console.WriteLine("ENTER 1 FOR Subscribe");
            Console.WriteLine("ENTER 2 FOR Publish");
            Console.WriteLine("ENTER 3 FOR Presence");
            Console.WriteLine("ENTER 4 FOR Detailed History");
            Console.WriteLine("ENTER 5 FOR Here_Now");
            Console.WriteLine("ENTER 6 FOR Unsubscribe");
            Console.WriteLine("ENTER 7 FOR Presence-Unsubscribe");
            Console.WriteLine("ENTER 8 FOR Time");
            Console.WriteLine("ENTER 9 FOR Disconnect/Reconnect existing Subscriber(s) (when internet is available)");
            Console.WriteLine("ENTER 10 TO Disable Network Connection (no internet)");
            Console.WriteLine("ENTER 11 TO Enable Network Connection (yes internet)");
            Console.WriteLine("ENTER 99 FOR EXIT OR QUIT");

            bool exitFlag = false;
            string channel="";

            Console.WriteLine("");
            while (!exitFlag)
            {
                string userinput = Console.ReadLine();
                switch (userinput)
                {
                    case "99":
                        exitFlag = true;
                        pubnub.EndPendingRequests();
                        break;
                    case "1":
                        Console.WriteLine("Enter CHANNEL name for subscribe. Use comma to enter multiple channels.");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running subscribe()");
                        pubnub.Subscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);

                        break;
                    case "2":
                        Console.WriteLine("Enter CHANNEL name for publish.");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();

                        Console.WriteLine("Enter the message for publish. To exit loop, enter QUIT");
                        string publishMsg = Console.ReadLine();
                        
                        Console.WriteLine("Running publish()");

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
                    case "3":
                        Console.WriteLine("Enter CHANNEL name for presence. Use comma to enter multiple channels.");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Presence Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running presence()");
                        pubnub.Presence<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage);

                        break;
                    case "4":
                        Console.WriteLine("Enter CHANNEL name for Detailed History");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running detailed history()");
                        pubnub.DetailedHistory<string>(channel, 100, DisplayReturnMessage);
                        break;
                    case "5":
                        Console.WriteLine("Enter CHANNEL name for HereNow");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running Here_Now()");
                        pubnub.HereNow<string>(channel, DisplayReturnMessage);
                        break;
                    case "6":
                        Console.WriteLine("Enter CHANNEL name for Unsubscribe. Use comma to enter multiple channels.");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running unsubscribe()");
                        pubnub.Unsubscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage, DisplayDisconnectStatusMessage);
                        break;
                    case "7":
                        Console.WriteLine("Enter CHANNEL name for Presence Unsubscribe. Use comma to enter multiple channels.");
                        channel = Console.ReadLine();

                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine(string.Format("Channel = {0}",channel));
                        Console.ResetColor();
                        Console.WriteLine();

                        Console.WriteLine("Running presence-unsubscribe()");
                        pubnub.PresenceUnsubscribe<string>(channel, DisplayReturnMessage, DisplayConnectStatusMessage, DisplayDisconnectStatusMessage);
                        break;
                    case "8":
                        Console.WriteLine("Running time()");
                        pubnub.Time<string>(DisplayReturnMessage);
                        break;
                    case "9":
                        Console.WriteLine("Running Disconnect/auto-Reconnect Subscriber Request Connection");
                        pubnub.TerminateCurrentSubscriberRequest();
                        break;
                    case "10":
                        Console.WriteLine("Disabling Network Connection (no internet)");
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("Initiating Simulation of Internet non-availability");
                        Console.WriteLine("Until Choice=11 is entered, no operations will occur");
                        Console.WriteLine("NOTE: Publish from other pubnub clients can occur and those will be ");
                        Console.WriteLine("      captured upon choice=11 is entered provided resume on reconnect is enabled.");
                        Console.ResetColor();
                        pubnub.EnableSimulateNetworkFailForTestingOnly();
                        break;
                    case "11":
                        Console.WriteLine("Enabling Network Connection (yes internet)");
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("Stopping Simulation of Internet non-availability");
                        Console.ResetColor();
                        pubnub.DisableSimulateNetworkFailForTestingOnly();
                        break;
                    default:
                        Console.WriteLine("INVALID CHOICE. ENTER 99 FOR EXIT OR QUIT");
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

        static void DisplayDisconnectStatusMessage(string result)
        {
            Console.WriteLine(result);
        }
    }
}
