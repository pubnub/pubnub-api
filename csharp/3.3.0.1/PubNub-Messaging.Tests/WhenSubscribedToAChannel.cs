using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;

namespace PubNubMessaging.Tests
{
    [TestFixture]
    public class WhenSubscribedToAChannel
    {
        ManualResetEvent meSubNoConnect = new ManualResetEvent(false);
        ManualResetEvent meSubYesConnect = new ManualResetEvent(false);
        ManualResetEvent mePublish = new ManualResetEvent(false);
        ManualResetEvent meUnsub = new ManualResetEvent(false);


        bool receivedMessage = false;

        [Test]
        public void ThenSubscribeShouldReturnReceivedMessage()
        {
            receivedMessage = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenSubscribedToAChannel";
            unitTest.TestCaseName = "ThenSubscribeShouldReturnReceivedMessage";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";

            pubnub.Subscribe<string>(channel, ReceivedMessageCallbackNoConnect);
            //Thread.Sleep(5000);

            pubnub.Publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
            mePublish.WaitOne(310 * 1000);

            meSubNoConnect.WaitOne(310 * 1000);
            pubnub.Unsubscribe<string>(channel, dummyUnsubCallback);
            
            meUnsub.WaitOne(310 * 1000);
            Assert.IsTrue(receivedMessage,"WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed");
        }

        [Test]
        public void ThenSubscribeShouldReturnConnectStatus()
        {
            receivedMessage = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenSubscribedToAChannel";
            unitTest.TestCaseName = "ThenSubscribeShouldReturnConnectStatus";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";

            pubnub.Subscribe<string>(channel, ReceivedMessageCallbackYesConnect, ConnectStatusCallback);
            meSubYesConnect.WaitOne(310 * 1000);

            pubnub.Unsubscribe<string>(channel, dummyUnsubCallback);
            meUnsub.WaitOne(310 * 1000);

            Assert.IsTrue(receivedMessage, "WhenSubscribedToAChannel --> ThenSubscribeShouldReturnConnectStatus Failed");
        }

        private void ReceivedMessageCallbackNoConnect(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
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
            meSubNoConnect.Set();
        }

        private void ReceivedMessageCallbackYesConnect(string result)
        {
            //dummy method provided as part of subscribe connect status check.
        }

        private void ConnectStatusCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "connected")
                    {
                        receivedMessage = true;
                    }
                }
            }
            meSubYesConnect.Set();
        }

        private void dummyPublishCallback(string result)
        {
            mePublish.Set();
        }

        private void dummyUnsubCallback(string result)
        {
            meUnsub.Set();
        }
    }
}
