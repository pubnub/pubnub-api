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
using PubNubMessaging.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Utilities;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Serialization;
using System.Threading;
//using System.Collections.Generic;
using System.Runtime.Serialization.Json;

namespace PubnubWindowsPhone.Test.UnitTest
{
    [TestClass]
    public class WhenAMessageIsPublished : WorkItemTest
    {
        JsonSerializer serializer = new JsonSerializer();

        ManualResetEvent mreUnencryptedPublish = new ManualResetEvent(false);
        ManualResetEvent mreOptionalSecretKeyPublish = new ManualResetEvent(false);
        ManualResetEvent mreNoSslPublish = new ManualResetEvent(false);

        ManualResetEvent mreUnencryptObjectPublish = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectPublish = new ManualResetEvent(false);
        ManualResetEvent mreEncryptPublish = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptPublish = new ManualResetEvent(false);
        ManualResetEvent mreEncryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreSecretEncryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreUnencryptObjectDetailedHistory = new ManualResetEvent(false);
        ManualResetEvent mreEncryptObjectDetailedHistory = new ManualResetEvent(false);

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

        System.Collections.Generic.List<string> errors = new System.Collections.Generic.List<string>();

        [TestMethod, Asynchronous]
        public void ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isUnencryptPublished = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";
                    string message = messageForUnencryptPublish;

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenUnencryptPublishShouldReturnSuccessCodeAndInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSuccessUnencryptPublishCodeCallback);
                    mreUnencryptedPublish.WaitOne(310 * 1000);

