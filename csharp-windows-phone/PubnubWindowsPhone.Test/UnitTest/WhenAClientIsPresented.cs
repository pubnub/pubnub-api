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
    public class WhenAClientIsPresented : WorkItemTest
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);
        ManualResetEvent manualEvent3 = new ManualResetEvent(false);

        ManualResetEvent manualEvent4 = new ManualResetEvent(false);
        ManualResetEvent preUnsubEvent = new ManualResetEvent(false);

        static bool receivedFlag1 = false;
        static bool receivedFlag2 = false;

        [TestMethod,Asynchronous]
        public void ThenPresenceShouldReturnReceivedMessage()
        {
            receivedFlag1 = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAClientIsPresented";
                    unitTest.TestCaseName = "ThenPresenceShouldReturnReceivedMessage";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.presence<string>(channel, ThenPresenceShouldReturnMessage);

                    //since presence expects from stimulus from sub/unsub...
                    pubnub.subscribe<string>(channel, DummyMethodForSubscribe);
                    manualEvent1.WaitOne(2000);

                    pubnub.unsubscribe<string>(channel, DummyMethodForUnSubscribe);
                    manualEvent3.WaitOne(2000);

                    pubnub.presence_unsubscribe<string>(channel, DummyMethodForPreUnSub);
                    preUnsubEvent.WaitOne(2000);

                    manualEvent2.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(receivedFlag1, "Presence message not received");
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
                    object[] receivedObj = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                    JContainer dic = receivedObj[0] as JContainer;
                    var uuid = dic["uuid"].ToString();
                    if (uuid != null)
                    {
                        receivedFlag1 = true;
                    }
                }
            }
            catch { }
            finally
            {
                manualEvent2.Set();
            }
        }


        [TestMethod,Asynchronous]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            receivedFlag2 = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAClientIsPresented";
                    unitTest.TestCaseName = "IfHereNowIsCalledThenItShouldReturnInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.here_now<string>(channel, ThenHereNowShouldReturnMessage);
                    manualEvent4.WaitOne();
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(receivedFlag2, "here_now message not received");
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
                               object[] receivedObj = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                               var dic = ((JContainer)receivedObj[0])["uuids"];
                               if (dic != null)
                               {
                                   receivedFlag2 = true;
                               }
                           }
                       });
            }
            catch { }
            finally
            {
                manualEvent4.Set();
            }
        }

        [Asynchronous]
        void DummyMethodForSubscribe(string receivedMessage)
        {
            manualEvent1.Set();
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForUnSubscribe(string receivedMessage)
        {
            manualEvent3.Set();
            //Dummary callback method for unsubscribe to test presence
        }

        [Asynchronous]
        void DummyMethodForPreUnSub(string receivedMessage)
        {
            preUnsubEvent.Set();
        }
    }
}
