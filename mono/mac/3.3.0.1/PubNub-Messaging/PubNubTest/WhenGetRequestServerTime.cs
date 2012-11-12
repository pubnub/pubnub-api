using System;
using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;


namespace PubNubTest
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
            
            string strResponse = "";
            Common.deliveryStatus = false;

            pubnub.time(Common.DisplayReturnMessage);
            while (!Common.deliveryStatus) ;

            IList<object> fields = Common.objResponse as IList<object>;
            strResponse = fields[0].ToString();
            Console.WriteLine(strResponse);
            Assert.AreNotEqual("0",strResponse);
        }

    }
}

