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
    public class WhenAClientIsPresented : WorkItemTest
    {
        ManualResetEvent subscribeManualEvent = new ManualResetEvent(false);
        ManualResetEvent presenceManualEvent = new ManualResetEvent(false);
        ManualResetEvent unsubscribeManualEvent = new ManualResetEvent(false);

        ManualResetEvent subscribeUUIDManualEvent = new ManualResetEvent(false);
        ManualResetEvent presenceUUIDManualEvent = new ManualResetEvent(false);
        ManualResetEvent unsubscribeUUIDManualEvent = new ManualResetEvent(false);

        ManualResetEvent hereNowManualEvent = new ManualResetEvent(false);
        ManualResetEvent presenceUnsubscribeEvent = new ManualResetEvent(false);
        ManualResetEvent presenceUnsubscribeUUIDEvent = new ManualResetEvent(false);

        static bool receivedPresenceMessage = false;
        static bool receivedHereNowMessage = false;
        static bool receivedCustomUUID = false;

        string customUUID = "mylocalmachine.mydomain.com";

        [TestMethod, Asynchronous]
        public void ThenPresenceShouldReturnReceivedMessage()
        {
            receivedPresenceMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAClientIsPresented";
                    unitTest.TestCaseName = "ThenPresenceShouldReturnReceivedMessage";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Presence<string>(channel, ThenPresenceShouldReturnMessage, PresenceDummyMethodForConnectCallback);
                    Thread.Sleep(1000);

                    //since presence expects from stimulus from sub/unsub...
                    pubnub.Subscribe<string>(channel, DummyMethodForSubscribe, SubscribeDummyMethodForConnectCallback);
                    Thread.Sleep(1000);
                    subscribeManualEvent.WaitOne(2000);

                    pubnub.Unsubscribe<string>(channel, DummyMethodForUnSubscribe, UnsubscribeDummyMethodForConnectCallback, UnsubscribeDummyMethodForDisconnectCallback);
                    Thread.Sleep(1000);
                    unsubscribeManualEvent.WaitOne(2000);

                    presenceManualEvent.WaitOne(310 * 1000);

                    pubnub.EndPendingRequests();

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(receivedPresenceMessage, "Presence message not received");
                           TestComplete();
                       });
                });
        }

        [TestMethod, Asynchronous]
        public void ThenPresenceShouldReturnCustomUUID()
        {
            receivedCustomUUID = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAClientIsPresented";
                    unitTest.TestCaseName = "ThenPresenceShouldReturnCustomUUID";
                    pubnub.PubnubUnitTest = unitTest;

                    string channel = "my/channel";

                    pubnub.Presence<string>(channel, ThenPresenceWithCustomUUIDShouldReturnMessage, PresenceUUIDDummyMethodForConnectCallback);
                    Thread.Sleep(1000);

                    //since presence expects from stimulus from sub/unsub...
                    pubnub.SessionUUID = customUUID;
                    pubnub.Subscribe<string>(channel, DummyMethodForSubscribeUUID, SubscribeUUIDDummyMethodForConnectCallback);
                    subscribeUUIDManualEvent.WaitOne();
                    Thread.Sleep(1000);

                    pubnub.Unsubscribe<string>(channel, DummyMethodForUnSubscribeUUID, UnsubscribeUUIDDummyMethodForConnectCallback, UnsubscribeUUIDDummyMethodForDisconnectCallback);
                    Thread.Sleep(1000);
                    unsubscribeUUIDManualEvent.WaitOne(2000);

                    presenceUUIDManualEvent.WaitOne();
                    Thread.Sleep(1000);
                    pubnub.EndPendingRequests();

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(receivedCustomUUID, "Custom UUID not received");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        void ThenPresenceShouldReturnMessage(string receivedMessage)
        {
            try
            {
                Deployment.Current.Dispatcher.BeginInvoke(() =>
                    {
                        if (!string.IsNullOrWhiteSpace(receivedMessage))
                        {
                            object[] serializedMessage = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                            JContainer dictionary = serializedMessage[0] as JContainer;
                            var uuid = dictionary["uuid"].ToString();
                            if (uuid != null)
                            {
                                receivedPresenceMessage = true;
                            }
                        }
                    });
            }
            catch { }
            finally
            {
                presenceManualEvent.Set();
            }
        }

        [Asynchronous]
        void ThenPresenceWithCustomUUIDShouldReturnMessage(string receivedMessage)
        {
            try
            {
                Deployment.Current.Dispatcher.BeginInvoke(() =>
                    {
                        if (!string.IsNullOrEmpty(receivedMessage) && !string.IsNullOrEmpty(receivedMessage.Trim()))
                        {
                            object[] serializedMessage = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                            JContainer dictionary = serializedMessage[0] as JContainer;
                            var uuid = dictionary["uuid"].ToString();
                            if (uuid != null && uuid.Contains(customUUID))
                            {
                                receivedCustomUUID = true;
                            }
                        }
                    });
            }
            catch { }
            finally
            {
                presenceUUIDManualEvent.Set();
            }
        }

        [TestMethod,Asynchronous]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            receivedHereNowMessage = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAClientIsPresented";
                    unitTest.TestCaseName = "IfHereNowIsCalledThenItShouldReturnInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.HereNow<string>(channel, ThenHereNowShouldReturnMessage);
                    hereNowManualEvent.WaitOne();
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(receivedHereNowMessage, "here_now message not received");
                           TestComplete();
                       });
                });
        }

        [Asynchronous]
        void ThenHereNowShouldReturnMessage(string receivedMessage)
        {
            try
            {
                Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           if (!string.IsNullOrWhiteSpace(receivedMessage))
                           {
                               object[] serializedMessage = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                               var dictionary = ((JContainer)serializedMessage[0])["uuids"];
                               if (dictionary != null)
                               {
                                   receivedHereNowMessage = true;
                               }
                           }
                       });
            }
            catch { }
            finally
            {
                hereNowManualEvent.Set();
            }
        }

        [Asynchronous]
        void DummyMethodForSubscribe(string receivedMessage)
        {
            try
            {
                Deployment.Current.Dispatcher.BeginInvoke(() =>
                {
                    if (!string.IsNullOrWhiteSpace(receivedMessage))
                    {
                        object[] serializedMessage = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                        JContainer dictionary = serializedMessage[0] as JContainer;
                        var uuid = dictionary["uuid"].ToString();
                        if (uuid != null)
                        {
                            receivedPresenceMessage = true;
                        }
                    }
                });
            }
            catch { }
            finally
            {
                presenceManualEvent.Set();
            }
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForSubscribeUUID(string receivedMessage)
        {
            Deployment.Current.Dispatcher.BeginInvoke(() =>
            {
                if (!string.IsNullOrEmpty(receivedMessage) && !string.IsNullOrEmpty(receivedMessage.Trim()))
                {
                    object[] serializedMessage = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                    JContainer dictionary = serializedMessage[0] as JContainer;
                    if (dictionary != null)
                    {
                        var uuid = dictionary["uuid"].ToString();
                        if (uuid != null)
                        {
                            receivedCustomUUID = true;
                            presenceUUIDManualEvent.Set();
                        }
                    }
                }
            });
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForUnSubscribe(string receivedMessage)
        {
            //Dummary callback method for unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForUnSubscribeUUID(string receivedMessage)
        {
            //Dummary callback method for unsubscribe to test presence
        }

        [Asynchronous]
        void PresenceDummyMethodForConnectCallback(string receivedMessage)
        {
        }

        [Asynchronous]
        void PresenceUUIDDummyMethodForConnectCallback(string receivedMessage)
        {
        }

        [Asynchronous]
        void SubscribeDummyMethodForConnectCallback(string receivedMessage)
        {
            subscribeManualEvent.Set();
        }

        [Asynchronous]
        void SubscribeUUIDDummyMethodForConnectCallback(string receivedMessage)
        {
            subscribeUUIDManualEvent.Set();
        }

        [Asynchronous]
        void UnsubscribeDummyMethodForConnectCallback(string receivedMessage)
        {
        }

        [Asynchronous]
        void UnsubscribeUUIDDummyMethodForConnectCallback(string receivedMessage)
        {
        }

        [Asynchronous]
        void UnsubscribeDummyMethodForDisconnectCallback(string receivedMessage)
        {
            unsubscribeManualEvent.Set();
        }

        [Asynchronous]
        void UnsubscribeUUIDDummyMethodForDisconnectCallback(string receivedMessage)
        {
            unsubscribeUUIDManualEvent.Set();
        }
    }
}
