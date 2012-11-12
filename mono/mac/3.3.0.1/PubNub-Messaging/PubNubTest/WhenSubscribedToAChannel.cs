using System;
using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Collections;
using System.Linq;


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

          Common.deliveryStatus = false;

          pubnub.subscribe (channel, Common.DisplayReturnMessage); 
          string msg = "Test Message";
          pubnub.publish (channel, msg, Common.DisplayReturnMessage);
          Common.deliveryStatus = false;
          while (!Common.deliveryStatus);
          bool bStop = false;
          while (!bStop) {
             if (Common.objResponse != null) {
                IList<object> fields = Common.objResponse as IList<object>;

                if (fields [0] != null)
                {
                    var myObjectArray = (from item in fields select item as object).ToArray ();
                    IEnumerable enumerable = myObjectArray [0] as IEnumerable;
                    if (enumerable != null) {
                       foreach (object element in enumerable) 
                       {
                          Console.WriteLine ("Resp:" + element.ToString ());
                          Assert.AreEqual(msg, element.ToString());
                          bStop = true;
                       }
                    }
                }
             }
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

          Common.deliveryStatus = false;

          pubnub.subscribe (channel, Common.DisplayReturnMessage); 
          string msg = "Test Message";
          pubnub.publish (channel, msg, Common.DisplayReturnMessage);
          Common.deliveryStatus = false;
          while (!Common.deliveryStatus);
            
          bool bStop = false;
          while (!bStop) {
             if (Common.objResponse != null) {
                IList<object> fields = Common.objResponse as IList<object>;

                if (fields [0] != null)
                {
                    var myObjectArray = (from item in fields select item as object).ToArray ();
                    IEnumerable enumerable = myObjectArray [0] as IEnumerable;
                    if (enumerable != null) {
                       foreach (object element in enumerable) 
                       {
                          PubnubCrypto aes = new PubnubCrypto("enigma");
                          
                          Console.WriteLine ("Resp:" + element.ToString ());
                          //non serialized input
                          Assert.AreEqual("\""+msg+"\"", aes.decrypt(element.ToString()));
                          bStop = true;
                       }
                    }
                }
             }
          }
       }
    }
}

