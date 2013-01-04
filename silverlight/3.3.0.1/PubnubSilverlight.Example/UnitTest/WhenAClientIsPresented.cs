using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubnubSilverlight.Core;
using Microsoft.Silverlight.Testing;


namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenAClientIsPresented : SilverlightTest
    {
        static bool receivedFlag1 = false;
        static bool receivedFlag2 = false;

        bool isPresenceReturnMessage = false;
        bool isSubscribed = false;
        bool isUnSubscribed = false;
        bool isHereNowReturnMessage = false;

        [TestMethod]
        [Asynchronous]
        public void ThenPresenceShouldReturnReceivedMessage()
        {
            receivedFlag1 = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            EnqueueCallback(() => pubnub.presence<string>(channel, ThenPresenceShouldReturnMessage));
            EnqueueCallback(() => pubnub.subscribe<string>(channel, DummyMethodForSubscribe));
            EnqueueConditional(() => isSubscribed);
            EnqueueCallback(() => pubnub.unsubscribe<string>(channel, DummyMethodForUnSubscribe));
            EnqueueConditional(() => isUnSubscribed);
            EnqueueConditional(() => isPresenceReturnMessage);
            EnqueueCallback(() => Assert.IsTrue(receivedFlag1, "Presence message not received"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ThenPresenceShouldReturnMessage(string receivedMessage)
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

            isPresenceReturnMessage = true;
        }



        [TestMethod]
        [Asynchronous]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            EnqueueCallback(() => pubnub.here_now<string>(channel, ThenHereNowShouldReturnMessage));
            EnqueueConditional(() => isHereNowReturnMessage);
            EnqueueCallback(() => Assert.IsTrue(receivedFlag2, "here_now message not received"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ThenHereNowShouldReturnMessage(string receivedMessage)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(receivedMessage))
                {
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    IList receivedObj = (IList)js.DeserializeObject(receivedMessage);
                    var dic = ((IDictionary<string, object>)receivedObj[0])["uuids"];
                    if (dic != null)
                    {
                        receivedFlag2 = true;
                    }
                }
            }
            catch { }

            isHereNowReturnMessage = true;
        }

        [Asynchronous]
        public void DummyMethodForSubscribe(string receivedMessage)
        {
            isSubscribed = true;
            //Dummary callback method for subscribe and unsubscribe to test presence
        }

        [Asynchronous]
        public void DummyMethodForUnSubscribe(string receivedMessage)
        {
            isUnSubscribed = true;
            //Dummary callback method for unsubscribe to test presence
        }
    }
}
