using System;
using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;

namespace PubNubTest
{
    [TestFixture]
    public class WhenAClientIsPresented
    {
        [Test]
        public void ThenItShouldReturnReceivedMessage()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";

            Common.deliveryStatus = false;

            pubnub.presence(channel, Common.DisplayReturnMessage);
            while (!Common.deliveryStatus) ;

            string strResponse = "";
            if (Common.objResponse.Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
                IList<object> fields = Common.objResponse as IList<object>;
                foreach (object item in fields)
                {
                    strResponse = item.ToString();
                    Console.WriteLine(strResponse);
                    //Assert.IsNotEmpty(strResponse);
                }
                Assert.AreEqual("hello_world", fields[2]);
            }
        }

        [Test]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            Pubnub pubnub = new Pubnub(
               "demo",
               "demo",
               "",
               "",
               false
           );
            string channel = "hello_world";

            Common.deliveryStatus = false;

            pubnub.here_now(channel, Common.DisplayReturnMessage);
            while (!Common.deliveryStatus) ;

            string strResponse = "";
            if (Common.objResponse.Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
                IList<object> fields = Common.objResponse as IList<object>;
                foreach(object lst in fields)
                {
                    strResponse = lst.ToString();
                    Console.WriteLine(strResponse);
                    Assert.IsNotEmpty(strResponse);
                }
                Dictionary<string, object> message = (Dictionary<string, object>)fields[0];
                foreach(KeyValuePair<String, object> entry in message)
                {
                    Console.WriteLine("value:" + entry.Value + "  " + "key:" + entry.Key);
                }

                /*object[] objUuid = (object[])message["uuids"];
                foreach (object obj in objUuid)
                {
                    Console.WriteLine(obj.ToString()); 
                }*/
                //Assert.AreNotEqual(0, message["occupancy"]);
            }

        }
    }
}

