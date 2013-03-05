using System;
using PubNubMessaging.Core;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;


namespace PubNubMessaging.Tests
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
            Common common = new Common();
            common.DeliveryStatus = false;
            common.Response = null;

            pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenAClientIsPresented", "ThenPresenceShouldReturnReceivedMessage");

            pubnub.Presence(channel, common.DisplayReturnMessage);
            //while (!cm.deliveryStatus) ;
            //cm.response = null;
            pubnub.Subscribe(channel, common.DisplayReturnMessageDummy);
            while (!common.DeliveryStatus) ;

            string response = "";
            if (common.Response.Equals (null)) {
                Assert.Fail("Null response");
            }
            else
            {
                IList<object> responseFields = common.Response as IList<object>;
                foreach (object item in responseFields)
                {
                    response = item.ToString();
                    Console.WriteLine("Response:" + response);
                    //Assert.IsNotEmpty(strResponse);
                }
                Assert.AreEqual("hello_world", responseFields[2]);
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
            Common common = new Common();
            common.DeliveryStatus = false;
            common.Response = null;
            
            HereNow(pubnub, "IfHereNowIsCalledThenItShouldReturnInfo", common.DisplayReturnMessage);
            while (!common.DeliveryStatus) ;

            ParseResponse(common.Response);
        }

        void HereNow(Pubnub pubnub, string unitTestCaseName, 
                                            Action<object> userCallback)
        {
          string channel = "hello_world";

          PubnubUnitTest unitTest = new PubnubUnitTest();
          unitTest.TestClassName = "WhenAClientIsPresented";
          unitTest.TestCaseName = unitTestCaseName;
          pubnub.PubnubUnitTest = unitTest;

          pubnub.HereNow(channel, userCallback);
        }

        public void ParseResponse(object commonResponse)
        {
          string response = "";
          if (commonResponse.Equals (null)) {
            Assert.Fail("Null response");
          }
          else
          {
            IList<object> responseFields = commonResponse as IList<object>;
            foreach(object item in responseFields)
            {
              response = item.ToString();
              Console.WriteLine("Response:" + response);
              Assert.IsNotEmpty(response);
            }
            Dictionary<string, object> message = (Dictionary<string, object>)responseFields[0];
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

        [Test]
        public void IfHereNowIsCalledWithCipherThenItShouldReturnInfo()
        {
            Pubnub pubnub = new Pubnub(
               "demo",
               "demo",
               "",
               "enigma",
               false
            );
            Common common = new Common();
            common.DeliveryStatus = false;
            common.Response = null;
            
            HereNow(pubnub, "IfHereNowIsCalledThenItShouldReturnInfo", common.DisplayReturnMessage);
            while (!common.DeliveryStatus) ;

            ParseResponse(common.Response);
        }
    }
}

