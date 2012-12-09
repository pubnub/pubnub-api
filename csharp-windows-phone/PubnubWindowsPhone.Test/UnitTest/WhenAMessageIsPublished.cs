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

                    pubnub.publish<string>(channel, message, ReturnSuccessUnencryptPublishCodeCallback);
                    manualEvent1.WaitOne(310 * 1000);

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
                        pubnub.detailedHistory<string>(channel, -1, unEncryptPublishTimetoken, -1, false, CaptureUnencryptDetailedHistoryCallback);
                        mreUnencryptDH.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptDH, "Unable to match the successful unencrypt Publish");
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

                    pubnub.publish<string>(channel, message, ReturnSuccessUnencryptObjectPublishCodeCallback);
                    mreUnencryptObjectPub.WaitOne(310 * 1000);

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
                        pubnub.detailedHistory<string>(channel, -1, unEncryptObjectPublishTimetoken, -1, false, CaptureUnencryptObjectDetailedHistoryCallback);
                        mreUnencryptObjectDH.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isUnencryptObjectDH, "Unable to match the successful unencrypt object Publish");
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

                    pubnub.publish<string>(channel, message, ReturnSuccessEncryptObjectPublishCodeCallback);
                    mreEncryptObjectPub.WaitOne(310 * 1000);

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
                        pubnub.detailedHistory<string>(channel, -1, encryptObjectPublishTimetoken, -1, false, CaptureEncryptObjectDetailedHistoryCallback);
                        mreEncryptObjectDH.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptObjectDH, "Unable to match the successful encrypt object Publish");
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

                    pubnub.publish<string>(channel, message, ReturnSuccessEncryptPublishCodeCallback);
                    mreEncryptPub.WaitOne(310 * 1000);

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
                        pubnub.detailedHistory<string>(channel, -1, encryptPublishTimetoken, -1, false, CaptureEncryptDetailedHistoryCallback);
                        mreEncryptDH.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isEncryptDH, "Unable to decrypt the successful Publish");
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

                    pubnub.publish<string>(channel, message, ReturnSuccessSecretEncryptPublishCodeCallback);
                    mreSecretEncryptPub.WaitOne(310 * 1000);

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
                        pubnub.detailedHistory<string>(channel, -1, secretEncryptPublishTimetoken, -1, false, CaptureSecretEncryptDetailedHistoryCallback);
                        mreSecretEncryptDH.WaitOne(310 * 1000);
                        Deployment.Current.Dispatcher.BeginInvoke(() =>
                       {
                           Assert.IsTrue(isSecretEncryptDH, "Unable to decrypt the successful Secret key Publish");
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

        [Asynchronous]
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

        [Asynchronous]
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

        [Asynchronous]
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

        [Asynchronous]
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

        [Asynchronous]
        private void CaptureUnencryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null && jArr[0].ToString() == messageForUnencryptPublish)
                    {
                        isUnencryptDH = true;
                    }
                }
            }

            mreUnencryptDH.Set();
        }

        [Asynchronous]
        private void CaptureUnencryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null && jArr[0].ToString(Formatting.None) == messageObjectForUnencryptPublish)
                    {
                        isUnencryptObjectDH = true;
                    }
                }
            }

            mreUnencryptObjectDH.Set();
        }

        [Asynchronous]
        private void CaptureEncryptObjectDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    //JArray jArr = JArray.Parse(receivedObj[0].ToString());
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null && jArr[0].ToString(Formatting.None) == messageObjectForEncryptPublish)
                    {
                        isEncryptObjectDH = true;
                    }
                }
            }

            mreEncryptObjectDH.Set();
        }

        [Asynchronous]
        private void CaptureEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null && jArr[0].ToString() == messageForEncryptPublish)
                    {
                        isEncryptDH = true;
                    }
                }
            }

            mreEncryptDH.Set();
        }

        [Asynchronous]
        private void CaptureSecretEncryptDetailedHistoryCallback(string result)
        {
            if (!string.IsNullOrWhiteSpace(result))
            {
                object[] receivedObj = JsonConvert.DeserializeObject<object[]>(result);
                if (receivedObj is object[])
                {
                    JArray jArr = receivedObj[0] as JArray;
                    if (jArr != null && jArr[0].ToString() == messageForSecretEncryptPublish)
                    {
                        isSecretEncryptDH = true;
                    }
                }
            }

            mreSecretEncryptDH.Set();
        }

        [TestMethod, Asynchronous]
        public void ThenPubnubShouldGenerateUniqueIdentifier()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                               {
                                   Assert.IsNotNull(pubnub.generateGUID());
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
                        pubnub.publish<string>(channel, message, null);
                    }
                    catch (MissingFieldException mfe)
                    {
                        isExpectedException = true;
                    }
                    catch (Exception ex)
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

                    pubnub.publish<string>(channel, message, ReturnSecretKeyPublishCallback);
                    manualEvent2.WaitOne(310 * 1000);
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

        [TestMethod,Asynchronous]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    isPublished3 = false;
                    Pubnub pubnub = new Pubnub("demo", "demo", "");
                    string channel = "my/channel";
                    string message = "Pubnub API Usage Example";

                    pubnub.publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback);
                    manualEvent3.WaitOne(310 * 1000);
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
                    });
            }
            manualEvent3.Set();
        }
    }
}
