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
using Microsoft.Silverlight.Testing;

namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenAMessageIsPublished : SilverlightTest
    {
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

        bool isCheck = false;
        bool isUnencryptCheck = false;
        bool isUnencryptObjectPubCheck = false;
        bool isUnencryptObjectDHCheck = false;
        bool isEncryptObjectPubCheck = false;
        bool isEncryptObjectDHCheck = false;
        bool isEncryptPubCheck = false;
        bool isEncryptDHCheck = false;
        bool isSecretEncryptPubCheck = false;
        bool isSecretEncryptDHCheck = false;
        bool isCkeck2 = false;
        bool isCkeck3 = false;

        [TestMethod]
        [Asynchronous]
        public void ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptPublished = false;
            Pubnub pubnub = new Pubnub("demo","demo","","",false);
            string channel = "my/channel";
            string message = messageForUnencryptPublish;

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSuccessUnencryptPublishCodeCallback));
            EnqueueConditional(() => isCheck);

            EnqueueCallback(() => 
            {
                if (!isUnencryptPublished)
                {
                    Assert.IsTrue(isUnencryptPublished, "Unencrypt Publish Failed");
                }
                else
                {
                    EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, unEncryptPublishTimetoken, -1, false, CaptureUnencryptDetailedHistoryCallback));
                    EnqueueConditional(() => isUnencryptCheck);
                    EnqueueCallback(() => Assert.IsTrue(isUnencryptDH, "Unable to match the successful unencrypt Publish"));
                }
            });

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSuccessUnencryptPublishCodeCallback(string result)
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
            isCheck = true;
        }

        [Asynchronous]
        public void CaptureUnencryptDetailedHistoryCallback(string result)
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

            isUnencryptCheck = true;
        }

        [TestMethod]
        [Asynchronous]
        public void ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isUnencryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
            string channel = "my/channel";

            object message = new CustomClass();
            messageObjectForUnencryptPublish = JsonConvert.SerializeObject(message);

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSuccessUnencryptObjectPublishCodeCallback));
            EnqueueConditional(() => isUnencryptObjectPubCheck);

            EnqueueCallback(() =>
            {
                if (!isUnencryptObjectPublished)
                {
                    Assert.IsTrue(isUnencryptObjectPublished, "Unencrypt Publish Failed");
                }
                else
                {
                    EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, unEncryptObjectPublishTimetoken, -1, false, CaptureUnencryptObjectDetailedHistoryCallback));
                    EnqueueConditional(() => isUnencryptObjectDHCheck);
                    EnqueueCallback(() => Assert.IsTrue(isUnencryptObjectDH, "Unable to match the successful unencrypt object Publish"));
                }
            });

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSuccessUnencryptObjectPublishCodeCallback(string result)
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
            isUnencryptObjectPubCheck = true;
        }

        [Asynchronous]
        public void CaptureUnencryptObjectDetailedHistoryCallback(string result)
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

            isUnencryptObjectDHCheck = true;
        }

        [TestMethod]
        [Asynchronous]
        public void ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptObjectPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
            string channel = "my/channel";
            object message = new SecretCustomClass();
            messageObjectForEncryptPublish = JsonConvert.SerializeObject(message);

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSuccessEncryptObjectPublishCodeCallback));
            EnqueueConditional(() => isEncryptObjectPubCheck);

            EnqueueCallback(() =>
            {
                if (!isEncryptObjectPublished)
                {
                    Assert.IsTrue(isEncryptObjectPublished, "Encrypt Object Publish Failed");
                }
                else
                {
                   EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, encryptObjectPublishTimetoken, -1, false, CaptureEncryptObjectDetailedHistoryCallback));
                   EnqueueConditional(() => isEncryptObjectDHCheck);
                   EnqueueCallback(() => Assert.IsTrue(isEncryptObjectDH, "Unable to match the successful encrypt object Publish"));
                }
            });

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSuccessEncryptObjectPublishCodeCallback(string result)
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
            isEncryptObjectPubCheck = true;
        }

        [Asynchronous]
        public void CaptureEncryptObjectDetailedHistoryCallback(string result)
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

            isEncryptObjectDHCheck = true;
        }

        [TestMethod]
        [Asynchronous]
        public void ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "", "enigma", false);
            string channel = "my/channel";
            string message = messageForEncryptPublish;

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSuccessEncryptPublishCodeCallback));
            EnqueueConditional(() => isEncryptPubCheck);
       
            EnqueueCallback(() =>
            {
                if (!isEncryptPublished)
                {
                    Assert.IsTrue(isEncryptPublished, "Encrypt Publish Failed");
                }
                else
                {
                    EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, encryptPublishTimetoken, -1, false, CaptureEncryptDetailedHistoryCallback));
                    EnqueueConditional(() => isEncryptDHCheck);
                    EnqueueCallback(() => Assert.IsTrue(isEncryptDH, "Unable to decrypt the successful Publish"));
                }
            });

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSuccessEncryptPublishCodeCallback(string result)
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
            isEncryptPubCheck = true;
        }

        [Asynchronous]
        public void CaptureEncryptDetailedHistoryCallback(string result)
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

            isEncryptDHCheck = true;
        }

        [TestMethod]
        [Asynchronous]
        public void ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            isSecretEncryptPublished = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "key", "enigma", false);
            string channel = "my/channel";
            string message = messageForSecretEncryptPublish;

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSuccessSecretEncryptPublishCodeCallback));
            EnqueueConditional(() => isSecretEncryptPubCheck);

            EnqueueCallback(() =>
            {
                if (!isSecretEncryptPublished)
                {
                    Assert.IsTrue(isSecretEncryptPublished, "Secret Encrypt Publish Failed");
                }
                else
                {
                    EnqueueCallback(() => pubnub.detailedHistory<string>(channel, -1, secretEncryptPublishTimetoken, -1, false, CaptureSecretEncryptDetailedHistoryCallback));
                    EnqueueConditional(() => isSecretEncryptDHCheck);
                    EnqueueCallback(() => Assert.IsTrue(isSecretEncryptDH, "Unable to decrypt the successful Secret key Publish"));
                }
            });

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSuccessSecretEncryptPublishCodeCallback(string result)
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
            isSecretEncryptPubCheck = true;
        }

        [Asynchronous]
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

            isSecretEncryptDHCheck = true;
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
        [Asynchronous]
        public void ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            isPublished2 = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "key");
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnSecretKeyPublishCallback));
            EnqueueConditional(() => isCkeck2);
            EnqueueCallback(() => Assert.IsTrue(isPublished2, "Publish Failed with secret key"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnSecretKeyPublishCallback(string result)
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
            isCkeck2 = true;
        }

        [TestMethod]
        [Asynchronous]
        public void IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            isPublished3 = false;
            Pubnub pubnub = new Pubnub("demo", "demo", "");
            string channel = "my/channel";
            string message = "Pubnub API Usage Example";

            EnqueueCallback(() => pubnub.publish<string>(channel, message, ReturnNoSSLDefaultFalseCallback));
            EnqueueConditional(() => isCkeck3);
            EnqueueCallback(() => Assert.IsTrue(isPublished3, "Publish Failed with no SSL"));

            EnqueueTestComplete();
        }

        [Asynchronous]
        public void ReturnNoSSLDefaultFalseCallback(string result)
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
            isCkeck3 = true;
        }
    }
}
