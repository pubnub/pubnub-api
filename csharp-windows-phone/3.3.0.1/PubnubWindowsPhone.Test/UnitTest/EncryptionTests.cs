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
using System.Collections.Generic;

using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace PubnubWindowsPhone.Test.UnitTest
{

    [TestClass]
    public class EncryptionTests:WorkItemTest
    {
        /// <summary>
        /// Tests the null encryption.
        /// The input is serialized
        /// </summary>
        [TestMethod,Asynchronous]
        public void TestNullEncryption()
        {

            bool isExpectedException = false;

            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //serialized string
                    string strMessage = null;

                    try
                    {
                        //encrypt
                        string enc = pc.encrypt(strMessage);
                    }
                    catch (ArgumentNullException)
                    {
                        isExpectedException = true;
                    }

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.IsTrue(isExpectedException);
                            TestComplete();
                        });
                    
                });
        }

        /// <summary>
        /// Tests the null decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [TestMethod, Asynchronous]
        public void TestNullDecryption()
        {
            bool isExpectedException = false;
            string dec = "";
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = null;
                    try
                    {
                        //decrypt
                        dec = pc.decrypt(strMessage);
                    }
                    catch (ArgumentNullException)
                    {
                        isExpectedException = true;
                    }

                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            //Assert.AreEqual("", dec);
                            Assert.IsTrue(isExpectedException);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is deserialized  
        /// Decrypted string should match yay!
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestYayDecryptionBasic()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    string strMessage = "q/xJqqN6qbiZMXYmiQC1Fw==";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //deserialize again
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("yay!", dec);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match q/xJqqN6qbiZMXYmiQC1Fw==
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestYayEncryptionBasic()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = "yay!";
                    //Encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("q/xJqqN6qbiZMXYmiQC1Fw==", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is not deserialized  
        /// Decrypted and Deserialized string should match yay!
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestYayDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //string strMessage= "\"q/xJqqN6qbiZMXYmiQC1Fw==\"";
                    //Non deserialized string
                    string strMessage = "\"Wi24KS4pcTzvyuGOHubiXg==\"";
                    //Deserialize 
                    strMessage = JsonConvert.DeserializeObject<string>(strMessage);
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //deserialize again
                    strMessage = JsonConvert.DeserializeObject<string>(dec);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("yay!", strMessage);
                            TestComplete();
                        });
                });
        }
        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match Wi24KS4pcTzvyuGOHubiXg==
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestYayEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = "yay!";
                    //serialize the string
                    strMessage = JsonConvert.SerializeObject(strMessage);
                    Console.WriteLine(strMessage);
                    //Encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("Wi24KS4pcTzvyuGOHubiXg==", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the array encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestArrayEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //create an empty array object
                    object[] objArr = { };
                    //serialize
                    string strArr = JsonConvert.SerializeObject(objArr);
                    //Encrypt
                    string enc = pc.encrypt(strArr);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("Ns4TB41JjT2NCXaGLWSPAQ==", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the array decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to been deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestArrayDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //Input the deserialized string
                    string strMessage = "Ns4TB41JjT2NCXaGLWSPAQ==";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //create a serialized object
                    object[] objArr = { };
                    string res = JsonConvert.SerializeObject(objArr);
                    //compare the serialized object and the return of the Decrypt method
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual(res, dec);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the object encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestObjectEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //create an object
                    Object obj = new Object();
                    //serialize
                    string strObj = JsonConvert.SerializeObject(obj);
                    //encrypt
                    string enc = pc.encrypt(strObj);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("IDjZE9BHSjcX67RddfCYYg==", enc);
                            TestComplete();
                        });
                });
        }
        /// <summary>
        /// Tests the object decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to be deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestObjectDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //Deserialized
                    string strMessage = "IDjZE9BHSjcX67RddfCYYg==";
                    //Decrypt
                    string dec = pc.decrypt(strMessage);
                    //create an object
                    Object obj = new Object();
                    //Serialize the object
                    string res = JsonConvert.SerializeObject(obj);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual(res, dec);
                            TestComplete();
                        });
                });
        }
        /// <summary>
        /// Tests my object encryption.
        /// The output is not serialized 
        /// Encrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestMyObjectEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //create an object of the custom class
                    CustomClass cc = new CustomClass();
                    //serialize it
                    string res = JsonConvert.SerializeObject(cc);

                    //encrypt it
                    string enc = pc.encrypt(res);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=", enc);
                            TestComplete();
                        });
                });
        }
        /// <summary>
        /// Tests my object decryption.
        /// The output is not deserialized
        /// Decrypted string should match the serialized object
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestMyObjectDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //Deserialized
                    string strMessage = "Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=";
                    //Decrypt
                    string dec = pc.decrypt(strMessage);
                    //create an object of the custom class
                    CustomClass cc = new CustomClass();

                    //Serialize it
                    string res = JsonConvert.SerializeObject(cc);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual(res, dec);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the pub nub encryption2.
        /// The output is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestPubNubEncryption2()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //Deserialized
                    string strMessage = "Pubnub Messaging API 2";
                    //serialize the message
                    strMessage = JsonConvert.SerializeObject(strMessage);

                    //encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the pub nub decryption2.
        /// Assumes that the input message is deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 2
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestPubNubDecryption2()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //Deserialized string    
                    string strMessage = "f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=";
                    //Decrypt
                    string dec = pc.decrypt(strMessage);
                    //Deserialize
                    strMessage = JsonConvert.DeserializeObject<string>(dec);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("Pubnub Messaging API 2", strMessage);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the pub nub encryption1.
        /// The input is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestPubNubEncryption1()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //non serialized string
                    string strMessage = "Pubnub Messaging API 1";
                    //serialize
                    strMessage = JsonConvert.SerializeObject(strMessage);
                    //encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the pub nub decryption1.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 1        
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestPubNubDecryption1()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //deserialize
                    strMessage = (dec != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(dec) : "";
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("Pubnub Messaging API 1", strMessage);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the stuff can encryption.
        /// The input is serialized
        /// Encrypted string should match zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestStuffCanEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //input serialized string
                    string strMessage = "{\"this stuff\":{\"can get\":\"complicated!\"}}";
                    //encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the stuffcan decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestStuffcanDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = "zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("{\"this stuff\":{\"can get\":\"complicated!\"}}", dec);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the hash encryption.
        /// The input is serialized
        /// Encrypted string should match GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestHashEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //serialized string
                    string strMessage = "{\"foo\":{\"bar\":\"foobar\"}}";
                    //encrypt
                    string enc = pc.encrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the hash decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [TestMethod, Asynchronous]
        public void TestHashDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    //deserialized string
                    string strMessage = "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("{\"foo\":{\"bar\":\"foobar\"}}", dec);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the unicode chars encryption.
        /// The input is not serialized
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestUnicodeCharsEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    string strMessage = "漢語";

                    strMessage = JsonConvert.SerializeObject(strMessage);
                    Console.WriteLine(strMessage);
                    string enc = pc.encrypt(strMessage);
                    Console.WriteLine(enc);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("+BY5/miAA8aeuhVl4d13Kg==", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the unicode decryption.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match the unicode chars       
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestUnicodeCharsDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    string strMessage = "+BY5/miAA8aeuhVl4d13Kg==";
                    //JavaScriptSerializer js = new JavaScriptSerializer();
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //deserialize
                    strMessage = (dec != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(dec) : "";
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("漢語", strMessage);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the german chars decryption.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match the unicode chars  
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestGermanCharsDecryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    string strMessage = "stpgsG1DZZxb44J7mFNSzg==";
                    //decrypt
                    string dec = pc.decrypt(strMessage);
                    //deserialize
                    strMessage = (dec != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(dec) : "";
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("ÜÖ", strMessage);
                            TestComplete();
                        });
                });
        }
        /// <summary>
        /// Tests the german encryption.
        /// The input is not serialized
        /// </summary>
        [TestMethod, Asynchronous]
        public void TestGermanCharsEncryption()
        {
            ThreadPool.QueueUserWorkItem((s) =>
                {
                    PubnubCrypto pc = new PubnubCrypto("enigma");
                    string strMessage = "ÜÖ";

                    strMessage = JsonConvert.SerializeObject(strMessage);
                    Console.WriteLine(strMessage);
                    string enc = pc.encrypt(strMessage);
                    Console.WriteLine(enc);
                    Deployment.Current.Dispatcher.BeginInvoke(() =>
                        {
                            Assert.AreEqual("stpgsG1DZZxb44J7mFNSzg==", enc);
                            TestComplete();
                        });
                });
        }

        /// <summary>
        /// Tests the cipher.
        /// </summary>
        /*[TestMethod]
        public void  TestCipher ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");

            string strCipher = pc.GetEncryptionKey();

            Assert.AreEqual("67a4f45f0d1d9bc606486fc42dc49416", strCipher);
        }*/

        static string EncodeNonAsciiCharacters(string value)
        {
            StringBuilder sb = new StringBuilder();
            foreach (char c in value)
            {
                if (c > 127)
                {
                    // This character is too big for ASCII
                    string encodedValue = "\\u" + ((int)c).ToString("x4");
                    sb.Append(encodedValue);
                }
                else
                {
                    sb.Append(c);
                }
            }
            return sb.ToString();
        }

        static string DecodeEncodedNonAsciiCharacters(string value)
        {
            return Regex.Replace(
                value,
                @"\\u(?<Value>[a-zA-Z0-9]{4})",
                m =>
                {
                    return ((char)int.Parse(m.Groups["Value"].Value, NumberStyles.HexNumber)).ToString();
                });
        }


    }
}
