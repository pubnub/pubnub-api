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
    public class WhenUnsubscribedToAChannel
    {
        ManualResetEvent meNotSubscribed = new ManualResetEvent(false);
        ManualResetEvent meChannelSubscribed = new ManualResetEvent(false);
        ManualResetEvent meChannelUnsubscribed = new ManualResetEvent(false);

        bool receivedNotSubscribedMessage = false;
        bool receivedUnsubscribedMessage = false;
        bool receivedChannelConnectedMessage = false;

        [Test]
        public void ThenNoExistChannelShouldReturnNotSubscribed()
        {
            receivedNotSubscribedMessage = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenUnsubscribedToAChannel";
            unitTest.TestCaseName = "ThenNoExistChannelShouldReturnNotSubscribed";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";

            pubnub.Unsubscribe<string>(channel, DummyMethodNoExistChannelUnsubscribeChannelUserCallback, DummyMethodNoExistChannelUnsubscribeChannelConnectCallback, DummyMethodNoExistChannelUnsubscribeChannelDisconnectCallback1);

            meNotSubscribed.WaitOne();

            pubnub.EndPendingRequests();

            Assert.IsTrue(receivedNotSubscribedMessage, "WhenUnsubscribedToAChannel --> ThenNoExistChannelShouldReturnNotSubscribed Failed");
        }

        [Test]
        public void ThenShouldReturnUnsubscribedMessage()
        {
            receivedChannelConnectedMessage = false;
            receivedUnsubscribedMessage = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenUnsubscribedToAChannel";
            unitTest.TestCaseName = "ThenShouldReturnUnsubscribedMessage";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";

            pubnub.Subscribe<string>(channel, DummyMethodChannelSubscribeUserCallback, DummyMethodChannelSubscribeConnectCallback);
            meChannelSubscribed.WaitOne();

            if (receivedChannelConnectedMessage)
            {
                pubnub.Unsubscribe<string>(channel, DummyMethodUnsubscribeChannelUserCallback, DummyMethodUnsubscribeChannelConnectCallback, DummyMethodUnsubscribeChannelDisconnectCallback);
                meChannelUnsubscribed.WaitOne();
            }

            pubnub.EndPendingRequests();

            Assert.IsTrue(receivedUnsubscribedMessage, "WhenUnsubscribedToAChannel --> ThenShouldReturnUnsubscribedMessage Failed");
        }

        private void DummyMethodChannelSubscribeUserCallback(string result)
        {
        }

        private void DummyMethodChannelSubscribeConnectCallback(string result)
        {
            if (result.Contains("Connected"))
            {
                receivedChannelConnectedMessage = true;
            }
            meChannelSubscribed.Set();
        }

        private void DummyMethodUnsubscribeChannelUserCallback(string result)
        {
        }

        private void DummyMethodUnsubscribeChannelConnectCallback(string result)
        {
        }

        private void DummyMethodUnsubscribeChannelDisconnectCallback(string result)
        {
            if (result.Contains("Unsubscribed from"))
            {
                receivedUnsubscribedMessage = true;
            }
            meChannelUnsubscribed.Set();
        }

        private void DummyMethodNoExistChannelUnsubscribeChannelUserCallback(string result)
        {
            if (result.Contains("not subscribed"))
            {
                receivedNotSubscribedMessage = true;
            }
            meNotSubscribed.Set();
        }

        private void DummyMethodNoExistChannelUnsubscribeChannelConnectCallback(string result)
        {
        }

        private void DummyMethodNoExistChannelUnsubscribeChannelDisconnectCallback1(string result)
        {
        }

    }
}
