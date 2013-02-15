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
    public class WhenAMessageIsPublished
    {
        ManualResetEvent mreUnencryptedPublish = new ManualResetEvent(false);
        ManualResetEvent mreOptionalSecretKeyPublish = new ManualResetEvent(false);
        ManualResetEvent mreNoSslPublish = new ManualResetEvent(false);

        ManualResetEvent mreUnencryptObjectPublish = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectPublish = new ManualResetEvent(false);
        ManualResetEvent mreEncryptPublish = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptPublish = new ManualResetEvent(false);
        ManualResetEvent mreComplexObjectPublish = new ManualResetEvent(false);

        ManualResetEvent mreEncryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptObjectDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreComplexObjectDetailedHistory = new ManualResetEvent(false);

        bool isPublished2 = false;
        bool isPublished3 = false;

        bool isUnencryptPublished = false;
        bool isUnencryptObjectPublished = false;
        bool isEncryptObjectPublished = false;
        bool isUnencryptDetailedHistory = false;
        bool isUnencryptObjectDetailedHistory = false;
        bool isEncryptObjectDetailedHistory = false;
        bool isEncryptPublished = false;
        bool isSecretEncryptPublished = false;
        bool isEncryptDetailedHistory = false;
        bool isSecretEncryptDetailedHistory = false;
        bool isComplexObjectPublished = false;
        bool isComplexObjectDetailedHistory = false;

        long unEncryptPublishTimetoken = 0;
        long unEncryptObjectPublishTimetoken = 0;
        long encryptObjectPublishTimetoken = 0;
        long encryptPublishTimetoken = 0;
        long secretEncryptPublishTimetoken = 0;
        long complexObjectPublishTimetoken = 0;

        const string messageForUnencryptPublish = "Pubnub Messaging API 1";
        const string messageForEncryptPublish = "漢語";
        const string messageForSecretEncryptPublish = "Pubnub Messaging API 2";
        string messageObjectForUnencryptPublish = "";
        string messageObjectForEncryptPublish = "";
        string messageComplexObjectForPublish = "";

        [Test]
        public void ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptPublished = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);
            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenUnencryptPublishShouldReturnSuccessCodeAndInfo";
            pubnub.PubnubUnitTest = unitTest;
            string channel = "my/channel";
            string message = messageForUnencryptPublish;

            pubnub.Publish<string>(channel, message, ReturnSuccessUnencryptPublishCodeCallback);
            mreUnencryptedPublish.WaitOne(310*1000);

            if (!isUnencryptPublished)
            {
                Assert.IsTrue(isUnencryptPublished, "Unencrypt Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, unEncryptPublishTimetoken, -1, false, CaptureUnencryptDetailedHistoryCallback);
                mreUnencryptDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isUnencryptDetailedHistory, "Unable to match the successful unencrypt Publish");
            }
        }

        [Test]
        public void ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo";
            pubnub.PubnubUnitTest = unitTest;
            string channel = "my/channel";
            object message = new CustomClass();
            messageObjectForUnencryptPublish = JsonConvert.SerializeObject(message);

            pubnub.Publish<string>(channel, message, ReturnSuccessUnencryptObjectPublishCodeCallback);
            mreUnencryptObjectPublish.WaitOne(310 * 1000);

            if (!isUnencryptObjectPublished)
            {
                Assert.IsTrue(isUnencryptObjectPublished, "Unencrypt Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, unEncryptObjectPublishTimetoken, -1, false, CaptureUnencryptObjectDetailedHistoryCallback);
                mreUnencryptObjectDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isUnencryptObjectDetailedHistory, "Unable to match the successful unencrypt object Publish");
            }
        }

        [Test]
        public void ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
            
            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";
            object message = new SecretCustomClass();
            messageObjectForEncryptPublish = JsonConvert.SerializeObject(message);

            pubnub.Publish<string>(channel, message, ReturnSuccessEncryptObjectPublishCodeCallback);
            mreEncryptObjectPublish.WaitOne(310 * 1000);

            if (!isEncryptObjectPublished)
            {
                Assert.IsTrue(isEncryptObjectPublished, "Encrypt Object Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, encryptObjectPublishTimetoken, -1, false, CaptureEncryptObjectDetailedHistoryCallback);
                mreEncryptObjectDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isEncryptObjectDetailedHistory, "Unable to match the successful encrypt object Publish");
            }
        }

        [Test]
        public void ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenEncryptPublishShouldReturnSuccessCodeAndInfo";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";
            string message = messageForEncryptPublish;

            pubnub.Publish<string>(channel, message, ReturnSuccessEncryptPublishCodeCallback);
            mreEncryptPublish.WaitOne(310 * 1000);

            if (!isEncryptPublished)
            {
                Assert.IsTrue(isEncryptPublished, "Encrypt Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, encryptPublishTimetoken, -1, false, CaptureEncryptDetailedHistoryCallback);
                mreEncryptDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isEncryptDetailedHistory, "Unable to decrypt the successful Publish");
            }
        }

        [Test]
        public void ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isSecretEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "key", "enigma", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";
            string message = messageForSecretEncryptPublish;

            pubnub.Publish<string>(channel, message, ReturnSuccessSecretEncryptPublishCodeCallback);
            mreSecretEncryptPublish.WaitOne(310 * 1000);

            if (!isSecretEncryptPublished)
            {
                Assert.IsTrue(isSecretEncryptPublished, "Secret Encrypt Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, secretEncryptPublishTimetoken, -1, false, CaptureSecretEncryptDetailedHistoryCallback);
                mreSecretEncryptDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isSecretEncryptDetailedHistory, "Unable to decrypt the successful Secret key Publish");
            }
        }

        [Test]
        public void ThenComplexMessageObjectShouldReturnSuccessCodeAndInfo()
        {
            isComplexObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenComplexMessageObjectShouldReturnSuccessCodeAndInfo";
            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";
            object message = new PubnubDemoObject();
            messageComplexObjectForPublish = JsonConvert.SerializeObject(message);

            pubnub.Publish<string>(channel, message, ReturnSuccessComplexObjectPublishCodeCallback);
            mreComplexObjectPublish.WaitOne(310 * 1000);

            if (!isComplexObjectPublished)
            {
                Assert.IsTrue(isComplexObjectPublished, "Complex Object Publish Failed");
            }
            else
            {
                pubnub.DetailedHistory<string>(channel, -1, complexObjectPublishTimetoken, -1, false, CaptureComplexObjectDetailedHistoryCallback);
                mreComplexObjectDetailedHistory.WaitOne(310 * 1000);
                Assert.IsTrue(isComplexObjectDetailedHistory, "Unable to match the successful unencrypt object Publish");
            }
        }

        private void ReturnSuccessUnencryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isUnencryptPublished = true;
                        unEncryptPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }
            mreUnencryptedPublish.Set();
        }

        private void ReturnSuccessUnencryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isUnencryptObjectPublished = true;
                        unEncryptObjectPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }
            mreUnencryptObjectPublish.Set();
        }

        private void ReturnSuccessEncryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isEncryptObjectPublished = true;
                        encryptObjectPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }
            mreEncryptObjectPublish.Set();
        }

        private void ReturnSuccessEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isEncryptPublished = true;
                        encryptPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }
            mreEncryptPublish.Set();
        }

        private void ReturnSuccessSecretEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isSecretEncryptPublished = true;
                        secretEncryptPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }
            mreSecretEncryptPublish.Set();
        }

        private void CaptureUnencryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString() == messageForUnencryptPublish)
                    {
                        isUnencryptDetailedHistory = true;
                    }
                }
            }

            mreUnencryptDetailedHistory.Set();
        }

        private void CaptureUnencryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString(Formatting.None) == messageObjectForUnencryptPublish)
                    {
                        isUnencryptObjectDetailedHistory = true;
                    }
                }
            }

            mreUnencryptObjectDetailedHistory.Set();
        }

        private void CaptureEncryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString(Formatting.None) == messageObjectForEncryptPublish)
                    {
                        isEncryptObjectDetailedHistory = true;
                    }
                }
            }

            mreEncryptObjectDetailedHistory.Set();
        }

        private void CaptureEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString() == messageForEncryptPublish)
                    {
                        isEncryptDetailedHistory = true;
                    }
                }
            }

            mreEncryptDetailedHistory.Set();
        }

        private void CaptureSecretEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedResult = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedResult is object[])
                {
                    JArray message = deserializedResult[0] as JArray;
                    if (message != null && message[0].ToString() == messageForSecretEncryptPublish)
                    {
                        isSecretEncryptDetailedHistory = true;
                    }
                }
            }

            mreSecretEncryptDetailedHistory.Set();
        }

        private void ReturnSuccessComplexObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isComplexObjectPublished = true;
                        complexObjectPublishTimetoken = Convert.ToInt64(deserializedMessage[2].ToString());
                    }
                }
            }

            mreComplexObjectPublish.Set();

        }

        private void CaptureComplexObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString(Formatting.None) == messageComplexObjectForPublish)
                    {
                        isComplexObjectDetailedHistory = true;
                    }
                }
            }

            mreComplexObjectDetailedHistory.Set();
        }

        [Test]
        public void ThenPubnubShouldGenerateUniqueIdentifier()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            Assert.IsNotNull(pubnub.GenerateGuid());
        }

        [Test]
        [ExpectedException(typeof(MissingFieldException))]
        public void ThenPublishKeyShouldNotBeEmpty()
        {
            Pubnub pubnub = new Pubnub("", "demo", "", "", false);

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenPublishKeyShouldNotBeEmpty";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.Publish<string>(channel, message, null);
        }


        [Test]
        public void ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            isPublished2 = false;
            Pubnub pubnub = new Pubnub("demo","demo","key");

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "ThenOptionalSecretKeyShouldBeProvidedInConstructor";

            pubnub.PubnubUnitTest = unitTest;


            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.Publish<string>(channel, message, ReturnSecretKeyPublishCallback);
            mreOptionalSecretKeyPublish.WaitOne(310 * 1000);

            Assert.IsTrue(isPublished2, "Publish Failed with secret key");
        }

        private void ReturnSecretKeyPublishCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedResult = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedResult is object[])
                {
                    long statusCode = Int64.Parse(deserializedResult[0].ToString());
                    string statusMessage = (string)deserializedResult[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isPublished2 = true;
                    }
                }
            }
            mreOptionalSecretKeyPublish.Set();
        }

        [Test]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            isPublished3 = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "");

            PubnubUnitTest unitTest = new PubnubUnitTest();
            unitTest.TestClassName = "WhenAMessageIsPublished";
            unitTest.TestCaseName = "IfSSLNotProvidedThenDefaultShouldBeFalse";

            pubnub.PubnubUnitTest = unitTest;

            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            pubnub.Publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback);
            mreNoSslPublish.WaitOne(310 * 1000);
            Assert.IsTrue(isPublished3, "Publish Failed with no SSL");
        }

        private void ReturnNoSSLDefaultFalseCallback(string result)
        {
            if (!string.IsNullOrEmpty(result) && !string.IsNullOrEmpty(result.Trim()))
            {
                object[] deserializedResult = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedResult is object[])
                {
                    long statusCode = Int64.Parse(deserializedResult[0].ToString());
                    string statusMessage = (string)deserializedResult[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isPublished3 = true;
                    }
                }
            }
            mreNoSslPublish.Set();
        }
    }
}