                    if (!isUnencryptPublished)
                    {
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptPublished, "Unencrypt Publish Failed");
                           TestComplete();
                       });
                    }
                    else
                    {
                        pubnub.DetailedHistory<string>(channel, -1, unEncryptPublishTimetoken, -1, false, CaptureUnencryptDetailedHistoryCallback);
                        mreUnencryptDetailedHistory.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptDetailedHistory, "Unable to match the successful unencrypt Publish");
                           TestComplete();
                       });
                    }
                });
        }

        [TestMethod, Asynchronous]
        public void ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isUnencryptObjectPublished = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
                    string channel = "my/channel";
                    object message = new CustomClass();
                    messageObjectForUnencryptPublish = JsonConvert.SerializeObject(message);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSuccessUnencryptObjectPublishCodeCallback);
                    mreUnencryptObjectPublish.WaitOne(310 * 1000);

                    if (!isUnencryptObjectPublished)
                    {
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptObjectPublished, "Unencrypt Publish Failed");
                           TestComplete();
                       });
                    }
                    else
                    {
                        pubnub.DetailedHistory<string>(channel, -1, unEncryptObjectPublishTimetoken, -1, false, CaptureUnencryptObjectDetailedHistoryCallback);
                        mreUnencryptObjectDetailedHistory.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptObjectDetailedHistory, "Unable to match the successful unencrypt object Publish");
                           TestComplete();
                       });
                    }
                });
        }

        [TestMethod, Asynchronous]
        public void ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isEncryptObjectPublished = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
                    string channel = "my/channel";
                    
                    object message = new SecretCustomClass();

                    messageObjectForEncryptPublish = JsonConvert.SerializeObject(message);

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSuccessEncryptObjectPublishCodeCallback);
                    mreEncryptObjectPublish.WaitOne(310 * 1000);

                    if (!isEncryptObjectPublished)
                    {
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptObjectPublished, "Encrypt Object Publish Failed");
                           TestComplete();
                       });
                    }
                    else
                    {
                        pubnub.DetailedHistory<string>(channel, -1, encryptObjectPublishTimetoken, -1, false, CaptureEncryptObjectDetailedHistoryCallback);
                        mreEncryptObjectDetailedHistory.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptObjectDetailedHistory, "Unable to match the successful encrypt object Publish");
                           TestComplete();
                       });
                    }
                });
        }


        [TestMethod, Asynchronous]
        public void ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isEncryptPublished = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
                    string channel = "my/channel";
                    string message = messageForEncryptPublish;

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenEncryptPublishShouldReturnSuccessCodeAndInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSuccessEncryptPublishCodeCallback);
                    mreEncryptPublish.WaitOne(310 * 1000);

                    if (!isEncryptPublished)
                    {
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptPublished, "Encrypt Publish Failed");
                           TestComplete();
                       });
                    }
                    else
                    {
                        pubnub.DetailedHistory<string>(channel, -1, encryptPublishTimetoken, -1, false, CaptureEncryptDetailedHistoryCallback);
                        mreEncryptDetailedHistory.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptDetailedHistory, "Unable to decrypt the successful Publish");
                           TestComplete();
                       });
                    }
                });
        }

        [TestMethod, Asynchronous]
        public void ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isSecretEncryptPublished = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "key", "enigma", false);
                    string channel = "my/channel";
                    string message = messageForSecretEncryptPublish;

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSuccessSecretEncryptPublishCodeCallback);
                    mreSecretEncryptPublish.WaitOne(310 * 1000);

                    if (!isSecretEncryptPublished)
                    {
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isSecretEncryptPublished, "Secret Encrypt Publish Failed");
                           TestComplete();
                       });
                    }
                    else
                    {
                        pubnub.DetailedHistory<string>(channel, -1, secretEncryptPublishTimetoken, -1, false, CaptureSecretEncryptDetailedHistoryCallback);
                        mreSecretEncryptDetailedHistory.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isSecretEncryptDetailedHistory, "Unable to decrypt the successful Secret key Publish");
                           TestComplete();
                       });
                    }
                });
        }

        [Asynchronous]
        private void ReturnSuccessUnencryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void ReturnSuccessUnencryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void ReturnSuccessEncryptObjectPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void ReturnSuccessEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void ReturnSuccessSecretEncryptPublishCodeCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void CaptureUnencryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void CaptureUnencryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void CaptureEncryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void CaptureEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
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

        [Asynchronous]
        private void CaptureSecretEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    JArray message = deserializedMessage[0] as JArray;
                    if (message != null && message[0].ToString() == messageForSecretEncryptPublish)
                    {
                        isSecretEncryptDetailedHistory = true;
                    }
                }
            }

            mreSecretEncryptDetailedHistory.Set();
        }

        [TestMethod, Asynchronous]
        public void ThenPubnubShouldGenerateUniqueIdentifier()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                               {
                                   Assert.IsNotNull(pubnub.GenerateGuid());
                                   TestComplete();
                               });
                });

        }

        [TestMethod, Asynchronous]
        public void ThenPublishKeyShouldNotBeEmpty()
        {
            bool isExpectedException = false;
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("", "demo", "", "", false);

                    string channel = "my/channel";
                    string message = "Pubnub API Usage Example";

                    try
                    {
                        pubnub.Publish<string>(channel, message, null);
                    }
                    catch (MissingFieldException)
                    {
                        isExpectedException = true;
                    }
                    catch (Exception)
                    {
                        isExpectedException = false;
                    }
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(isExpectedException);
                            TestComplete();
                        });
                });
        }


        [TestMethod, Asynchronous]
        public void ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isPublished2 = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "key");
                    string channel = "my/channel";
                    string message = "Pubnub API Usage Example";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "ThenOptionalSecretKeyShouldBeProvidedInConstructor";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnSecretKeyPublishCallback);
                    mreOptionalSecretKeyPublish.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                               {
                                   Assert.IsTrue(isPublished2, "Publish Failed with secret key");
                                   TestComplete();
                               });
                });
        }

        [Asynchronous]
        private void ReturnSecretKeyPublishCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                if (deserializedMessage is object[])
                {
                    long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                    string statusMessage = (string)deserializedMessage[1];
                    if (statusCode == 1 && statusMessage.ToLower() == "sent")
                    {
                        isPublished2 = true;
                    }
                }
            }
            mreOptionalSecretKeyPublish.Set();
        }

        [TestMethod,Asynchronous]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isPublished3 = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "");
                    string channel = "my/channel";
                    string message = "Pubnub API Usage Example";

                    PubnubUnitTest unitTest = new PubnubUnitTest();
                    unitTest.TestClassName = "WhenAMessageIsPublished";
                    unitTest.TestCaseName = "IfSSLNotProvidedThenDefaultShouldBeFalse";
                    pubnub.PubnubUnitTest = unitTest;

                    pubnub.Publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback);
                    mreNoSslPublish.WaitOne(310 * 1000);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                               {
                                   Assert.IsTrue(isPublished3, "Publish Failed with no SSL");
                                   TestComplete();
                               });
                });
        }

        [Asynchronous]
        private void ReturnNoSSLDefaultFalseCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                Deployment.Current.Dispatcher.BeginInvoke(() =>
                    {
                        object[] deserializedMessage = JsonConvert.DeserializeObject<object[]>(result);
                        if (deserializedMessage is object[])
                        {
                            long statusCode = Int64.Parse(deserializedMessage[0].ToString());
                            string statusMessage = (string)deserializedMessage[1];
                            if (statusCode == 1 && statusMessage.ToLower() == "sent")
                            {
                                isPublished3 = true;
                            }
                        }
                    });
            }
            mreNoSslPublish.Set();
        }
    }
}
