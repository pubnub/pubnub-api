using System;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Collections;
using PubNubMessaging.Core;


namespace PubNubMessaging.Tests
{
	[TestFixture]
	public class WhenDetailedHistoryIsRequested
	{
		[Test]
		public void ItShouldReturnDetailedHistory()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false
				);
			string channel = "hello_world";
			string message = "Test message";
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			//publish a test message. 
			pubnub.Publish(channel, message, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus); 
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"ItShouldReturnDetailedHistory");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, 1, common.DisplayReturnMessage);
			while (!common.DeliveryStatus);
			
			ParseResponse(common.Response, 0, 0, message);
		}
		
		public void SendMultipleIntMessages(int messageStart, int messageEnd, string channel, Pubnub pubnub)
		{
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;   
			
			for (int i = messageStart; i < messageEnd; i++)
			{
				common.DeliveryStatus = false;
				string msg = i.ToString();
				pubnub.Publish(channel, msg, common.DisplayReturnMessage);
				
				while (!common.DeliveryStatus) ;
				
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
		}
		
		public void ParseResponse(object commonResponse, int messageStart, int messageEnd, string message)
		{
			if (commonResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = commonResponse as IList<object>;
				
				if (fields [0] != null)
				{
					ParseFields(fields, messageStart, messageEnd, message);
				}
			}        
		}
		
		public void ParseFields(IList<object> fields, int messageStart, int messageEnd, string message)
		{
			string response = "";
			
			var myObjectArray = (from item in fields select item as object).ToArray();
			IList<object> enumerable = myObjectArray [0] as IList<object>;
			if ((enumerable != null) && (enumerable.Count > 0))
			{
				int j = messageStart;
				foreach (object element in enumerable)
				{
					response = element.ToString();
					if(messageStart != messageEnd)
					{
						Console.WriteLine(String.Format("response :{0} :: j: {1}", response, j));
						if(j < messageEnd)
							Assert.AreEqual(j.ToString(), response);
						j++;
					}
					else if(!message.Equals(""))
					{
						Console.WriteLine("Response:" + response);
						Assert.AreEqual(message, response);
					}
					else
					{
						Console.WriteLine("Response:" + response);
						Assert.IsNotNull(response);
					}
				}
			}
			else
			{
				Assert.Fail("No response");
			}
		}
		
		[Test]
		public void TestUnencryptedDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			
			string channel = "hello_world";
			
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;        
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages/2, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages/2, totalMessages, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedDetailedHistoryParams1");
			
			common.DeliveryStatus = false;
			common.Response = null;
			Console.WriteLine("DetailedHistory with start & end");
			
			pubnub.DetailedHistory(channel, starttime, midtime, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedDetailedHistoryParams2");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			
			ParseResponse(common.Response, totalMessages/2, totalMessages, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedDetailedHistoryParams3");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, false, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
		}
		
		[Test]
		public void TestEncryptedDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			
			string channel = "hello_world";
			
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;        
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages/2, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages/2, totalMessages, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedDetailedHistoryParams1");
			
			common.DeliveryStatus = false;
			common.Response = null;
			Console.WriteLine("DetailedHistory with start & end");
			
			pubnub.DetailedHistory(channel, starttime, midtime, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedDetailedHistoryParams2");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			
			ParseResponse(common.Response, totalMessages/2, totalMessages, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedDetailedHistoryParams3");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, false, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
		}
		
		[Test]
		public void TestUnencryptedDetailedHistory()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			
			string channel = "hello_world";
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages/2, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages/2, totalMessages, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			while (!common.DeliveryStatus) ;
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested", "TestUnencryptedDetailedHistory");
			
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.DetailedHistory(channel, totalMessages, common.DisplayReturnMessage);
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			ParseResponse(common.Response, 0, totalMessages, "");
		} 
		
		[Test]
		public void TestEncryptedDetailedHistory()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			string channel = "hello_world";
			
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages, totalMessages/2, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			while (!common.DeliveryStatus) ;
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested", "TestEncryptedDetailedHistory");
			
			common.Response = null;
			common.DeliveryStatus = false;
			
			pubnub.DetailedHistory(channel, totalMessages, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			
			ParseResponse(common.Response, 0, totalMessages, "");
		}
		
		[Test]
		public void DetailedHistoryExample()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			string channel = "hello_world";
			
			string message = "Test Message";
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.Publish(channel, message, common.DisplayReturnMessage);
			while (!common.DeliveryStatus) ;
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested", "DetailHistoryCount10ReturnsRecords");
			
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.DetailedHistory(channel, 10, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			
			ParseResponse(common.Response, 0,  0, "");
		}
		
		[Test]
		public void DetailedHistoryDecryptedExample()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			string channel = "hello_world";
			
			string message = "Test Message";
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.Publish(channel, message, common.DisplayReturnMessage);
			while (!common.DeliveryStatus) ;
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested", "DetailedHistoryDecryptedExample");
			
			common.DeliveryStatus = false;
			common.Response = null;
			
			pubnub.DetailedHistory(channel, 1, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			
			ParseResponse(common.Response, 0, 0, message);
		}
		
		[Test]
		public void TestEncryptedSecretDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"secretkey",
				"enigma",
				false);
			
			string channel = "hello_world";
			
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;        
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages/2, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages/2, totalMessages, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedSecretDetailedHistoryParams1");
			
			common.DeliveryStatus = false;
			common.Response = null;
			Console.WriteLine("DetailedHistory with start & end");
			
			pubnub.DetailedHistory(channel, starttime, midtime, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedSecretDetailedHistoryParams2");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			
			ParseResponse(common.Response, totalMessages/2, totalMessages, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestEncryptedSecretDetailedHistoryParams3");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, false, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
		}
		
		[Test]
		public void TestUnencryptedSecretDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"secretkey",
				"",
				false);
			
			string channel = "hello_world";
			
			int totalMessages = 10;
			
			Common common = new Common();
			common.DeliveryStatus = false;
			common.Response = null;        
			
			long starttime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(0, totalMessages/2, channel, pubnub);
			
			long midtime = common.Timestamp(pubnub);
			
			SendMultipleIntMessages(totalMessages/2, totalMessages, channel, pubnub);
			
			long endtime = common.Timestamp(pubnub);
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedSecretDetailedHistoryParams1");
			
			common.DeliveryStatus = false;
			common.Response = null;
			Console.WriteLine("DetailedHistory with start & end");
			
			pubnub.DetailedHistory(channel, starttime, midtime, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedSecretDetailedHistoryParams2");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, true, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			
			ParseResponse(common.Response, totalMessages/2, totalMessages, "");
			
			pubnub.PubnubUnitTest = common.CreateUnitTestInstance("WhenDetailedHistoryIsRequested" ,"TestUnencryptedSecretDetailedHistoryParams3");
			
			common.DeliveryStatus = false;
			common.Response = null;
			pubnub.DetailedHistory(channel, midtime, -1, totalMessages / 2, false, common.DisplayReturnMessage);
			
			while (!common.DeliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			ParseResponse(common.Response, 0, totalMessages/2, "");
		}
	}
}

