using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class WhenGetRequestServerTime
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        bool timeReceived = false;

        [TestMethod]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            pubnub.time<string>(ReturnTimeStampCallback);
            manualEvent1.WaitOne(310 * 1000);
            Assert.IsTrue(timeReceived, "time() Failed");
        }

        private void ReturnTimeStampCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                IList receivedObj = (IList)js.DeserializeObject(result);
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

        [TestMethod]
        public void TranslateDateTimeToUnixTime()
        {
            //Test for 26th June 2012 GMT
            DateTime dt = new DateTime(2012,6,26,0,0,0,DateTimeKind.Utc);
            long nanosecTime = Pubnub.translateDateTimeToPubnubUnixNanoSeconds(dt);
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
