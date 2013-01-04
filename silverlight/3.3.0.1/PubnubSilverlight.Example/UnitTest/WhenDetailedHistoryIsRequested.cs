using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using PubnubSilverlight.Core;
using Microsoft.Silverlight.Testing;


namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenDetailedHistoryIsRequested : SilverlightTest
    {
        bool msg10Received = false;
        bool msg10ReverseTrueReceived = false;
        bool msgStartReverseTrue = false;

        int expectedCountAtStartTimeWithReverseTrue=0;
        long startTimeWithReverseTrue = 0;

        bool isDetailedHistory = false;
        bool isDetailedHistoryReverse = false;
        bool isDetailedHistoryStartReverseTrue = false;
        bool isPublishStartReverseTrue = false;

        [TestMethod]
        [Asynchronous]
        public void DetailHistoryCount10ReturnsRecords()
        {
            msg10Received = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            EnqueueCallback(() => pubnub.detailedHistory<string>(channel, 10, DetailedHistoryCount10Callback));
            EnqueueConditional(() => isDetailedHistory);
            EnqueueCallback(() => Assert.IsTrue(msg10Received, "Detailed History Failed"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void DetailedHistoryCount10Callback(string result)
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

            isDetailedHistory = true;
        }

        [TestMethod]
        [Asynchronous]
        public void DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            msg10ReverseTrueReceived = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, -1, 10, true, DetailedHistoryCount10ReverseTrueCallback));
            EnqueueConditional(() => isDetailedHistoryReverse);
            EnqueueCallback(() => Assert.IsTrue(msg10ReverseTrueReceived, "Detailed History Failed"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void DetailedHistoryCount10ReverseTrueCallback(string result)
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

            isDetailedHistoryReverse = true;
        }

        [TestMethod]
        [Asynchronous]
        public void DetailedHistoryStartWithReverseTrue()
        {
            expectedCountAtStartTimeWithReverseTrue = 0;
            msgStartReverseTrue = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";
            startTimeWithReverseTrue = Pubnub.translateDateTimeToPubnubUnixNanoSeconds(DateTime.UtcNow);

            EnqueueCallback(() =>
            {
                for (int index = 0; index < 10; index++)
                {
                    EnqueueCallback(() =>
                    {
                        pubnub.publish<string>(channel, string.Format("DetailedHistoryStartTimeWithReverseTrue {0} {1}", startTimeWithReverseTrue, index), DetailedHistorySamplePublishCallback);
                    });
                    EnqueueConditional(() => isPublishStartReverseTrue);
                }
            });

            //EnqueueCallback(() => Thread.Sleep(5000)); !!!

            EnqueueCallback(() => pubnub.detailedHistory<string>(channel, startTimeWithReverseTrue, DetailedHistoryStartWithReverseTrueCallback, true));
            EnqueueConditional(() => isDetailedHistoryStartReverseTrue);
            EnqueueCallback(() => Assert.IsTrue(msgStartReverseTrue, "Detailed History with Start and Reverse True Failed"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void DetailedHistoryStartWithReverseTrueCallback(string result)
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
            isDetailedHistoryStartReverseTrue = true;
        }

        [Asynchronous]
        public void DetailedHistorySamplePublishCallback(string result)
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
            isPublishStartReverseTrue = true;
        }
    }
}
