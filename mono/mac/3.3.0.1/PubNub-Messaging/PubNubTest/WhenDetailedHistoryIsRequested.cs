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

     Common.deliveryStatus = false;
     //publish a test message. 
     pubnub.publish(channel, "Test message", Common.DisplayReturnMessage);
             
     while (!Common.deliveryStatus)
       ; 

     Common.deliveryStatus = false;
     Common.objResponse = null;
     pubnub.detailedHistory(channel, 1, Common.DisplayReturnMessage);
     while (!Common.deliveryStatus)
       ;

     string strResponse = "";
     if (Common.objResponse.Equals(null))
       {
        Assert.Fail("Null response");
       } else
        {
          IList<object> fields = Common.objResponse as IList<object>;
          foreach (object item in fields)
            {
             strResponse = item.ToString();
             Console.WriteLine(strResponse);
             Assert.IsNotEmpty(strResponse);
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
          long starttime = Common.Timestamp(pubnub);
          
          
          for (int i = 0; i < total_msg / 2; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }
          
          long endtime = Common.Timestamp(pubnub);

          Common.deliveryStatus = false;
          Common.objResponse = null;
          Console.WriteLine("DetailedHistory with start & end");
          pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, Common.DisplayReturnMessage);

          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = true");
          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, Common.DisplayReturnMessage);

          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = false");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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

          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, Common.DisplayReturnMessage);

          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          string channel = "testchannel";
          //pubnub.CIPHER_KEY = "";
          int total_msg = 10;
          long starttime = Common.Timestamp(pubnub);
          Dictionary<long, string> inputs = new Dictionary<long,string>();
          for (int i = 0; i < total_msg / 2; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          
          long endtime = Common.Timestamp(pubnub);
          while (!Common.deliveryStatus) ;

          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, total_msg, Common.DisplayReturnMessage);
          Common.deliveryStatus = false;
          while (!Common.deliveryStatus) ;

          Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");

          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          string channel = "testchannel";
          //pubnub.CIPHER_KEY = "enigma";

          int total_msg = 10;
          long starttime = Common.Timestamp(pubnub);
          Dictionary<long, string> inputs = new Dictionary<long, string>();
          for (int i = 0; i < total_msg / 2; i++)
          {
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long endtime = Common.Timestamp(pubnub);
          while (!Common.deliveryStatus) ;

          
          Common.objResponse = null;
          pubnub.detailedHistory(channel, total_msg, Common.DisplayReturnMessage);
          Common.deliveryStatus = false;
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          string channel = "testchannel";

          int total_msg = 10;
          long starttime = Common.Timestamp(pubnub);
          
          
          for (int i = 0; i < total_msg / 2; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }


          long endtime = Common.Timestamp(pubnub);

          Common.deliveryStatus = false;
          Common.objResponse = null;
          Console.WriteLine("DetailedHistory with start & end");
          pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = true");
          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = false");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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

          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          string channel = "testchannel";
          //pubnub.CIPHER_KEY = "";
          string msg = "Test Message";
          Common.deliveryStatus = false;

          pubnub.publish(channel, msg, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
 
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, 10, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
          
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;

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
                       Assert.IsNotEmpty(strResponse);
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
          string channel = "testchannel";
          //pubnub.CIPHER_KEY = "enigma";
          string msg = "Test Message";

          Common.deliveryStatus = false;
          pubnub.publish(channel, msg, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;

          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, 1, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n*********** DetailedHistory Messages Received*********** ");
          
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          string channel = "testchannel";

          //pubnub.CIPHER_KEY = "enigma";
          int total_msg = 10;
          long starttime = Common.Timestamp(pubnub);
          
          
          for (int i = 0; i < total_msg / 2; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }
          
          long endtime = Common.Timestamp(pubnub);

          Common.deliveryStatus = false;
          Common.objResponse = null;
          Console.WriteLine("DetailedHistory with start & end");
          pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = true");
          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = false");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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

          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
       public static void TestUnEncryptedSecretDetailedHistoryParams()
       {
          Pubnub pubnub = new Pubnub(
                "demo",
                "demo",
                "secretkey",
                "",
                false);
          string channel = "testchannel";

          //pubnub.CIPHER_KEY = "enigma";
          int total_msg = 10;
          long starttime = Common.Timestamp(pubnub);
          
          
          for (int i = 0; i < total_msg / 2; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }

          long midtime = Common.Timestamp(pubnub);
          for (int i = total_msg / 2; i < total_msg; i++)
          {
             Common.deliveryStatus = false;
             string msg = i.ToString();
             pubnub.publish(channel, msg, Common.DisplayReturnMessage);
             while (!Common.deliveryStatus) ;
             //long t = Timestamp();
             //inputs.Add(t, msg);
             Console.WriteLine("Message # " + i.ToString() + " published");
          }
          
          long endtime = Common.Timestamp(pubnub);

          Common.deliveryStatus = false;
          Common.objResponse = null;
          Console.WriteLine("DetailedHistory with start & end");
          pubnub.detailedHistory(channel, starttime, midtime, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = true");
          string strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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
          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, true, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          
          Console.WriteLine("DetailedHistory with start & reverse = false");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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

          
          Common.deliveryStatus = false;
          Common.objResponse = null;
          pubnub.detailedHistory(channel, midtime, -1, total_msg / 2, false, Common.DisplayReturnMessage);
          while (!Common.deliveryStatus) ;
          Console.WriteLine("\n******* DetailedHistory Messages Received ******* ");
          strResponse = "";
          if (Common.objResponse.Equals(null))
          {
            Assert.Fail("Null response");
          } 
          else
          {
             IList<object> fields = Common.objResponse as IList<object>;
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

