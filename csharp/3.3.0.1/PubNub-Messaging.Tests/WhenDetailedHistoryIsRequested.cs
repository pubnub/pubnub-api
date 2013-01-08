using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;

namespace PubNubMessaging.Tests
{
    [TestFixture]
    public class WhenDetailedHistoryIsRequested
    {
        ManualResetEvent mreMessageCount10 = new ManualResetEvent(false);
        ManualResetEvent mreMessageCount10ReverseTrue = new ManualResetEvent(false);
        ManualResetEvent mreMessageStartReverseTrue = new ManualResetEvent(false);
        ManualResetEvent mrePublishStartReverseTrue = new ManualResetEvent(false);


        bool message10Received = false;
        bool message10ReverseTrueReceived = false;
        bool messageStartReverseTrue = false;

        int expectedCountAtStartTimeWithReverseTrue=0;
        long startTimeWithReverseTrue = 0;

        [Test]
        public void DetailHistoryCount10ReturnsRecords()
        {
            message10Received = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
            unitTest.TestCaseName = "DetailHistoryCount10ReturnsRecords";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";

            pubnub.DetailedHistory<string>(channel, 10, DetailedHistoryCount10Callback);
            mreMessageCount10.WaitOne(310 * 1000);
            Assert.IsTrue(message10Received, "Detailed History Failed");
        }

        void DetailedHistoryCount10Callback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null)
                    {
                        if (message.Count >= 0)
                        {
                            message10Received = true;
                        }
                    }
                }
            }

            mreMessageCount10.Set();
        }

        [Test]
        public void DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            message10ReverseTrueReceived = false;

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
            unitTest.TestCaseName = "DetailHistoryCount10ReverseTrueReturnsRecords";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";

            pubnub.DetailedHistory<string>(channel, -1, -1, 10, true, DetailedHistoryCount10ReverseTrueCallback);
            mreMessageCount10ReverseTrue.WaitOne(310 * 1000);
            Assert.IsTrue(message10ReverseTrueReceived, "Detailed History Failed");
        }

        void DetailedHistoryCount10ReverseTrueCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null)
                    {
                        if (message.Count >= 0)
                        {
                            message10ReverseTrueReceived = true;
                        }
                    }
                }
            }

            mreMessageCount10ReverseTrue.Set();
        }

        [Test]
        public void DetailedHistoryStartWithReverseTrue()
        {
            expectedCountAtStartTimeWithReverseTrue = 0;
            messageStartReverseTrue = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenDetailedHistoryIsRequested";
            unitTest.TestCaseName = "DetailedHistoryStartWithReverseTrue";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";
            startTimeWithReverseTrue = Pubnub.TranslateDateTimeToPubnubUnixNanoSeconds(new DateTime(2012,12,1));
            for (int index = 0; index < 10; index++)
            {
                pubnub.Publish<string>(channel, 
                    string.Format("DetailedHistoryStartTimeWithReverseTrue {0}", index), 
                    DetailedHistorySamplePublishCallback);
                mrePublishStartReverseTrue.WaitOne();
            }

            Thread.Sleep(2000);

            pubnub.DetailedHistory<string>(channel, startTimeWithReverseTrue, DetailedHistoryStartWithReverseTrueCallback, true);
            mreMessageStartReverseTrue.WaitOne(310 * 1000);
            Assert.IsTrue(messageStartReverseTrue, "Detailed History with Start and Reverse True Failed");
        }

        private void DetailedHistoryStartWithReverseTrueCallback(string result)
        {
            int actualCountAtStartTimeWithReverseFalse = 0;
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null)
                    {
                        if (message.Count >= expectedCountAtStartTimeWithReverseTrue)
                        {
                            foreach (object item in message)
                            {
                                if (item.ToString().Contains("DetailedHistoryStartTimeWithReverseTrue"))
                                {
                                    actualCountAtStartTimeWithReverseFalse++;
                                }
                            }
                            if (actualCountAtStartTimeWithReverseFalse == expectedCountAtStartTimeWithReverseTrue)
                            {
                                messageStartReverseTrue = true;
                            }
                        }
                    }
                }
            }
            mreMessageStartReverseTrue.Set();
        }

        private void DetailedHistorySamplePublishCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    int statusCode = Int32.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        expectedCountAtStartTimeWithReverseTrue++;
                    }
                }
            }
            mrePublishStartReverseTrue.Set();
        }
    }
}
