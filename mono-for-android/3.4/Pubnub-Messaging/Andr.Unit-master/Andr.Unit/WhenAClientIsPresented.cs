using System;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using PubNubMessaging.Core;


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
			Common commonPresence = new Common();
			commonPresence.DeliveryStatus = false;
			commonPresence.Response = null;
			
			pubnub.PubnubUnitTest = commonPresence.CreateUnitTestInstance("WhenAClientIsPresented", "ThenPresenceShouldReturnReceivedMessage");
			
			pubnub.Presence(channel, commonPresence.DisplayReturnMessageDummy, commonPresence.DisplayReturnMessageDummy);
			
			Common commonSubscribe = new Common();
			commonSubscribe.DeliveryStatus = false;
			commonSubscribe.Response = null;
			
			pubnub.Subscribe(channel, commonSubscribe.DisplayReturnMessageDummy, commonSubscribe.DisplayReturnMessage);
			while (!commonSubscribe.DeliveryStatus) ;
			
			string response = "";
			if (commonSubscribe.Response == null) {
				Assert.Fail("Null response");
			}
			else
			{
				IList<object> responseFields = commonSubscribe.Response as IList<object>;
				foreach (object item in responseFields)
				{
					response = item.ToString();
					Console.WriteLine("Response:" + response);
					//Assert.IsNotEmpty(strResponse);
				}
				Assert.True("hello_world".Equals(responseFields[2]));
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
					Assert.NotNull(response);
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
		
		[Test]
		public void ThenPresenceShouldReturnCustomUUID()
		{
			Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
			
			Common commonHereNow = new Common();
			commonHereNow.DeliveryStatus = false;
			commonHereNow.Response = null;
			
			Common commonSubscribe = new Common();
			commonSubscribe.DeliveryStatus = false;
			commonSubscribe.Response = null;
			
			pubnub.PubnubUnitTest = commonHereNow.CreateUnitTestInstance("WhenAClientIsPresented", "ThenPresenceShouldReturnCustomUUID");;
			pubnub.SessionUUID = "CustomSessionUUIDTest";
			
			string channel = "hello_world";
			
			pubnub.Subscribe(channel, commonSubscribe.DisplayReturnMessageDummy, commonSubscribe.DisplayReturnMessage);
			
			while (!commonSubscribe.DeliveryStatus);
			
			pubnub.HereNow<string>(channel, commonHereNow.DisplayReturnMessage);
			
			while (!commonHereNow.DeliveryStatus);
			
			if (commonHereNow.Response == null) {
				Assert.Fail("Null response");
			}
			else
			{
				Assert.True(commonHereNow.Response.ToString().Contains(pubnub.SessionUUID));
			}          
		}
	}
}

