using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using Microsoft.Silverlight.Testing;

namespace PubNub_Messaging
{
    [TestClass]
    public class WhenGetRequestServerTime : SilverlightTest
    {
        bool isTimeStamp = false;
        bool timeReceived = false;

        [TestMethod]
        [Asynchronous]
        public void ThenItShouldReturnTimeStamp()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            EnqueueCallback(() => pubnub.time<string>(ReturnTimeStampCallback));
            EnqueueConditional(() => isTimeStamp);
            EnqueueCallback(() => Assert.IsTrue(timeReceived, "time() Failed"));
            EnqueueTestComplete();
        }

        [Asynchronous]
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
            isTimeStamp = true;
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
