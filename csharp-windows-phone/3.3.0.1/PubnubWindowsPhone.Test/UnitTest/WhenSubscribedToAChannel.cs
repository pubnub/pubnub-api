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
using PubNubMessaging.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Collections.Generic;


namespace PubnubWindowsPhone.Test.UnitTest
{
    [TestClass]
    public class WhenSubscribedToAChannel : WorkItemTest
    {
        ManualResetEvent meSubscribeNoConnect = new ManualResetEvent(false);
        ManualResetEvent meSubscribeYesConnect = new ManualResetEvent(false);
        ManualResetEvent mePublish = new ManualResetEvent(false);
        ManualResetEvent meUnsubscribe = new ManualResetEvent(false);

        bool receivedMessage = false;
        bool receivedConnectMessage = false;

        [TestMethod,Asynchronous]
        public void ThenSubscribeShouldReturnReceivedMessage()
        {
            receivedMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    string channel = "my/channel";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenSubscribedToAChannel";
                    unitTest.TestCaseName = "ThenSubscribeShouldReturnReceivedMessage";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Subscribe<string>(channel, ReceivedMessageCallback);

                    pubnub.Publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
                    mePublish.WaitOne(310 * 1000);

                    meSubscribeNoConnect.WaitOne(310 * 1000);
                    
                    pubnub.Unsubscribe<string>(channel, dummyUnsubCallback);
                    meUnsubscribe.WaitOne(310 * 1000);
                    Thread.Sleep(100);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedMessage, "WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed");
                            TestComplete();
                        });
                });
        }

        [TestMethod, Asynchronous]
        public void ThenSubscribeShouldReturnConnectStatus()
        {
            receivedConnectMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenSubscribedToAChannel";
                    unitTest.TestCaseName = "ThenSubscribeShouldReturnConnectStatus";

                    pubnub.PubnubUnitTest = unitTest;

                    string channel = "my/channel";

                    pubnub.Subscribe<string>(channel, ReceivedMessageCallbackYesConnect, ConnectStatusCallback);
                    meSubscribeYesConnect.WaitOne(310 * 1000);
                    Thread.Sleep(200);

                    pubnub.Unsubscribe<string>(channel, dummyUnsubCallback);
                    meUnsubscribe.WaitOne(310 * 1000);
                    Thread.Sleep(200);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedConnectMessage, "WhenSubscribedToAChannel --> ThenSubscribeShouldReturnConnectStatus Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]  
        private void ReceivedMessageCallbackYesConnect(string result)
        {
            //dummy method provided as part of subscribe connect status check.
        }

        [Asynchronous]
        private void ConnectStatusCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "connected")
                    {
                        receivedConnectMessage = true;
                    }
                }
            }
            meSubscribeYesConnect.Set();
        }
        [Asynchronous]
        private void ReceivedMessageCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    object subscribedObj = (object)deserializedMessage[0];
                    if (subscribedObj != null)
                    {
                        receivedMessage = true;
                    }
                }
            }
            meSubscribeNoConnect.Set();
        }

        [Asynchronous]
        private void dummyPublishCallback(string result)
        {
            mePublish.Set();
        }

        [Asynchronous]
        private void dummyUnsubCallback(string result)
        {
            meUnsubscribe.Set();
        }
    }
}
