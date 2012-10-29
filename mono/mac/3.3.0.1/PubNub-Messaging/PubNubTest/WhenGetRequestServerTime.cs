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
            
            bool responseStatus = false;

            string strResponse = "";
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e) {
                if (e.PropertyName == "Time") {
                    strResponse = ((Pubnub)sender).Time[0].ToString();

                    responseStatus = true;
                }
            };

            pubnub.time();
            while (!responseStatus);

            Console.WriteLine (strResponse);
            Assert.AreNotEqual("0",strResponse);
        }

    }
}

