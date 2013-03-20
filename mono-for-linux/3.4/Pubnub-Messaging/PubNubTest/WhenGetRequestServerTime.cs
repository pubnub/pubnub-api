using System;
using PubNubMessaging.Core;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Threading;


namespace PubNubMessaging.Tests
{
    [TestFixture]
    public class WhenGetRequestServerTime
    {
        [Test]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "",
                "",
                false
            );

            Common common = new Common();
            common.DeliveryStatus = false;
            common.Response = null;

            pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenGetRequestServerTime", "ThenItShouldReturnTimeStamp");;
            
            string response = "";

            pubnub.Time(common.DisplayReturnMessage);
           
            while (!common.DeliveryStatus) ;

            IList<object> fields = common.Response as IList<object>;
            response = fields[0].ToString();
            Console.WriteLine("Response:" + response);
            Assert.AreNotEqual("0",response);
        }
    }
}

