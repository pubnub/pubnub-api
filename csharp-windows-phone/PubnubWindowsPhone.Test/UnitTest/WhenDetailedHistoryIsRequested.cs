using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;

using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Phone.Testing;
using PubNub_Messaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Collections.Generic;


namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenDetailedHistoryIsRequested : WorkItemTest
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

        [TestMethod,Asynchronous]
        public void DetailHistoryCount10ReturnsRecords()
        {
            msg10Received = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    pubnub.detailedHistory<string>(channel, 10, DetailedHistoryCount10Callback);
                    mreMsgCount10.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(msg10Received, "Detailed History Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        void DetailedHistoryCount10Callback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null)
                    {
                        //object[] historyObj = (object[])receivedObj[0];
                        if (jArr.Count >= 0)
                        {
                            msg10Received = true;
                        }
                    }
                }
            }

            mreMsgCount10.Set();
        }

        [TestMethod,Asynchronous]
        public void DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            msg10ReverseTrueReceived = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";

                    pubnub.detailedHistory<string>(channel, -1, -1, 10, true, DetailedHistoryCount10ReverseTrueCallback);
                    mreMsgCount10ReverseTrue.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(msg10ReverseTrueReceived, "Detailed History Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        void DetailedHistoryCount10ReverseTrueCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null)
                    {
                        //object[] historyObj = (object[])receivedObj[0];
                        if (jArr.Count >= 0)
                        {
                            msg10ReverseTrueReceived = true;
                        }
                    }
                }
            }

            mreMsgCount10ReverseTrue.Set();
        }

        [TestMethod,Asynchronous]
        public void DetailedHistoryStartWithReverseTrue()
        {
            expectedCountAtStartTimeWithReverseTrue = 0;
            msgStartReverseTrue = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
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
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(msgStartReverseTrue, "Detailed History with Start and Reverse True Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        private void DetailedHistoryStartWithReverseTrueCallback(string result)
        {
            int actualCountAtStartTimeWithReverseFalse = 0;
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null)
                    {
                        //object[] historyObj = (object[])receivedObj[0];
                        if (jArr.Count >= expectedCountAtStartTimeWithReverseTrue)
                        {
                            foreach (object item in jArr)
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

        [Asynchronous]
        private void DetailedHistorySamplePublishCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    int statusCode = Int32.Parse(receivedObj[0].ToString());
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
