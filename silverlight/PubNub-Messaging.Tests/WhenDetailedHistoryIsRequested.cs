using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;


namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenDetailedHistoryIsRequested
    {
        ManualResetEvent mreMsgCount10 = new ManualResetEvent(false);
        ManualResetEvent mreMsgCount10ReverseTrue = new ManualResetEvent(false);
        ManualResetEvent mreMsgStartReverseTrue = new ManualResetEvent(false);
        ManualResetEvent mrePublishStartReverseTrue = new ManualResetEvent(false);


        bool msg10Received = false;
        bool msg10ReverseTrueReceived = false;
        bool msgStartReverseTrue = false;

        int expectedCountAtStartTimeWithReverseTrue=0;
        long startTimeWithReverseTrue = 0;

        [TestMethod]
        public void DetailHistoryCount10ReturnsRecords()
        {
            msg10Received = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            pubnub.detailedHistory<string>(channel, 10, DetailedHistoryCount10Callback);
            mreMsgCount10.WaitOne(310 * 1000);
            Assert.IsTrue(msg10Received, "Detailed History Failed");
        }

        void DetailedHistoryCount10Callback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    if (receivedObj[0] is object[])
                    {
                        object[] historyObj = (object[])receivedObj[0];
                        if (historyObj.Length >= 0)
                        {
                            msg10Received = true;
                        }
                    }
                }
            }

            mreMsgCount10.Set();
        }

        [TestMethod]
        public void DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            msg10ReverseTrueReceived = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            pubnub.detailedHistory<string>(channel, -1, -1, 10, true, DetailedHistoryCount10ReverseTrueCallback);
            mreMsgCount10ReverseTrue.WaitOne(310 * 1000);
            Assert.IsTrue(msg10ReverseTrueReceived, "Detailed History Failed");
        }

        void DetailedHistoryCount10ReverseTrueCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    if (receivedObj[0] is object[])
                    {
                        object[] historyObj = (object[])receivedObj[0];
                        if (historyObj.Length >= 0)
                        {
                            msg10ReverseTrueReceived = true;
                        }
                    }
                }
            }

            mreMsgCount10ReverseTrue.Set();
        }

        [TestMethod]
        public void DetailedHistoryStartWithReverseTrue()
        {
            expectedCountAtStartTimeWithReverseTrue = 0;
            msgStartReverseTrue = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";
            startTimeWithReverseTrue = Pubnub.translateDateTimeToPubnubUnixNanoSeconds(DateTime.UtcNow);
            for (int index = 0; index < 10; index++)
            {
                pubnub.publish<string>(channel, 
                    string.Format("DetailedHistoryStartTimeWithReverseTrue {0} {1}", startTimeWithReverseTrue, index), 
                    DetailedHistorySamplePublishCallback);
                mrePublishStartReverseTrue.WaitOne(5000);
            }

            Thread.Sleep(5000);

            pubnub.detailedHistory<string>(channel, startTimeWithReverseTrue, DetailedHistoryStartWithReverseTrueCallback, true);
            mreMsgStartReverseTrue.WaitOne(310 * 1000);
            Assert.IsTrue(msgStartReverseTrue, "Detailed History with Start and Reverse True Failed");
        }

        private void DetailedHistoryStartWithReverseTrueCallback(string result)
        {
            int actualCountAtStartTimeWithReverseFalse = 0;
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    if (receivedObj[0] is object[])
                    {
                        object[] historyObj = (object[])receivedObj[0];
                        if (historyObj.Length >= expectedCountAtStartTimeWithReverseTrue)
                        {
                            foreach (object item in historyObj)
                            {
                                if (item.ToString().Contains(string.Format("DetailedHistoryStartTimeWithReverseTrue {0}", startTimeWithReverseTrue)))
                                {
                                    actualCountAtStartTimeWithReverseFalse++;
                                }
                            }
                            if (actualCountAtStartTimeWithReverseFalse == expectedCountAtStartTimeWithReverseTrue)
                            {
                                msgStartReverseTrue = true;
                            }
                        }
                    }
                }
            }
            mreMsgStartReverseTrue.Set();
        }

        private void DetailedHistorySamplePublishCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
                if (receivedObj is object[])
                {
                    int statusCode = (int)receivedObj[0];
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        expectedCountAtStartTimeWithReverseTrue++;
                    }
                }
            }
            mrePublishStartReverseTrue.Set();
        }
    }
}
