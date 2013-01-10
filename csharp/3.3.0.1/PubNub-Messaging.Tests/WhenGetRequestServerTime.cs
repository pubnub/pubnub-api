using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace PubNub_Messaging.Tests
{
    [TestFixture]
    public class WhenGetRequestServerTime
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        bool timeReceived = false;

        [Test]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenGetRequestServerTime";
            unitTest.TestCaseName = "ThenItShouldReturnTimeStamp";

            pubnub.PubnubUnitTest = unitTest;

            pubnub.time<string>(ReturnTimeStampCallback);
            manualEvent1.WaitOne(310 * 1000);
            Assert.IsTrue(timeReceived, "time() Failed");
        }

        private void ReturnTimeStampCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
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
            manualEvent1.Set();
        }

        [Test]
        public void TranslateDateTimeToUnixTime()
        {
            //Test for 26th June 2012 GMT
            DateTime dt = new DateTime(2012,6,26,0,0,0,DateTimeKind.Utc);
            long nanosecTime = Pubnub.translateDateTimeToPubnubUnixNanoSeconds(dt);
            Assert.AreEqual(13406688000000000, nanosecTime);
        }

        [Test]
        public void TranslateUnixTimeToDateTime()
        {
            //Test for 26th June 2012 GMT
            DateTime expectedDt = new DateTime(2012, 6, 26, 0, 0, 0, DateTimeKind.Utc);
            DateTime actualDt = Pubnub.translatePubnubUnixNanoSecondsToDateTime(13406688000000000);
            Assert.AreEqual(expectedDt, actualDt);
        }
    }
}
