using System;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using PubNubMessaging.Core;


namespace PubNubMessaging.Tests
{
	[TestFixture]
	public class WhenAMessageIsPublished
	{
		public void NullMessage()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false
				);
			string channel = "hello_world";
			string message = null;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.Publish(channel, message, common.DisplayReturnMessage);
			//wait till the response is received from the server
			while (!common.DeliveryStatus) ;
			IList<object> fields = common.Response as IList<object>;
			string sent = fields[1].ToString();
			string one = fields[0].ToString();
			Assert.True(("Sent").Equals(sent));
			Assert.True(("1").Equals(one));
		}
		
		[Test]
		public void ThenItShouldReturnSuccessCodeAndInfo()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false
				);
			string channel = "hello_world";
			string message = "Pubnub API Usage Example";
			
			Common common = new Common();
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenAMessageIsPublished", "ThenItShouldReturnSuccessCodeAndInfo");
			
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.Publish(channel, message, common.DisplayReturnMessage);
			//wait till the response is received from the server
			while (!common.DeliveryStatus) ;
			IList<object> fields = common.Response as IList<object>;
			string sent = fields[1].ToString();
			string one = fields[0].ToString();
			Assert.True (("Sent").Equals(sent));
			Assert.True(("1").Equals(one));
		}
		
		[Test]
		public void ThenItShouldGenerateUniqueIdentifier()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false
				);
			
			Assert.NotNull(pubnub.GenerateGuid());
		}
		
		[Test]
		public void ThenPublishKeyShouldBeOverriden()
		{
			Pubnub pubnub = new Pubnub(
				"",
				"demo",
				"",
				"",
				false
				);
			string channel = "mychannel";
			string message = "Pubnub API Usage Example";
			
			pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false
				);
			Common common = new Common();
			Assert.True((true).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
		}
		
		[Test]
		[ExpectedException(typeof(MissingFieldException))]
		public void ThenPublishKeyShouldNotBeEmptyAfterOverriden()
		{
			Pubnub pubnub = new Pubnub(
				"",
				"demo",
				"",
				"",
				false
				);
			string channel = "mychannel";
			string message = "Pubnub API Usage Example";
			Common common = new Common();
			Assert.True((false).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
		}
		
		[Test]
		public void ThenSecretKeyShouldBeProvidedOptionally()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo"
				);
			string channel = "mychannel";
			string message = "Pubnub API Usage Example";
			Common common = new Common();
			Assert.True((true).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
			pubnub = new Pubnub(
				"demo",
				"demo",
				"key"
				);
			Assert.True((true).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
		}
		
		[Test]
		public void IfSSLNotProvidedThenDefaultShouldBeFalse()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				""
				);
			string channel = "hello_world";
			string message = "Pubnub API Usage Example";
			Common common = new Common();
			Assert.True((true).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
		}
		
		[Test]
		[ExpectedException(typeof(MissingFieldException))]
		public void NullShouldBeTreatedAsEmpty()
		{
			Pubnub pubnub = new Pubnub(
				null,
				"demo",
				null,
				null,
				false
				);
			string channel = "mychannel";
			string message = "Pubnub API Usage Example";
			Common common = new Common();
			Assert.True((false).Equals(pubnub.Publish(channel, message, common.DisplayReturnMessage)));
		}
	}
}

