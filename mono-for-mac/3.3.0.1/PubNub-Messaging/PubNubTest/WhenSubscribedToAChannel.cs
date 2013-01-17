using System;
using PubNubMessaging.Core;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Threading;


namespace PubNubMessaging.Tests
{
    [TestFixture]
    public class WhenSubscribedToAChannel
    {
       [Test]
       public void ThenItShouldReturnReceivedMessage () 
       {

          Pubnub pubnub = new Pubnub (
                "demo",
                "demo",
                "",
                "",
                false);
          string channel = "hello_world";

          Common common = new Common();
          common.DeliveryStatus = false;
          common.Response = null;

          pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenSubscribedToAChannel", "ThenSubscribeShouldReturnReceivedMessage");

          pubnub.Subscribe (channel, common.DisplayReturnMessage); 
          Thread.Sleep(3000);

          string message = "Test Message";

          pubnub.Publish (channel, message, common.DisplayReturnMessageDummy);

          //cm.deliveryStatus = false;
          while (!common.DeliveryStatus);
             if (common.Response != null) {
                IList<object> fields = common.Response as IList<object>;

                if (fields [0] != null)
                {
                    var myObjectArray = (from item in fields select item as object).ToArray ();
                    Console.WriteLine ("Response:" + myObjectArray[0].ToString ());
                    Assert.AreEqual(message, myObjectArray[0].ToString());
                }
                else
                {
                    Assert.Fail("No response");
                }
             }
            else
            {
              Assert.Fail("No response");
            }
       }
        
       [Test]
       public void ThenItShouldReturnReceivedMessageCipher ()
       {

          Pubnub pubnub = new Pubnub (
                "demo",
                "demo",
                "",
                "enigma",
                false);
          string channel = "hello_world";

          Common common = new Common();
          common.DeliveryStatus = false;
          common.Response = null;

          pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenSubscribedToAChannel", "ThenSubscribeShouldReturnReceivedMessageCipher");

          string message = "Test Message";

          pubnub.Subscribe (channel, common.DisplayReturnMessage); 
          Thread.Sleep(3000);

          pubnub.Publish (channel, message, common.DisplayReturnMessageDummy);

          while (!common.DeliveryStatus);
          
            if (common.Response != null) {
              IList<object> fields = common.Response as IList<object>;
              
              if (fields [0] != null)
              {
                var myObjectArray = (from item in fields select item as object).ToArray ();
                Console.WriteLine ("Response:" + myObjectArray[0].ToString ());
                Assert.AreEqual(message, myObjectArray[0].ToString());
              }
          }
       }
    }
}

