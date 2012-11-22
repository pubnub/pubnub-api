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


namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenAClientIsPresented
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);
        ManualResetEvent manualEvent3 = new ManualResetEvent(false);

        ManualResetEvent manualEvent4 = new ManualResetEvent(false);

        static bool receivedFlag1 = false;
        static bool receivedFlag2 = false;

        [TestMethod]
        public void ThenPresenceShouldReturnReceivedMessage()
        {
            receivedFlag1 = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            pubnub.presence<string>(channel, ThenPresenceShouldReturnMessage);

            //since presence expects from stimulus from sub/unsub...
            pubnub.subscribe<string>(channel, DummyMethodForSubscribe);
            manualEvent1.WaitOne(2000);

            pubnub.unsubscribe<string>(channel, DummyMethodForUnSubscribe);
            manualEvent3.WaitOne(2000);

            manualEvent2.WaitOne(310 * 1000);
            Assert.IsTrue(receivedFlag1, "Presence message not received");
        }

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



        [TestMethod]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            receivedFlag2 = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";
            pubnub.here_now<string>(channel, ThenHereNowShouldReturnMessage);
            manualEvent4.WaitOne();
            Assert.IsTrue(receivedFlag2, "here_now message not received");
        }

        void ThenHereNowShouldReturnMessage(string receivedMessage)
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
    }
}
