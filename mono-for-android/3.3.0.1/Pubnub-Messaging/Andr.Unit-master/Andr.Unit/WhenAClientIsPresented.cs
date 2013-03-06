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
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenAClientIsPresented", "ThenPresenceShouldReturnCustomUUID");;
			pubnub.SessionUUID = "CustomSessionUUIDTest";
			
			string channel = "hello_world";
			
			pubnub.Presence(channel, common.DisplayReturnMessage);
			
			pubnub.Subscribe(channel, common.DisplayReturnMessageDummy);
			
			while (!common.DeliveryStatus) ;
			
			string response = "";
			if (common.Response.Equals (null)) {
				Assert.Fail("Null response");
			}
			else
			{
				IList<object> responseFields = common.Response as IList<object>;
				if(responseFields != null)
				{
					foreach (object item in responseFields)
					{
						response = item.ToString();
						Console.WriteLine("Response:" + response);
					}
					Assert.True((responseFields[0].ToString()).Contains(pubnub.SessionUUID));
				}
				else
				{
					Assert.Fail("null response");
				}
			}          
		}
	}
}

