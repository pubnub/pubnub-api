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
//using PubnubSilverlight.Core;
using System.Diagnostics;
using System.ComponentModel;
using System.IO;
using System.Threading;
using Microsoft.Silverlight.Testing;
using PubnubSilverlight.Example.Dialogs;
using PubnubSilverlight.Core;
//using PubNub_Messaging;

namespace PubnubSilverlight.Example.Views
{
    public partial class CodeExampleView : Page
    {

        #region "Properties and Members"

        static public Pubnub pubnub;

        static public bool deliveryStatus = false;
        public string channel
        {
            get
            {
                return string.IsNullOrEmpty(ChannelInput.Text) ? string.Empty : ChannelInput.Text;
            }
        }

        static public bool enableSSL = false;
        static public string cipheryKey = string.Empty;
       
        #endregion

        public CodeExampleView()
        {
            InitializeComponent();
            
            Console.Container = ConsoleContainer;

            MessageBoxResult result = MessageBox.Show("Enable SSL?", "Settings", MessageBoxButton.OKCancel);
            if (result == MessageBoxResult.OK)
            {
                enableSSL = true;
                Console.WriteLine("SSL Enabled");
            }
            else
            {
                Console.WriteLine("SSL NOT Enabled");
            }

            MessageBoxResult cipherKeyView = MessageBox.Show("Do you want enter cipher key for encryption feature?", "Settings", MessageBoxButton.OKCancel);
            if (cipherKeyView == MessageBoxResult.OK)
            {
                PublishMessageDialog view = new PublishMessageDialog();

                view.Show();

                view.Closed += (obj, args) =>
                {
                    if (view.DialogResult == true)
                    {
                        cipheryKey = view.Message.Text;
                        Console.WriteLine("Cipher key provided.");
                    }
                };
            }
            else
            {
                Console.WriteLine("No Cipher key provided.");
                cipheryKey = string.Empty;
            }

            pubnub = new Pubnub("demo", "demo", "", cipheryKey, enableSSL);

        }

        private void Subscribe_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running subscribe()");
            pubnub.subscribe<string>(channel, DisplayReturnMessage);
        }

        private void Publish_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running publish()");

            PublishMessageDialog view = new PublishMessageDialog();

            view.Show();

            view.Closed += (obj, args) => 
            {
                if (view.DialogResult == true)
                {
                    string publishMsg = view.Message.Text;
                    pubnub.publish<string>(channel, publishMsg, DisplayReturnMessage);
                }
            };
        }

        private void Presence_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running presence()");
            pubnub.presence<string>(channel, DisplayReturnMessage);
        }

        private void History_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running detailed history()");
            pubnub.detailedHistory<string>(channel, 100, DisplayReturnMessage);
        }

        private void HereNow_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running Here_Now()");
            pubnub.here_now<string>(channel, DisplayReturnMessage);
        }

        private void Unsubscribe_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running unsubscribe()");
            pubnub.unsubscribe<string>(channel, DisplayReturnMessage);
        }

        private void PresenceUnsubscrib_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running presence-unsubscribe()");
            pubnub.presence_unsubscribe<string>(channel, DisplayReturnMessage);
        }

        private void Time_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running time()");
            pubnub.time<string>(DisplayReturnMessage);
        }






        static void DisplayReturnMessage(string result)
        {
            Console.WriteLine(result);
        }

        static void DisplayReturnMessage(object result)
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
                Console.WriteLine("unable to parse data");
            }
        }

        static void ParseObject(object result, int loop)
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
                                Console.WriteLine(item.ToString());
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
                        Console.WriteLine("");
                    }
                }
            }
            else if (result.GetType().IsGenericType && (result.GetType().Name == typeof(Dictionary<,>).Name))
            {
                Dictionary<string, object> itemList = (Dictionary<string, object>)result;
                foreach (KeyValuePair<string, object> pair in itemList)
                {
                    Console.WriteLine(string.Format("key = {0}", pair.Key));
                    if (pair.Value is object[])
                    {
                        Console.WriteLine("value = ");
                        ParseObject(pair.Value, loop);
                    }
                    else
                    {
                        Console.WriteLine(string.Format("value = {0}", pair.Value));
                    }
                }
            }
            else
            {
                Console.WriteLine(result.ToString());
            }

        }
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
