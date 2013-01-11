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

        ManualResetEvent hereNowManualEvent = new ManualResetEvent(false);
        ManualResetEvent presenceUnsubscribeEvent = new ManualResetEvent(false);

        static bool receivedPresenceMessage = false;
        static bool receivedHereNowMessage = false;

        [TestMethod,Asynchronous]
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

                    pubnub.Presence<string>(channel, ThenPresenceShouldReturnMessage);

                    //since presence expects from stimulus from sub/unsub...
                    pubnub.Subscribe<string>(channel, DummyMethodForSubscribe);
                    subscribeManualEvent.WaitOne(2000);

                    pubnub.Unsubscribe<string>(channel, DummyMethodForUnSubscribe);
                    unsubscribeManualEvent.WaitOne(2000);

                    pubnub.PresenceUnsubscribe<string>(channel, DummyMethodForPreUnSub);
                    presenceUnsubscribeEvent.WaitOne(2000);

                    presenceManualEvent.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(receivedPresenceMessage, "Presence message not received");
                           TestComplete();
                       });
                });
        }

        [Asynchronous]
        void ThenPresenceShouldReturnMessage(string receivedMessage)
        {
            try
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
            }
            catch { }
            finally
            {
                presenceManualEvent.Set();
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
            subscribeManualEvent.Set();
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForUnSubscribe(string receivedMessage)
        {
            unsubscribeManualEvent.Set();
            //Dummary callback method for unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForPreUnSub(string receivedMessage)
        {
            presenceUnsubscribeEvent.Set();
        }
    }
}
