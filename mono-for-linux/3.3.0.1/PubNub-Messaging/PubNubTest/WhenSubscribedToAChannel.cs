using System;
using PubNub_Messaging;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Threading;


namespace PubNubTest
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

          Common cm = new Common();
          cm.deliveryStatus = false;
          cm.objResponse = null;

          PubnubUnitTest unitTest = new PubnubUnitTest();
          unitTest.TestClassName = "WhenSubscribedToAChannel";
          unitTest.TestCaseName = "ThenSubscribeShouldReturnReceivedMessage";
          
          pubnub.PubnubUnitTest = unitTest;

          pubnub.subscribe (channel, cm.DisplayReturnMessage); 
          Thread.Sleep(3000);
          string msg = "Test Message";

          pubnub.publish (channel, msg, cm.DisplayReturnMessageDummy);
          //cm.deliveryStatus = false;
          while (!cm.deliveryStatus);
             if (cm.objResponse != null) {
                IList<object> fields = cm.objResponse as IList<object>;

                if (fields [0] != null)
                {
                    var myObjectArray = (from item in fields select item as object).ToArray ();
                    Console.WriteLine ("Resp:" + myObjectArray[0].ToString ());
                    Assert.AreEqual(msg, myObjectArray[0].ToString());
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

          Common cm = new Common();
          cm.deliveryStatus = false;
          cm.objResponse = null;

          PubnubUnitTest unitTest = new PubnubUnitTest();
          unitTest.TestClassName = "WhenSubscribedToAChannel";
          unitTest.TestCaseName = "ThenSubscribeShouldReturnReceivedMessageCipher";
          
          pubnub.PubnubUnitTest = unitTest;

          pubnub.subscribe (channel, cm.DisplayReturnMessage); 
          Thread.Sleep(3000);
          string msg = "Test Message";

          pubnub.publish (channel, msg, cm.DisplayReturnMessageDummy);

          while (!cm.deliveryStatus);
            
            if (cm.objResponse != null) {
              IList<object> fields = cm.objResponse as IList<object>;
              
              if (fields [0] != null)
              {
                var myObjectArray = (from item in fields select item as object).ToArray ();
                Console.WriteLine ("Resp:" + myObjectArray[0].ToString ());
                Assert.AreEqual(msg, myObjectArray[0].ToString());
              }
          }
       }
    }
}

