using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Navigation;
using PubnubSilverlight.Core;
using System.Diagnostics;
using System.ComponentModel;
using System.IO;
using System.Threading;
using Microsoft.Silverlight.Testing;

namespace PubnubSilverlight.Example.Views
{
    public partial class CodeExampleView : Page
    {

        #region "Properties and Members"

        static public bool deliveryStatus = false;
        static public Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
        static public string channel = "hello_world";
        static public string message = "Pubnub API Usage Example - Publish";
        #endregion

        public CodeExampleView()
        {
            InitializeComponent();

            Console.Container = ConsoleContainer;
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

        //#region "Publish Example"

        //private static void Publish_Example()
        //{
        //    pubnub.CIPHER_KEY = "";

        //    pubnub.PropertyChanged -= Publish_Example_Changed;
        //    pubnub.PropertyChanged += Publish_Example_Changed;

        //    pubnub.publish(channel, message);
        //}

        //private static void Publish_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Publish")
        //    {
        //        Console.WriteLine("\n*********** Publish Messages *********** ");
        //        Console.WriteLine("Publish Success: " + ((Pubnub)sender).Publish[0].ToString() + "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString());
        //    }
        //}

        //#endregion

        //#region "Detailed History Example"

        //private static void DetailedHistory_Example()
        //{
        //    pubnub.CIPHER_KEY = "";
        //    pubnub.PropertyChanged -= DetailedHistory_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(DetailedHistory_Example_Changed);
        //    pubnub.detailedHistory(channel, 10);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        //}

        //private static void MessageFeeder(object feed)
        //{
        //    try
        //    {
        //        Dictionary<string, object> _message = (Dictionary<string, object>)(feed);
        //        for (int i = 0; i < _message.Count; i++)
        //            Console.WriteLine("Key: " + _message.ElementAt(i).Key + " - Value: " + _message.ElementAt(i).Value);
        //    }
        //    catch
        //    {
        //        try
        //        {
        //            List<object> _message = (List<object>)feed;
        //            for (int i = 0; i < _message.Count; i++)
        //                Console.WriteLine(_message[i].ToString());
        //        }
        //        catch
        //        {
        //            Console.WriteLine("Time: " + feed.ToString());
        //        }

        //    }
        //}

        //private static void DetailedHistory_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        MessageFeeder(((Pubnub)sender).DetailedHistory);
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Detailed History Decrypted Example"

        //private static void DetailedHistory_Decrypted_Example()
        //{
        //    pubnub.CIPHER_KEY = "enigma";
        //    //int start = 
        //    pubnub.PropertyChanged -= DetailedHistory_Decrypted_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(DetailedHistory_Decrypted_Example_Changed);
        //    pubnub.detailedHistory(channel, 1);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        //}

        //private static void DetailedHistory_Decrypted_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        MessageFeeder((List<object>)(((Pubnub)sender).DetailedHistory));
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Timestamp Example"

        //private static void Timestamp_Example()
        //{
        //    pubnub.CIPHER_KEY = "";

        //    pubnub.PropertyChanged -= Timestamp_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(Timestamp_Example_Changed);
        //    pubnub.time();
        //}

        //private static void Timestamp_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Time")
        //    {
        //        Console.WriteLine("\n********** Timestamp Messages ********** ");
        //        MessageFeeder(((Pubnub)sender).Time[0]);
        //    }
        //}

        //#endregion

        //#region "HereNow Example"

        //private static void HereNow_Example()
        //{
        //    pubnub.CIPHER_KEY = "";
        //    pubnub.PropertyChanged -= HereNow_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(HereNow_Example_Changed);
        //    pubnub.here_now(channel);
        //}

        //private static void HereNow_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Here_Now")
        //    {
        //        Console.WriteLine("\n********** Here Now Messages *********** ");
        //        Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).Here_Now[0]);
        //        foreach (object uuid in (object[])_message["uuids"])
        //        {
        //            Console.WriteLine("UUID: " + uuid.ToString());
        //        }
        //        Console.WriteLine("Occupancy: " + _message["occupancy"].ToString());
        //    }
        //}

        //#endregion

        //#region "Presence Example"

        //private static void Presence_Example()
        //{
        //    pubnub.CIPHER_KEY = "";
        //    pubnub.PropertyChanged -= Presence_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(Presence_Example_Changed);
        //    pubnub.presence(channel);
        //}

        //private static void Presence_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "ReturnMessage")
        //    {
        //        Console.WriteLine("\n********** Presence Messages ********** ");
        //        MessageFeeder(((Pubnub)sender).ReturnMessage);
        //    }
        //}

        //#endregion

        //#region "Subscribe Example"

        //private static void Subscribe_Example()
        //{
        //    pubnub.CIPHER_KEY = "";
        //    pubnub.PropertyChanged -= Subscribe_Example_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(Subscribe_Example_Changed);
        //    pubnub.subscribe(channel);
        //}

        //private static void Subscribe_Example_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "ReturnMessage")
        //    {
        //        Console.WriteLine("\n********** Subscribe Messages ********** ");
        //        MessageFeeder(((Pubnub)sender).ReturnMessage);
        //    }
        //}

        //#endregion

        //#region "Test Unencrypted History"

        //private static void TestUnencryptedHistory()
        //{
        //    pubnub.CIPHER_KEY = "";
        //    pubnub.PropertyChanged -= TestUnencryptedHistory_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestUnencryptedHistory_Changed);
        //    pubnub.publish(channel, message);
        //    pubnub.history(channel, 1);
        //}

        //private static void TestUnencryptedHistory_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Publish")
        //    {
        //        Console.WriteLine("\n*********** Publish Messages *********** ");
        //        Console.WriteLine("Publish Success: " + ((Pubnub)sender).Publish[0].ToString() + "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString());
        //    }

        //    if (e.PropertyName == "History")
        //    {
        //        Console.WriteLine("\n*********** History Messages *********** ");
        //        MessageFeeder(((Pubnub)sender).History);
        //    }

        //}

        //#endregion

        //#region "Test Encrypted History"

        //private static void TestEncryptedHistory()
        //{
        //    pubnub.CIPHER_KEY = "enigma";
        //    pubnub.PropertyChanged -= TestEncryptedHistory_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestEncryptedHistory_Changed);
        //    pubnub.publish(channel, message);
        //    pubnub.history(channel, 1);
        //}

        //private static void TestEncryptedHistory_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Publish")
        //    {
        //        Console.WriteLine("\n*********** Publish Messages *********** ");
        //        Console.WriteLine("Publish Success: " + ((Pubnub)sender).Publish[0].ToString() + "\nPublish Info: " + ((Pubnub)sender).Publish[1].ToString());
        //    }

        //    if (e.PropertyName == "History")
        //    {
        //        Console.WriteLine("\n*********** History Messages *********** ");
        //        MessageFeeder(((Pubnub)sender).History);
        //    }

        //}

        //#endregion

        //#region "Test Unencrypted Detailed History"

        //private static void TestUnencryptedDetailedHistory()
        //{
        //    // Context setup for Detailed History
        //    pubnub.CIPHER_KEY = "";
        //    int total_msg = 10;
        //    long starttime = Timestamp();
        //    Dictionary<long, string> inputs = new Dictionary<long, string>();
        //    for (int i = 0; i < total_msg / 2; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long midtime = Timestamp();
        //    for (int i = total_msg / 2; i < total_msg; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long endtime = Timestamp();

        //    deliveryStatus = false;
        //    pubnub.PropertyChanged -= TestUnencryptedDetailedHistory_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestUnencryptedDetailedHistory_Changed);
        //    pubnub.detailedHistory(channel, total_msg);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        //}

        //private static void TestUnencryptedDetailedHistory_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
        //        {
        //            Console.WriteLine(msg_org.ToString());
        //        }
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Test Encrypted Detailed History"

        //private static void TestEncryptedDetailedHistory()
        //{
        //    // Context setup for Detailed History
        //    pubnub.CIPHER_KEY = "enigma";
        //    int total_msg = 10;
        //    long starttime = Timestamp();
        //    Dictionary<long, string> inputs = new Dictionary<long, string>();
        //    for (int i = 0; i < total_msg / 2; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long midtime = Timestamp();
        //    for (int i = total_msg / 2; i < total_msg; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long endtime = Timestamp();

        //    deliveryStatus = false;
        //    pubnub.PropertyChanged -= TestEncryptedDetailedHistory_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestEncryptedDetailedHistory_Changed);
        //    pubnub.detailedHistory(channel, total_msg);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
        //}

        //private static void TestEncryptedDetailedHistory_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
        //        {
        //            Console.WriteLine(msg_org.ToString());
        //        }
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Test Unencrypted Detailed History Params"

        //private static void TestUnencryptedDetailedHistoryParams()
        //{
        //    // Context setup for Detailed History
        //    pubnub.CIPHER_KEY = "";
        //    int total_msg = 10;
        //    long starttime = Timestamp();
        //    Dictionary<long, string> inputs = new Dictionary<long, string>();
        //    for (int i = 0; i < total_msg / 2; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long midtime = Timestamp();
        //    for (int i = total_msg / 2; i < total_msg; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long endtime = Timestamp();

        //    deliveryStatus = false;
        //    pubnub.PropertyChanged -= TestUnencryptedDetailedHistoryParams_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestUnencryptedDetailedHistoryParams_Changed);
        //    Console.WriteLine("DetailedHistory with start & end");
        //    pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("DetailedHistory with start & reverse = true");
        //    deliveryStatus = false;
        //    pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("DetailedHistory with start & reverse = false");
        //    deliveryStatus = false;
        //    pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        //}

        //private static void TestUnencryptedDetailedHistoryParams_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
        //        {
        //            Console.WriteLine(msg_org.ToString());
        //        }
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Test Encrypted Detailed History Params"

        //private static void TestEncryptedDetailedHistoryParams()
        //{
        //    // Context setup for Detailed History
        //    pubnub.CIPHER_KEY = "enigma";
        //    int total_msg = 10;
        //    long starttime = Timestamp();
        //    Dictionary<long, string> inputs = new Dictionary<long, string>();
        //    for (int i = 0; i < total_msg / 2; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long midtime = Timestamp();
        //    for (int i = total_msg / 2; i < total_msg; i++)
        //    {
        //        string msg = i.ToString();
        //        pubnub.publish(channel, msg);
        //        long t = Timestamp();
        //        inputs.Add(t, msg);
        //        Console.WriteLine("Message # " + i.ToString() + " published");
        //    }

        //    long endtime = Timestamp();

        //    deliveryStatus = false;
        //    pubnub.PropertyChanged -= TestEncryptedDetailedHistoryParams_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(TestEncryptedDetailedHistoryParams_Changed);
        //    Console.WriteLine("DetailedHistory with start & end");
        //    pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("DetailedHistory with start & reverse = true");
        //    deliveryStatus = false;
        //    pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("DetailedHistory with start & reverse = false");
        //    deliveryStatus = false;
        //    pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false);
        //    while (!deliveryStatus) ;
        //    Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
        //}

        //private static long Timestamp()
        //{
        //    deliveryStatus = false;
        //    pubnub.PropertyChanged -= Timestamp_Changed;
        //    pubnub.PropertyChanged += new PropertyChangedEventHandler(Timestamp_Changed);
        //    pubnub.time();
        //    while (!deliveryStatus) ;
        //    return Convert.ToInt64(pubnub.Time[0].ToString());
        //}

        //private static void TestEncryptedDetailedHistoryParams_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "DetailedHistory")
        //    {
        //        Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
        //        foreach (object msg_org in (List<object>)((Pubnub)sender).DetailedHistory)
        //        {
        //            Console.WriteLine(msg_org.ToString());
        //        }
        //        deliveryStatus = true;
        //    }
        //}

        //private static void Timestamp_Changed(object sender, PropertyChangedEventArgs e)
        //{
        //    if (e.PropertyName == "Time")
        //    {
        //        deliveryStatus = true;
        //    }
        //}

        //#endregion

        //#region "Events"

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning publish()");

        //    Thread task = new Thread(Publish_Example) { IsBackground = true };

        //    task.Start();

        }

