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
        ManualResetEvent meSubscribeNoConnect = new ManualResetEvent(false);
        ManualResetEvent meSubscribeYesConnect = new ManualResetEvent(false);
        ManualResetEvent mePublish = new ManualResetEvent(false);
        ManualResetEvent meUnsubscribe = new ManualResetEvent(false);

        bool receivedMessage = false;
        bool receivedConnectMessage = false;

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

            pubnub.Publish<string>(channel, "Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage", dummyPublishCallback);
            mePublish.WaitOne(310 * 1000);

            meSubscribeNoConnect.WaitOne(310 * 1000);
            pubnub.Unsubscribe<string>(channel, dummyUnsubscribeCallback);
            
            meUnsubscribe.WaitOne(310 * 1000);
            Assert.IsTrue(receivedMessage,"WhenSubscribedToAChannel --> ThenItShouldReturnReceivedMessage Failed");
        }

        [Test]
        public void ThenSubscribeShouldReturnConnectStatus()
        {
            receivedConnectMessage = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenSubscribedToAChannel";
            unitTest.TestCaseName = "ThenSubscribeShouldReturnConnectStatus";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";

            pubnub.Subscribe<string>(channel, ReceivedMessageCallbackYesConnect, ConnectStatusCallback);
            meSubscribeYesConnect.WaitOne(310 * 1000);

            pubnub.Unsubscribe<string>(channel, dummyUnsubscribeCallback);
            meUnsubscribe.WaitOne(310 * 1000);

            Assert.IsTrue(receivedConnectMessage, "WhenSubscribedToAChannel --> ThenSubscribeShouldReturnConnectStatus Failed");
        }

        private void ReceivedMessageCallbackNoConnect(string result)
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

        private void ReceivedMessageCallbackYesConnect(string result)
        {
            //dummy method provided as part of subscribe connect status check.
        }

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

        private void dummyPublishCallback(string result)
        {
            mePublish.Set();
        }

        private void dummyUnsubscribeCallback(string result)
        {
            meUnsubscribe.Set();
        }
    }
}
