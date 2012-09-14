using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Diagnostics;

namespace PubnubSilver
{
    public class Receiver : Callback
    {
        public bool responseCallback(string channel, object message)
            {
                object[] messages = (object[])message;
                //UIThread.Invoke(() =>
                //{
                    if (messages != null && messages.Length> 0)
                    {
                        //pt.subMessage.Visibility = Visibility.Visible;
                        for (int i = 0; i < messages.Length; i++)
                        {
                            Debug.WriteLine("[Subscribed data] " + messages[i]);
                            //if (!(pt.lSubscribe.Items.Contains(messages[i].ToString())))
                            //{
                            //    pt.lSubscribe.Items.Add(messages[i].ToString());
                            //}
                        }
                    }
                //});
                    return true;
            }

        public void errorCallback(string channel, object message)
        {
            Debug.WriteLine("Channel:" + channel + "-" + message.ToString());
        }

        public void connectCallback(string channel)
        {
            Debug.WriteLine("Connected to channel :" + channel);
        }

        public void reconnectCallback(string channel)
        {
            Debug.WriteLine("Reconnecting to channel :" + channel);
        }

        public void disconnectCallback(string channel)
        {
            Debug.WriteLine("Disconnected to channel :" + channel);
        }
    }

}
