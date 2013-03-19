using System;
using PubNubMessaging.Core;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;


namespace PubNubMessaging.Tests
{
  [TestFixture]
  public class WhenUnsubscribedToAChannel
  {
    [Test]
    public void ThenNonExistentChannelShouldReturnNotSubscribed()
    {
      Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

      Common common = new Common();
      common.DeliveryStatus = false;
      common.Response = null;
      
      pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenUnsubscribedToAChannel", "ThenNonExistentChannelShouldReturnNotSubscribed");
      
      string channel = "hello_world";
      
      pubnub.Unsubscribe<string>(channel, common.DisplayReturnMessage, common.DisplayReturnMessageDummy, common.DisplayReturnMessageDummy);
      while (!common.DeliveryStatus) ;
      
      if (common.Response.ToString().Contains ("not subscribed")) {
        Console.WriteLine("Response:" + common.Response);
        Assert.Pass();
      }
      else
      {
        Assert.Fail();
      }
    }

    [Test]
    public void ThenShouldReturnUnsubscribedMessage()
    {
      Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
      
      Common common = new Common();
      common.DeliveryStatus = false;
      common.Response = null;
      
      pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenUnsubscribedToAChannel", "ThenShouldReturnUnsubscribedMessage");
      
      string channel = "hello_world";

      pubnub.Subscribe<string>(channel, common.DisplayReturnMessageDummy, common.DisplayReturnMessage);

      while (!common.DeliveryStatus) ;
      common.DeliveryStatus = false;
      common.Response = null;

      pubnub.Unsubscribe<string>(channel, common.DisplayReturnMessageDummy, common.DisplayReturnMessageDummy, common.DisplayReturnMessage);
      while (!common.DeliveryStatus) ;

      if (common.Response.ToString().Contains ("Unsubscribed from")) {
        Console.WriteLine("Response:" + common.Response);
        Assert.Pass();
      }
      else
      {
        Assert.Fail();
      }    
    }
  }
}

