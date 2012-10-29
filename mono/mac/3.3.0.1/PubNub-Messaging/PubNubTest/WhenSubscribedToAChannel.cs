using System;
using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Collections;

namespace PubNubTest
{
    [TestFixture]
    public class WhenSubscribedToAChannel
    {
        [Test]
        public void ThenItShouldReturnReceivedMessage ()
        {
            string status = "";
            Pubnub pubnub = new Pubnub (
                   "demo",
                   "demo",
                   "",
                   "",
                   false);
            string channel = "hello_world";

            Common.deliveryStatus = false;

            pubnub.subscribe (channel, Common.DisplayReturnMessage); 

            while (!Common.deliveryStatus);

            string strResponse = "";
            Console.WriteLine (Common.objResponse);
            if (Common.objResponse.Equals (null)) {
                Assert.Fail("Null response");
            } else {
                IList<object> fields = Common.objResponse as IList<object>;

                foreach (object lst in fields) {
                    strResponse = lst.ToString ();
                    Console.WriteLine (strResponse);
                    Assert.IsNotEmpty (strResponse);
                }
            }
        }
    }
}

