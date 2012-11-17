using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubnubSilverlight.Core;

namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenAMessageIsPublished
    {
        ManualResetEvent manualEvent1 = new ManualResetEvent(false);
        ManualResetEvent manualEvent2 = new ManualResetEvent(false);
        ManualResetEvent manualEvent3 = new ManualResetEvent(false);

        ManualResetEvent mreUnencryptObjectPub = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectPub = new ManualResetEvent(false);
        ManualResetEvent mreEncryptPub = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptPub = new ManualResetEvent(false);
        ManualResetEvent mreEncryptDH = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptDH = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptDH = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptObjectDH = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectDH = new ManualResetEvent(false);

        bool isPublished2 = false;
        bool isPublished3 = false;

        bool isUnencryptPublished = false;
        bool isUnencryptObjectPublished = false;
        bool isEncryptObjectPublished = false;
        bool isUnencryptDH = false;
        bool isUnencryptObjectDH = false;
        bool isEncryptObjectDH = false;
        bool isEncryptPublished = false;
        bool isSecretEncryptPublished = false;
        bool isEncryptDH = false;
        bool isSecretEncryptDH = false;

        long unEncryptPublishTimetoken = 0;
        long unEncryptObjectPublishTimetoken = 0;
        long encryptObjectPublishTimetoken = 0;
        long encryptPublishTimetoken = 0;
        long secretEncryptPublishTimetoken = 0;

        const string messageForUnencryptPublish = "Pubnub Messaging API 1";
        const string messageForEncryptPublish = "漢語";
        const string messageForSecretEncryptPublish = "Pubnub Messaging API 2";
        string messageObjectForUnencryptPublish = "";
        string messageObjectForEncryptPublish = "";

        [TestMethod]
        public void ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptPublished = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);
            string channel = "my/channel";
            string message = messageForUnencryptPublish;

            pubnub.publish<string>(channel, message, ReturnSuccessUnencryptPublishCodeCallback);
            manualEvent1.WaitOne(310*1000);

            if (!isUnencryptPublished)
            {
                Assert.IsTrue(isUnencryptPublished, "Unencrypt Publish Failed");
            }
            else
            {
                pubnub.detailedHistory<string>(channel, -1, unEncryptPublishTimetoken, -1, false, CaptureUnencryptDetailedHistoryCallback);
                mreUnencryptDH.WaitOne(310 * 1000);
                Assert.IsTrue(isUnencryptDH, "Unable to match the successful unencrypt Publish");
            }
        }

        [TestMethod]
        public void ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";
            object message = new CustomClass();
            messageObjectForUnencryptPublish = JsonConvert.SerializeObject(message);

            pubnub.publish<string>(channel, message, ReturnSuccessUnencryptObjectPublishCodeCallback);
            mreUnencryptObjectPub.WaitOne(310 * 1000);

            if (!isUnencryptObjectPublished)
            {
                Assert.IsTrue(isUnencryptObjectPublished, "Unencrypt Publish Failed");
            }
            else
            {
                pubnub.detailedHistory<string>(channel, -1, unEncryptObjectPublishTimetoken, -1, false, CaptureUnencryptObjectDetailedHistoryCallback);
                mreUnencryptObjectDH.WaitOne(310 * 1000);
                Assert.IsTrue(isUnencryptObjectDH, "Unable to match the successful unencrypt object Publish");
            }
        }

        [TestMethod]
        public void ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
            string channel = "my/channel";
            object message = new SecretCustomClass();
            messageObjectForEncryptPublish = JsonConvert.SerializeObject(message);

            pubnub.publish<string>(channel, message, ReturnSuccessEncryptObjectPublishCodeCallback);
            mreEncryptObjectPub.WaitOne(310 * 1000);

            if (!isEncryptObjectPublished)
            {
                Assert.IsTrue(isEncryptObjectPublished, "Encrypt Object Publish Failed");
            }
            else
            {
                pubnub.detailedHistory<string>(channel, -1, encryptObjectPublishTimetoken, -1, false, CaptureEncryptObjectDetailedHistoryCallback);
                mreEncryptObjectDH.WaitOne(310 * 1000);
                Assert.IsTrue(isEncryptObjectDH, "Unable to match the successful encrypt object Publish");
            }
        }

        [TestMethod]
        public void ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
            string channel = "my/channel";
            string message = messageForEncryptPublish;

            pubnub.publish<string>(channel, message, ReturnSuccessEncryptPublishCodeCallback);
            mreEncryptPub.WaitOne(310 * 1000);

            if (!isEncryptPublished)
            {
                Assert.IsTrue(isEncryptPublished, "Encrypt Publish Failed");
            }
            else
            {
                pubnub.detailedHistory<string>(channel, -1, encryptPublishTimetoken, -1, false, CaptureEncryptDetailedHistoryCallback);
                mreEncryptDH.WaitOne(310 * 1000);
                Assert.IsTrue(isEncryptDH, "Unable to decrypt the successful Publish");
            }
        }

        [TestMethod]
        public void ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isSecretEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "key", "enigma", false);
            string channel = "my/channel";
            string message = messageForSecretEncryptPublish;

            pubnub.publish<string>(channel, message, ReturnSuccessSecretEncryptPublishCodeCallback);
            mreSecretEncryptPub.WaitOne(310 * 1000);

            if (!isSecretEncryptPublished)
            {
                Assert.IsTrue(isSecretEncryptPublished, "Secret Encrypt Publish Failed");
            }
            else
            {
                pubnub.detailedHistory<string>(channel, -1, secretEncryptPublishTimetoken, -1, false, CaptureSecretEncryptDetailedHistoryCallback);
                mreSecretEncryptDH.WaitOne(310 * 1000);
                Assert.IsTrue(isSecretEncryptDH, "Unable to decrypt the successful Secret key Publish");
            }
        }

        private void ReturnSuccessUnencryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isUnencryptPublished = true;
                        unEncryptPublishTimetoken = Convert.ToInt64(receivedObj[2].ToString());
                    }
                }
            }
            manualEvent1.Set();
        }

        private void ReturnSuccessUnencryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isUnencryptObjectPublished = true;
                        unEncryptObjectPublishTimetoken = Convert.ToInt64(receivedObj[2].ToString());
                    }
                }
            }
            mreUnencryptObjectPub.Set();
        }

        private void ReturnSuccessEncryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isEncryptObjectPublished = true;
                        encryptObjectPublishTimetoken = Convert.ToInt64(receivedObj[2].ToString());
                    }
                }
            }
            mreEncryptObjectPub.Set();
        }

        private void ReturnSuccessEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isEncryptPublished = true;
                        encryptPublishTimetoken = Convert.ToInt64(receivedObj[2].ToString());
                    }
                }
            }
            mreEncryptPub.Set();
        }

        private void ReturnSuccessSecretEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isSecretEncryptPublished = true;
                        secretEncryptPublishTimetoken = Convert.ToInt64(receivedObj[2].ToString());
                    }
                }
            }
            mreSecretEncryptPub.Set();
        }

        private void CaptureUnencryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jObj = JArray.Parse(receivedObj[0].ToString());
                    if (jObj[0].ToString() == messageForUnencryptPublish)
                    {
                        isUnencryptDH = true;
                    }
                }
            }

            mreUnencryptDH.Set();
        }

        private void CaptureUnencryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = JArray.Parse(receivedObj[0].ToString());
                    if (jArr[0].ToString(Formatting.None) == messageObjectForUnencryptPublish)
                    {
                        isUnencryptObjectDH = true;
                    }
                }
            }

            mreUnencryptObjectDH.Set();
        }

        private void CaptureEncryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = JArray.Parse(receivedObj[0].ToString());
                    if (jArr[0].ToString(Formatting.None) == messageObjectForEncryptPublish)
                    {
                        isEncryptObjectDH = true;
                    }
                }
            }

            mreEncryptObjectDH.Set();
        }

        private void CaptureEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = JArray.Parse(receivedObj[0].ToString());
                    if (jArr[0].ToString() == messageForEncryptPublish)
                    {
                        isEncryptDH = true;
                    }
                }
            }

            mreEncryptDH.Set();
        }

        private void CaptureSecretEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = JArray.Parse(receivedObj[0].ToString());
                    if (jArr[0].ToString() == messageForSecretEncryptPublish)
                    {
                        isSecretEncryptDH = true;
                    }
                }
            }

            mreSecretEncryptDH.Set();
        }

        [TestMethod]
        public void ThenPubnubShouldGenerateUniqueIdentifier()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            Assert.IsNotNull(pubnub.generateGUID());
        }

        [TestMethod]
        [ExpectedException(typeof(MissingFieldException))]
        public void ThenPublishKeyShouldNotBeEmpty()
        {
            Pubnub pubnub = new Pubnub("", "demo", "", "", false);

            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, null);
        }


        [TestMethod]
        public void ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            isPublished2 = false;
            Pubnub pubnub = new Pubnub("demo","demo","key");
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, ReturnSecretKeyPublishCallback);
            manualEvent2.WaitOne(310 * 1000);

            Assert.IsTrue(isPublished2, "Publish Failed with secret key");
        }

        private void ReturnSecretKeyPublishCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isPublished2 = true;
                    }
                }
            }
            manualEvent2.Set();
        }

        [TestMethod]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            isPublished3 = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "");
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback);
            manualEvent3.WaitOne(310 * 1000);
            Assert.IsTrue(isPublished3, "Publish Failed with no SSL");
        }

        private void ReturnNoSSLDefaultFalseCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    long statusCode = Int64.Parse(receivedObj[0].ToString());
                    string statusMsg = (string)receivedObj[1];
                    if (statusCode == 1 && statusMsg.ToLower() == "sent")
                    {
                        isPublished3 = true;
                    }
                }
            }
            manualEvent3.Set();
        }
    }
}
