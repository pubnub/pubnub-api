using System;
using PubNub_Messaging;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Collections;


namespace PubNubTest
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
			
			Common cm = new Common();
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			//publish a test message. 
			pubnub.publish(channel, "Test message", cm.DisplayReturnMessage);
			
			while (!cm.deliveryStatus); 
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "ItShouldReturnDetailedHistory";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, 1, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus);
			
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				foreach (object item in fields)
				{
					strResponse = item.ToString();
					Console.WriteLine(strResponse);
					Assert.IsNotNull(strResponse);
				}             
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							Console.WriteLine("Resp:" + element.ToString());
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}
			}
		}
		
		[Test]
		public static void TestEncryptedDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			
			string channel = "hello_world";
			
			//pubnub.CIPHER_KEY = "enigma";
			int total_msg = 10;
			
			Common cm = new Common();
			cm.deliveryStatus = false;
			cm.objResponse = null;        
			
			long starttime = cm.Timestamp(pubnub);
			
			for (int i = 0; i < total_msg / 2; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				//Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long endtime = cm.Timestamp(pubnub);
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestEncryptedDetailedHistoryParams1";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			Console.WriteLine("DetailedHistory with start & end");
			pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, cm.DisplayReturnMessage);
			
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}
			}         
			
			
			PubnubUnitTest unitTest2 = new PubnubUnitTest();
			unitTest2.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest2.TestCaseName = "TestEncryptedDetailedHistoryParams2";
			
			pubnub.PubnubUnitTest = unitTest2;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, cm.DisplayReturnMessage);
			
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = total_msg / 2;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}
			}  
			
			
			PubnubUnitTest unitTest3 = new PubnubUnitTest();
			unitTest3.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest3.TestCaseName = "TestEncryptedDetailedHistoryParams3";
			
			pubnub.PubnubUnitTest = unitTest3;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, cm.DisplayReturnMessage);
			
			while (!cm.deliveryStatus) ;
			//Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
		}
		
		[Test]
		public static void TestUnencryptedDetailedHistory()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			string channel = "hello_world";
			//pubnub.CIPHER_KEY = "";
			int total_msg = 10;
			
			Common cm = new Common();
			long starttime = cm.Timestamp(pubnub);
			cm.deliveryStatus = false;
			cm.objResponse = null;
			Dictionary<long, string> inputs = new Dictionary<long,string>();
			for (int i = 0; i < total_msg / 2; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long endtime = cm.Timestamp(pubnub);
			while (!cm.deliveryStatus) ;
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestUnencryptedDetailedHistory";
			
			pubnub.PubnubUnitTest = unitTest;
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			pubnub.detailedHistory(channel, total_msg, cm.DisplayReturnMessage);
			cm.deliveryStatus = false;
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
		} 
		
		[Test]
		public static void TestEncryptedDetailedHistory()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			string channel = "hello_world";
			//pubnub.CIPHER_KEY = "enigma";
			
			int total_msg = 10;
			Common cm = new Common();
			long starttime = cm.Timestamp(pubnub);
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			Dictionary<long, string> inputs = new Dictionary<long, string>();
			for (int i = 0; i < total_msg / 2; i++)
			{
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long endtime = cm.Timestamp(pubnub);
			while (!cm.deliveryStatus) ;
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestEncryptedDetailedHistory";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.objResponse = null;
			pubnub.detailedHistory(channel, total_msg, cm.DisplayReturnMessage);
			cm.deliveryStatus = false;
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}          
			}  
		}
		
		[Test]
		public static void TestUnencryptedDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			string channel = "hello_world";
			
			int total_msg = 10;
			
			Common cm = new Common();
			long starttime = cm.Timestamp(pubnub);
			cm.deliveryStatus = false;
			cm.objResponse = null;          
			
			for (int i = 0; i < total_msg / 2; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			
			long endtime = cm.Timestamp(pubnub);
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestUnencryptedDetailedHistoryParams1";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			Console.WriteLine("DetailedHistory with start & end");
			pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
			
			PubnubUnitTest unitTest2 = new PubnubUnitTest();
			unitTest2.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest2.TestCaseName = "TestUnencryptedDetailedHistoryParams2";
			
			pubnub.PubnubUnitTest = unitTest2;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = total_msg / 2;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
			
			PubnubUnitTest unitTest3 = new PubnubUnitTest();
			unitTest3.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest3.TestCaseName = "TestUnencryptedDetailedHistoryParams3";
			
			pubnub.PubnubUnitTest = unitTest3;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}           
			}  
		}
		
		[Test]
		public static void DetailedHistory_Example()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"",
				false);
			string channel = "hello_world";
			//pubnub.CIPHER_KEY = "";
			string msg = "Test Message";
			Common cm = new Common();
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			pubnub.publish(channel, msg, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "DetailHistoryCount10ReturnsRecords";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			pubnub.detailedHistory(channel, 10, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							string strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0}", strResponse));
							Assert.IsNotNull(strResponse);
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}
			}  
		}
		
		[Test]
		public static void DetailedHistory_Decrypted_Example()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"",
				"enigma",
				false);
			string channel = "hello_world";
			//pubnub.CIPHER_KEY = "enigma";
			string msg = "Test Message";
			Common cm = new Common();
			
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			
			pubnub.publish(channel, msg, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "DetailedHistory_Decrypted_Example";
			
			pubnub.PubnubUnitTest = unitTest;
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, 1, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
			
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					
					IList<object> myObjectList = myObjectArray[0] as IList<object>;
					if (fields [0] != null)
					{
						Console.WriteLine("myObjectList[0]: " + myObjectList[0]);
						Assert.AreEqual(msg, myObjectList[0]);
					}
					else
					{
						Assert.Fail("NULL response");
					}
				}
			}  
		}
		
		[Test]
		public static void TestEncryptedSecretDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"secretkey",
				"enigma",
				false);
			string channel = "hello_world";
			
			//pubnub.CIPHER_KEY = "enigma";
			int total_msg = 10;
			
			Common cm = new Common();
			long starttime = cm.Timestamp(pubnub);
			cm.deliveryStatus = false;
			cm.objResponse = null;          
			
			for (int i = 0; i < total_msg / 2; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long endtime = cm.Timestamp(pubnub);
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestEncryptedSecretDetailedHistoryParams1";
			
			pubnub.PubnubUnitTest = unitTest;
			cm.deliveryStatus = false;
			cm.objResponse = null;
			Console.WriteLine("DetailedHistory with start & end");
			pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}             
			}  
			
			PubnubUnitTest unitTest2 = new PubnubUnitTest();
			unitTest2.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest2.TestCaseName = "TestEncryptedSecretDetailedHistoryParams2";
			
			pubnub.PubnubUnitTest = unitTest2;
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = total_msg / 2;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
			
			PubnubUnitTest unitTest3 = new PubnubUnitTest();
			unitTest3.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest3.TestCaseName = "TestEncryptedSecretDetailedHistoryParams3";
			
			pubnub.PubnubUnitTest = unitTest3;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}             
			}  
		}
		
		[Test]
		public static void TestUnencryptedSecretDetailedHistoryParams()
		{
			Pubnub pubnub = new Pubnub(
				"demo",
				"demo",
				"secretkey",
				"",
				false);
			string channel = "hello_world";
			
			//pubnub.CIPHER_KEY = "enigma";
			int total_msg = 10;
			Common cm = new Common();
			long starttime = cm.Timestamp(pubnub);
			cm.deliveryStatus = false;
			cm.objResponse = null;          
			
			for (int i = 0; i < total_msg / 2; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long midtime = cm.Timestamp(pubnub);
			for (int i = total_msg / 2; i < total_msg; i++)
			{
				cm.deliveryStatus = false;
				string msg = i.ToString();
				pubnub.publish(channel, msg, cm.DisplayReturnMessage);
				while (!cm.deliveryStatus) ;
				//long t = Timestamp();
				//inputs.Add(t, msg);
				Console.WriteLine("Message # " + i.ToString() + " published");
			}
			
			long endtime = cm.Timestamp(pubnub);
			
			PubnubUnitTest unitTest = new PubnubUnitTest();
			unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest.TestCaseName = "TestUnencryptedSecretDetailedHistoryParams1";
			
			pubnub.PubnubUnitTest = unitTest;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			Console.WriteLine("DetailedHistory with start & end");
			pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = true");
			string strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}            
			}  
			
			PubnubUnitTest unitTest2 = new PubnubUnitTest();
			unitTest2.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest2.TestCaseName = "TestUnencryptedSecretDetailedHistoryParams2";
			
			pubnub.PubnubUnitTest = unitTest2;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			
			Console.WriteLine("DetailedHistory with start & reverse = false");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = total_msg / 2;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}             
			}  
			
			
			PubnubUnitTest unitTest3 = new PubnubUnitTest();
			unitTest3.TestClassName = "WhenDetailedHistoryIsRequested";
			unitTest3.TestCaseName = "TestUnencryptedSecretDetailedHistoryParams3";
			
			pubnub.PubnubUnitTest = unitTest3;
			
			cm.deliveryStatus = false;
			cm.objResponse = null;
			pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, cm.DisplayReturnMessage);
			while (!cm.deliveryStatus) ;
			Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
			strResponse = "";
			if (cm.objResponse.Equals(null))
			{
				Assert.Fail("Null response");
			} 
			else
			{
				IList<object> fields = cm.objResponse as IList<object>;
				int j = 0;
				if (fields [0] != null)
				{
					var myObjectArray = (from item in fields select item as object).ToArray();
					IList<object> enumerable = myObjectArray [0] as IList<object>;
					if ((enumerable != null) && (enumerable.Count > 0))
					{
						foreach (object element in enumerable)
						{
							strResponse = element.ToString();
							Console.WriteLine(String.Format("resp:{0} :: j: {1}", strResponse, j));
							if(j<total_msg/2)
								Assert.AreEqual(j.ToString(), strResponse);
							j++;
						}
					}
					else
					{
						Assert.Fail("No response");
					}
				}             
			}  
		}
	}
}

