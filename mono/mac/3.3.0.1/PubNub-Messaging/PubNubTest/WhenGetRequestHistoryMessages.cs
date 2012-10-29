using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System;

namespace PubNubTest
{
    [TestFixture]
    public class WhenGetRequestHistoryMessages
    {

        [Test]
        public void ThenItShouldReturnHistoryMessages ()
        {
            Pubnub pubnub = new Pubnub (
                "demo",
                "demo",
                "",
                "",
                false
            );
            string channel = "hello_world";
            bool responseStatus = false;
            //publish a test message. 
            pubnub.publish (channel, "Test message", Common.DisplayReturnMessage);

            List<object> lstHistory = null;

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e) {
                if (e.PropertyName == "History")
                {
                    lstHistory = ((Pubnub)sender).History;

                    responseStatus = true;
                }
            };

            pubnub.history(channel, 1);

            while (!responseStatus) ;

            string strResponse = "";
            if (lstHistory.Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
                foreach(object lst in lstHistory)
                {
                    strResponse = lst.ToString();
                    Console.WriteLine("resp:" + strResponse);
                    Assert.IsNotEmpty(strResponse);
                }
            }
        }

        [Test]
        public static void TestUnencryptedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "my_channel";
            pubnub.CIPHER_KEY = "";

            Common.deliveryStatus = false;
            string message = "Pubnub API Usage Example - Publish";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e) {
                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    Common.deliveryStatus = true;
                }
            };
            pubnub.publish(channel, message, Common.DisplayReturnMessage);
            while (!Common.deliveryStatus) ;
            pubnub.history(channel, 1);
            
            Common.deliveryStatus = false;

            while (!Common.deliveryStatus) ;
            if (pubnub.History[0].Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
             Assert.AreEqual(pubnub.History[0], message);
            }
        }
        
        [Test]
        public static void TestEncryptedHistory()
        {
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            string channel = "my_channel";

            Common.deliveryStatus = false;
            string message = "Pubnub API Usage Example - Publish";
            pubnub.CIPHER_KEY = "enigma";

            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "History")
                {
                    Console.WriteLine("\n*********** History Messages *********** ");
                    Common.deliveryStatus = true;
                }
            };
            Common.deliveryStatus = false;
            pubnub.publish(channel, message, Common.DisplayReturnMessage);
            while (!Common.deliveryStatus) ;

            Common.deliveryStatus = false;
            pubnub.history(channel, 1);
            while (!Common.deliveryStatus) ;
            if (pubnub.History[0].Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
                Assert.AreEqual(pubnub.History[0], message);
            }
        }  
    }
}