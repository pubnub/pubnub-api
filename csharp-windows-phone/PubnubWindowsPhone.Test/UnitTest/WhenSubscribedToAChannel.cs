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

using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Phone.Testing;
using PubNub_Messaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Collections.Generic;


namespace PubnubWindowsPhone.Test.UnitTest
{
    [TestClass]
    public class WhenSubscribedToAChannel : WorkItemTest
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);

        bool receivedMessage = false;

        [TestMethod,Asynchronous]
        public void ThenSubscribeShouldReturnReceivedMessage()
        {
            receivedMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    string channel = "my/channel";

                    pubnub.subscribe<string>(channel, ReceivedMessageCallback);
                    Thread.Sleep(5000);

                    pubnub.publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
                    manualEvent2.WaitOne(310 * 1000);

                    manualEvent1.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedMessage, "WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        private void ReceivedMessageCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    object subscribedObj = (object)receivedObj[0];
                    if (subscribedObj != null)
                    {
                        receivedMessage = true;
                    }
                }
            }
            manualEvent1.Set();
        }

        [Asynchronous]
        private void dummyPublishCallback(string result)
        {
            manualEvent2.Set();
        }

    }
}
