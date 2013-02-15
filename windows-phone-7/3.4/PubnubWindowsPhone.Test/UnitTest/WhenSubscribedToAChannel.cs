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
        ManualResetEvent meAlreadySubscribed = new ManualResetEvent(false);
        ManualResetEvent meChannel1SubscribeConnect = new ManualResetEvent(false);
        ManualResetEvent meChannel2SubscribeConnect = new ManualResetEvent(false);
        ManualResetEvent meSubscriberManyMessages = new ManualResetEvent(false);

        bool receivedMessage = false;
        bool receivedConnectMessage = false;
        bool receivedAlreadySubscribedMessage = false;
        bool receivedChannel1ConnectMessage = false;
        bool receivedChannel2ConnectMessage = false;
        bool receivedManyMessages = false;

        int numberOfReceivedMessages = 0;

        [TestMethod, Asynchronous]
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

                    pubnub.Subscribe<string>(channel, ReceivedMessageCallbackWhenSubscribed, SubscribeDummyMethodForConnectCallback);
                    //Thread.Sleep(500);
                    pubnub.Publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
                    mePublish.WaitOne(310 * 1000);
                    //Thread.Sleep(500);
                    meSubscribeNoConnect.WaitOne(310 * 1000);
                    pubnub.Unsubscribe<string>(channel, dummyUnsubscribeCallback, SubscribeDummyMethodForConnectCallback, UnsubscribeDummyMethodForDisconnectCallback);
                    Thread.Sleep(500);
                    meUnsubscribe.WaitOne(310 * 1000);

                    Thread.Sleep(1000);
                    pubnub.EndPendingRequests();
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

                    pubnub.EndPendingRequests();
                    Thread.Sleep(200);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedConnectMessage, "WhenSubscribedToAChannel --> ThenSubscribeShouldReturnConnectStatus Failed");
                            TestComplete();
                        });
                });
        }

        [TestMethod, Asynchronous]
        public void ThenMultiSubscribeShouldReturnConnectStatus()
        {
            receivedChannel1ConnectMessage = false;
            receivedChannel2ConnectMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenSubscribedToAChannel";
                    unitTest.TestCaseName = "ThenMultiSubscribeShouldReturnConnectStatus";

                    pubnub.PubnubUnitTest = unitTest;


                    string channel1 = "my/channel1";
                    pubnub.Subscribe<string>(channel1, ReceivedChannelUserCallback, ReceivedChannel1ConnectCallback);
                    meChannel1SubscribeConnect.WaitOne(310 * 1000);

                    string channel2 = "my/channel2";
                    pubnub.Subscribe<string>(channel2, ReceivedChannelUserCallback, ReceivedChannel2ConnectCallback);
                    meChannel2SubscribeConnect.WaitOne(310 * 1000);

                    Thread.Sleep(500);

                    pubnub.EndPendingRequests();

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedChannel1ConnectMessage && receivedChannel2ConnectMessage, "WhenSubscribedToAChannel --> ThenSubscribeShouldReturnConnectStatus Failed");
                            TestComplete();
                        });
                });
        }

        [TestMethod, Asynchronous]
        public void ThenDuplicateChannelShouldReturnAlreadySubscribed()
        {
            receivedAlreadySubscribedMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenSubscribedToAChannel";
                    unitTest.TestCaseName = "ThenDuplicateChannelShouldReturnAlreadySubscribed";

                    pubnub.PubnubUnitTest = unitTest;

                    string channel = "my/channel";

                    pubnub.Subscribe<string>(channel, DummyMethodDuplicateChannelUserCallback1, DummyMethodDuplicateChannelConnectCallback);
                    Thread.Sleep(100);

                    pubnub.Subscribe<string>(channel, DummyMethodDuplicateChannelUserCallback2, DummyMethodDuplicateChannelConnectCallback);
                    meAlreadySubscribed.WaitOne();

                    pubnub.EndPendingRequests();

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedAlreadySubscribedMessage, "WhenSubscribedToAChannel --> ThenDuplicateChannelShouldReturnAlreadySubscribed Failed");
                            TestComplete();
                        });
                });
        }

        [TestMethod, Asynchronous]
        public void ThenSubscriberShouldBeAbleToReceiveManyMessages()
        {
            receivedManyMessages = false;

            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenSubscribedToAChannel";
                    unitTest.TestCaseName = "ThenSubscriberShouldBeAbleToReceiveManyMessages";
                    pubnub.PubnubUnitTest = unitTest;

                    string channel = "my/channel";

                    pubnub.Subscribe<string>(channel, SubscriberDummyMethodForManyMessagesUserCallback, SubscribeDummyMethodForManyMessagesConnectCallback);
                    Thread.Sleep(1000);
                    meSubscriberManyMessages.WaitOne();

                    pubnub.EndPendingRequests();

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedManyMessages, "WhenSubscribedToAChannel --> ThenSubscriberShouldBeAbleToReceiveManyMessages Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        private void SubscriberDummyMethodForManyMessagesUserCallback(string result)
        {
            numberOfReceivedMessages = numberOfReceivedMessages + 1;
            if (numberOfReceivedMessages >= 10)
            {
                receivedManyMessages = true;
                meSubscriberManyMessages.Set();
            }
        }

        [Asynchronous]
        private void SubscribeDummyMethodForManyMessagesConnectCallback(string result)
        {
        }

        [Asynchronous]
        private void ReceivedChannelUserCallback(string result)
        {
        }

        [Asynchronous]
        private void ReceivedChannel1ConnectCallback(string result)
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
                        receivedChannel1ConnectMessage = true;
                    }
                }
            }
            meChannel1SubscribeConnect.Set();
        }

        [Asynchronous]
        private void ReceivedChannel2ConnectCallback(string result)
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
                        receivedChannel2ConnectMessage = true;
                    }
                }
            }
            meChannel2SubscribeConnect.Set();
        }

        [Asynchronous]
        private void DummyMethodDuplicateChannelUserCallback1(string result)
        {
        }

        [Asynchronous]
        private void DummyMethodDuplicateChannelUserCallback2(string result)
        {
            if (result.Contains("already subscribed"))
            {
                receivedAlreadySubscribedMessage = true;
            }
            meAlreadySubscribed.Set();
        }

        [Asynchronous]
        private void DummyMethodDuplicateChannelConnectCallback(string result)
        {
        }

        [Asynchronous]
        private void ReceivedMessageCallbackWhenSubscribed(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    object subscribedObject = (object)deserializedMessage[0];
                    if (subscribedObject != null)
                    {
                        receivedMessage = true;
                    }
                }
            }
            meSubscribeNoConnect.Set();
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
        private void dummyPublishCallback(string result)
        {
            mePublish.Set();
        }

        [Asynchronous]
        private void dummyUnsubscribeCallback(string result)
        {

        }

        [Asynchronous]
        void SubscribeDummyMethodForConnectCallback(string receivedMessage)
        {
        }

        [Asynchronous]
        void UnsubscribeDummyMethodForDisconnectCallback(string receivedMessage)
        {
            meUnsubscribe.Set();
        }
    
    }
}
