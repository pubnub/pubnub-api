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
using PubnubSilverlight.Example.Dialogs;

namespace PubnubSilverlight.Example.Views
{
    public partial class CodeExampleView : Page
    {

        #region "Properties and Members"

        static public Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
        static public bool deliveryStatus = false;
        static public string channel = "my_channel";
        static public string message = "Pubnub API Usage Example - Publish";
       
        #endregion

        public CodeExampleView()
        {
            InitializeComponent();

            Console.Container = ConsoleContainer;
        }

        private void Subscribe_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running subscribe()");
            pubnub.subscribe(channel, DisplayReturnMessage);
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
                    pubnub.publish(channel, publishMsg, DisplayReturnMessage);
                }
            };
        }

        private void Presence_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running presence()");
            pubnub.presence(channel, DisplayReturnMessage);
        }

        private void History_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running detailed history()");
            pubnub.detailedHistory(channel, 100, DisplayReturnMessage);
        }

        private void HereNow_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running Here_Now()");
            pubnub.here_now(channel, DisplayReturnMessage);
        }

        private void Unsubscribe_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running unsubscribe()");
            pubnub.unsubscribe(channel, DisplayReturnMessage);
        }

        private void PresenceUnsubscrib_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running presence-unsubscribe()");
            pubnub.presence_unsubscribe(channel, DisplayReturnMessage);
        }

        private void Time_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Running time()");
            pubnub.time(DisplayReturnMessage);
        }


    




        private static void DisplayReturnMessage(object result)
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

        private static void ParseObject(object result, int loop)
        {
            if (result is object[])
            {
                object[] arrResult = (object[])result;
                foreach (object item in arrResult)
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

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            TextBox chanelTextBox = sender as TextBox;
            channel = chanelTextBox.Text;
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
