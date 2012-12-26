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
//using System.Collections.Generic;

namespace PubnubWindowsPhone.Test.UnitTest
{
    [TestClass]
    public class WhenGetRequestServerTime : WorkItemTest
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        bool timeReceived = false;

        [TestMethod]
        [Asynchronous]
        [Description("Gets the Server Time in Unix time nanosecond format")]
        public void ThenItShouldReturnTimeStamp()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenGetRequestServerTime";
                    unitTest.TestCaseName = "ThenItShouldReturnTimeStamp";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.time<string>(ReturnTimeStampCallback);
                    manualEvent1.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(timeReceived, "time() Failed");
                            TestComplete();
                        });
                });
        }

        [Asynchronous]
        private void ReturnTimeStampCallback(string result)
        {
            Deployment.Current.Dispatcher.BeginInvoke(() =>
                {
                    if (!string.IsNullOrWhiteSpace(result))
                    {
                        object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                        if (receivedObj is object[])
                        {
                            string time = receivedObj[0].ToString();
                            if (time.Length > 0)
                            {
                                timeReceived = true;
                            }
                        }
                    }
                });
            manualEvent1.Set();
        }

        [TestMethod]
        public void TranslateDateTimeToUnixTime()
        {
            DateTime dt = new DateTime(2012, 6, 26, 0, 0, 0, DateTimeKind.Utc);
            long nanosecTime = Pubnub.translateDateTimeToPubnubUnixNanoSeconds(dt);
            //Test for 26th June 2012 GMT
            Assert.AreEqual<long>(13406688000000000, nanosecTime);
        }

        [TestMethod]
        public void TranslateUnixTimeToDateTime()
        {
            //Test for 26th June 2012 GMT
            DateTime expectedDt = new DateTime(2012, 6, 26, 0, 0, 0, DateTimeKind.Utc);
            DateTime actualDt = Pubnub.translatePubnubUnixNanoSecondsToDateTime(13406688000000000);
            Assert.AreEqual<DateTime>(expectedDt, actualDt);
        }
    }
}
