using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace PubNub_Messaging.Tests
{
    [TestFixture]
    public class WhenAClientIsPresented
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);
        ManualResetEvent manualEvent3 = new ManualResetEvent(false);

        ManualResetEvent manualEvent4 = new ManualResetEvent(false);
        ManualResetEvent preUnsubEvent = new ManualResetEvent(false);

        static bool receivedFlag1 = false;
        static bool receivedFlag2 = false;

        [Test]
        public void ThenPresenceShouldReturnReceivedMessage()
        {
            receivedFlag1 = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            
            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAClientIsPresented";
            unitTest.TestCaseName = "ThenPresenceShouldReturnReceivedMessage";
            pubnub.PubnubUnitTest = unitTest;
            
            string channel = "my/channel";

            pubnub.presence<string>(channel, ThenPresenceShouldReturnMessage);

            //since presence expects from stimulus from sub/unsub...
            pubnub.subscribe<string>(channel, DummyMethodForSubscribe);
            manualEvent1.WaitOne(2000);

            pubnub.unsubscribe<string>(channel, DummyMethodForUnSubscribe);
            manualEvent3.WaitOne(2000);

            manualEvent2.WaitOne(310 * 1000);

            pubnub.presence_unsubscribe<string>(channel, DummyMethodForPreUnSub);
            preUnsubEvent.WaitOne();
            
            Assert.IsTrue(receivedFlag1, "Presence message not received");
        }

        void ThenPresenceShouldReturnMessage(string receivedMessage)
        {
            try
            {
                if (!string.IsNullOrEmpty(receivedMessage) && !string.IsNullOrEmpty(receivedMessage.Trim()))
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



        [Test]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            receivedFlag2 = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAClientIsPresented";
            unitTest.TestCaseName = "IfHereNowIsCalledThenItShouldReturnInfo";
            pubnub.PubnubUnitTest = unitTest;
            string channel = "my/channel";
            pubnub.here_now<string>(channel, ThenHereNowShouldReturnMessage);
            manualEvent4.WaitOne();
            Assert.IsTrue(receivedFlag2, "here_now message not received");
        }

        void ThenHereNowShouldReturnMessage(string receivedMessage)
        {
            try
            {
                if (!string.IsNullOrEmpty(receivedMessage) && !string.IsNullOrEmpty(receivedMessage.Trim()))
                {
                    object[] receivedObj = JsonConvert.DeserializeObject<object[]>(receivedMessage);
                    var dic = ((JContainer)receivedObj[0])["uuids"];
                    if (dic != null)
                    {
                        receivedFlag2 = true;
                    }
                }
            }
            catch { }
            finally
            {
                manualEvent4.Set();
            }
        }

        void DummyMethodForSubscribe(string receivedMessage)
        {
            manualEvent1.Set();
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        void DummyMethodForUnSubscribe(string receivedMessage)
        {
            manualEvent3.Set();
            //Dummary callback method for unsubscribe to test presence
        }

        void DummyMethodForPreUnSub(string receivedMessage)
        {
            preUnsubEvent.Set();
        }
    }
}