        private void Button_Click_2(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning detailedHistory()");

        //    Thread task = new Thread(DetailedHistory_Example) { IsBackground = true };

        //    task.Start();

        }

        private void Button_Click_3(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning detailedHistory()");

        //    Thread task = new Thread(DetailedHistory_Decrypted_Example) { IsBackground = true };

        //    task.Start();

        }

        private void Button_Click_4(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning timestamp()");

        //    Thread task = new Thread(Timestamp_Example) { IsBackground = true };

        //    task.Start();

        }

        private void Button_Click_5(object sender, RoutedEventArgs e)
        {
        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning here_now()");

        //    Thread task = new Thread(HereNow_Example) { IsBackground = true };

        //    task.Start();

        }

        private void Button_Click_6(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning presence()");

        //    Thread task = new Thread(Presence_Example) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_7(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning timestamp()");

        //    Thread task = new Thread(Subscribe_Example) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_8(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestUnencryptedHistory()");

        //    Thread task = new Thread(TestUnencryptedHistory) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_9(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestEncryptedHistory()");

        //    Thread task = new Thread(TestEncryptedHistory) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_10(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestUnencryptedDetailedHistory()");

        //    Thread task = new Thread(TestUnencryptedDetailedHistory) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_11(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestEncryptedDetailedHistory()");

        //    Thread task = new Thread(TestEncryptedDetailedHistory) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_12(object sender, RoutedEventArgs e)
        {

        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestUnencryptedDetailedHistoryParams()");

        //    Thread task = new Thread(TestUnencryptedDetailedHistoryParams) { IsBackground = true };

        //    task.Start();
        }

        private void Button_Click_13(object sender, RoutedEventArgs e)
        {
        //    Console.Clear();

        //    Console.WriteLine("Starting...");

        //    Console.WriteLine("\nRunning TestEncryptedDetailedHistoryParams()");

        //    Thread task = new Thread(TestEncryptedDetailedHistoryParams) { IsBackground = true };

        //    task.Start();
        }

        //#endregion


    }

    #region "Console View"

    public class Console
    {
        public static TextBlock Container { get; set; }

        public static void WriteLine(string format)
        {
            Container.Dispatcher.BeginInvoke(() =>
            {
                if (Container != null)
                {
                    if (Container.Text == null)
                    {
                        Container.Text = "";
                    }
                    Container.Text += format + "\r\n";
                }
            });
        }

        public static void Clear()
        {
            if (Container != null)
            {
                Container.Text = string.Empty;
            }
        }

    }

    #endregion

}
