using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenAClientIsPresented
    {
        ManualResetEvent manualEvent = new ManualResetEvent(false);
        static bool receivedFlag = false;

        [TestMethod]
        public void ThenItShouldReturnReceivedMessage()
        {
            receivedFlag = false;

            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            pubnub.presence<string>(channel, ThenItShouldReturnPresenceMessage);

            //since presence expects from stimulus from sub/unsub...
            pubnub.subscribe<string>(channel, DummyMethodForSubscribe);
            pubnub.unsubscribe<string>(channel, DummyMethodForSubscribe);
            
            manualEvent.WaitOne();
            Assert.IsTrue(receivedFlag, "Presence message not received");
        }

        void ThenItShouldReturnPresenceMessage(string receivedMessage)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(receivedMessage))
                {
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    IList receivedObj = (IList)js.DeserializeObject(receivedMessage);
                    var dic = (IDictionary<string, object>)((object[])receivedObj[0])[0];
                    var uuid = dic["uuid"].ToString();
                    if (uuid != null)
                    {
                        receivedFlag = true;
                    }
                }
            }
            catch { }
            finally
            {
                manualEvent.Set();
            }
        }

        [TestMethod]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            receivedFlag = false;

            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            pubnub.here_now<string>(channel, ThenItShouldReturnHereNowkMessage);
            manualEvent.WaitOne();
            Assert.IsTrue(receivedFlag, "here_now message not received");
        }

        void ThenItShouldReturnHereNowkMessage(string receivedMessage)
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
                        receivedFlag = true;
                    }
                }
            }
            catch { }
            finally
            {
                manualEvent.Set();
            }
        }

        void DummyMethodForSubscribe(string receivedMessage)
        {
        }

    }
}
