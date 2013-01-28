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
using PubNubMessaging.Core;

namespace PubNubMessaging.Tests
{
    [TestFixture]
    public class WhenGetRequestServerTime
    {
        ManualResetEvent mreTime = new ManualResetEvent(false);
        ManualResetEvent mreProxy = new ManualResetEvent(false);
        bool timeReceived = false;
        bool timeReceivedWhenProxy = false;

        [Test]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenGetRequestServerTime";
            unitTest.TestCaseName = "ThenItShouldReturnTimeStamp";

            pubnub.PubnubUnitTest = unitTest;

            pubnub.Time<string>(ReturnTimeStampCallback);
            mreTime.WaitOne(310 * 1000);
            Assert.IsTrue(timeReceived, "time() Failed");
        }

        [Test]
        public void ThenWithProxyItShouldReturnTimeStamp()
        {
            PubnubProxy proxy = new PubnubProxy();
            proxy.ProxyServer = "test.pandu.com";
            proxy.ProxyPort = 808;
            proxy.ProxyUserName = "tuvpnfreeproxy";
            proxy.ProxyPassword = "Rx8zW78k";

            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            pubnub.Proxy = proxy;

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenGetRequestServerTime";
            unitTest.TestCaseName = "ThenWithProxyItShouldReturnTimeStamp";

            pubnub.PubnubUnitTest = unitTest;

            pubnub.Time<string>(ReturnProxyPresenceTimeStampCallback);
            mreProxy.WaitOne(310 * 1000);
            Assert.IsTrue(timeReceivedWhenProxy, "time() Failed");
        }

        private void ReturnTimeStampCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    string time = deserializedMessage[0].ToString();
                    Int64 nanoTime;
                    if (time.Length > 2 && Int64.TryParse(time, out nanoTime))
                    {
                        timeReceived = true;
                    }
                }
            }
            mreTime.Set();
        }

        private void ReturnProxyPresenceTimeStampCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    string time = deserializedMessage[0].ToString();
                    Int64 nanoTime;
                    if (time.Length > 2 && Int64.TryParse(time, out nanoTime))
                    {
                        timeReceivedWhenProxy = true;
                    }
                }
            }
            mreProxy.Set();
        }

        [Test]
        public void TranslateDateTimeToUnixTime()
        {
            //Test for 26th June 2012 GMT
            DateTime dt = new DateTime(2012,6,26,0,0,0,DateTimeKind.Utc);
            long nanoSecondTime = Pubnub.TranslateDateTimeToPubnubUnixNanoSeconds(dt);
            Assert.AreEqual(13406688000000000, nanoSecondTime);
        }

        [Test]
        public void TranslateUnixTimeToDateTime()
        {
            //Test for 26th June 2012 GMT
            DateTime expectedDate = new DateTime(2012, 6, 26, 0, 0, 0, DateTimeKind.Utc);
            DateTime actualDate = Pubnub.TranslatePubnubUnixNanoSecondsToDateTime(13406688000000000);
            Assert.AreEqual(expectedDate, actualDate);
        }
    }
}
