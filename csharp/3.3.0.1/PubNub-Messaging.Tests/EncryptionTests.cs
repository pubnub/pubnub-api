using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using System.ComponentModel;
using System.Threading;
using System.Collections;
using PubNubMessaging.Core;
using System.Text.RegularExpressions;
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace PubNubMessaging.Tests
{
    /// <summary>
    /// Custom class for testing the encryption and decryption 
    /// </summary>
    class CustomClass
    {
        public string foo = "hi!";
        public int[] bar = { 1, 2, 3, 4, 5 };
    }
    class SecretCustomClass
    {
        public string foo = "hello!";
        public int[] bar = { 10, 20, 30, 40, 50 };
    }

    [TestFixture]
    public class EncryptionTests
    {
        /// <summary>
        /// Tests the null encryption.
        /// The input is serialized
        /// </summary>
        [Test]
        [ExpectedException(typeof(ArgumentNullException))]
        public void TestNullEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //serialized string
            string message = null;
            
            //encrypt
            string encryptedMessage = pc.Encrypt(message);
        }

        /// <summary>
        /// Tests the null decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [Test]
        [ExpectedException(typeof(ArgumentNullException))]
        public void TestNullDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = null;
            //decrypt
            string decryptedMessage = pc.Decrypt(message);

            Assert.AreEqual("", decryptedMessage);
        }

        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is deserialized  
        /// Decrypted string should match yay!
        /// </summary>
        [Test]
        public void TestYayDecryptionBasic()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string message = "q/xJqqN6qbiZMXYmiQC1Fw==";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //deserialize again
            Assert.AreEqual("yay!", decryptedMessage);
        }

        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match q/xJqqN6qbiZMXYmiQC1Fw==
        /// </summary>
        [Test]
        public void TestYayEncryptionBasic()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = "yay!";
            //Encrypt
            string encryptedMessage = pc.Encrypt(message);
            Assert.AreEqual("q/xJqqN6qbiZMXYmiQC1Fw==", encryptedMessage);
        }

        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is not deserialized  
        /// Decrypted and Deserialized string should match yay!
        /// </summary>
        [Test]
        public void TestYayDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //string strMessage= "\"q/xJqqN6qbiZMXYmiQC1Fw==\"";
            //Non deserialized string
            string message = "\"Wi24KS4pcTzvyuGOHubiXg==\"";
            //Deserialize
            message = JsonConvert.DeserializeObject<string>(message);
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //deserialize again
            message = JsonConvert.DeserializeObject<string>(decryptedMessage);
            Assert.AreEqual("yay!", message);
        }
        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match Wi24KS4pcTzvyuGOHubiXg==
        /// </summary>
        [Test]
        public void TestYayEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = "yay!";
            //serialize the string
            message = JsonConvert.SerializeObject(message);
            Console.WriteLine(message);
            //Encrypt
            string enc = pc.Encrypt(message);
            Assert.AreEqual("Wi24KS4pcTzvyuGOHubiXg==", enc);
        }

        /// <summary>
        /// Tests the array encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestArrayEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an empty array object
            object[] emptyArray = { };
            //serialize
            string serializedArray = JsonConvert.SerializeObject(emptyArray);
            //Encrypt
            string encryptedMessage = pc.Encrypt(serializedArray);

            Assert.AreEqual("Ns4TB41JjT2NCXaGLWSPAQ==", encryptedMessage);
        }

        /// <summary>
        /// Tests the array decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to been deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestArrayDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Input the deserialized string
            string message = "Ns4TB41JjT2NCXaGLWSPAQ==";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //create a serialized object
            object[] emptyArrayObject = { };
            string result = JsonConvert.SerializeObject(emptyArrayObject);
            //compare the serialized object and the return of the Decrypt method
            Assert.AreEqual(result, decryptedMessage);
        }

        /// <summary>
        /// Tests the object encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestObjectEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an object
            Object obj = new Object();
            //serialize
            string serializedObject = JsonConvert.SerializeObject(obj);
            //encrypt
            string encryptedMessage = pc.Encrypt(serializedObject);

            Assert.AreEqual("IDjZE9BHSjcX67RddfCYYg==", encryptedMessage);
        }
        /// <summary>
        /// Tests the object decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to be deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestObjectDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized
            string message = "IDjZE9BHSjcX67RddfCYYg==";
            //Decrypt
            string decryptedMessage = pc.Decrypt(message);
            //create an object
            Object obj = new Object();
            //Serialize the object
            string result = JsonConvert.SerializeObject(obj);

            Assert.AreEqual(result, decryptedMessage);
        }
        /// <summary>
        /// Tests my object encryption.
        /// The output is not serialized 
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestMyObjectEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an object of the custom class
            CustomClass cc = new CustomClass();
            //serialize it
            string result = JsonConvert.SerializeObject(cc);
            //encrypt it
            string encryptedMessage = pc.Encrypt(result);

            Assert.AreEqual("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=", encryptedMessage);
        }
        /// <summary>
        /// Tests my object decryption.
        /// The output is not deserialized
        /// Decrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestMyObjectDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized
            string message = "Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=";
            //Decrypt
            string decryptedMessage = pc.Decrypt(message);
            //create an object of the custom class
            CustomClass cc = new CustomClass();
            //Serialize it
            string result = JsonConvert.SerializeObject(cc);

            Assert.AreEqual(result, decryptedMessage);
        }

        /// <summary>
        /// Tests the pub nub encryption2.
        /// The output is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=
        /// </summary>
        [Test]
        public void TestPubNubEncryption2()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized
            string message = "Pubnub Messaging API 2";
            //serialize the message
            message = JsonConvert.SerializeObject(message);
            //encrypt
            string encryptedMessage = pc.Encrypt(message);

            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=", encryptedMessage);
        }

        /// <summary>
        /// Tests the pub nub decryption2.
        /// Assumes that the input message is deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 2
        /// </summary>
        [Test]
        public void TestPubNubDecryption2()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized string    
            string message = "f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=";
            //Decrypt
            string decryptedMessage = pc.Decrypt(message);
            //Deserialize
            message = JsonConvert.DeserializeObject<string>(decryptedMessage);
            Assert.AreEqual("Pubnub Messaging API 2", message);
        }

        /// <summary>
        /// Tests the pub nub encryption1.
        /// The input is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=
        /// </summary>
        [Test]
        public void TestPubNubEncryption1()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //non serialized string
            string message = "Pubnub Messaging API 1";
            //serialize
            message = JsonConvert.SerializeObject(message);
            //encrypt
            string encryptedMessage = pc.Encrypt(message);

            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=", encryptedMessage);
        }

        /// <summary>
        /// Tests the pub nub decryption1.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 1        
        /// </summary>
        [Test]
        public void TestPubNubDecryption1()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //deserialize
            message = (decryptedMessage != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(decryptedMessage) : "";
            Assert.AreEqual("Pubnub Messaging API 1", message);
        }

        /// <summary>
        /// Tests the stuff can encryption.
        /// The input is serialized
        /// Encrypted string should match zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF
        /// </summary>
        [Test]
        public void TestStuffCanEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //input serialized string
            string message = "{\"this stuff\":{\"can get\":\"complicated!\"}}";
            //encrypt
            string encryptedMessage = pc.Encrypt(message);

            Assert.AreEqual("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF", encryptedMessage);
        }

        /// <summary>
        /// Tests the stuffcan decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>
        [Test]
        public void TestStuffcanDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = "zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);

            Assert.AreEqual("{\"this stuff\":{\"can get\":\"complicated!\"}}", decryptedMessage);
        }

        /// <summary>
        /// Tests the hash encryption.
        /// The input is serialized
        /// Encrypted string should match GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=
        /// </summary>
        [Test]
        public void TestHashEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //serialized string
            string message = "{\"foo\":{\"bar\":\"foobar\"}}";
            //encrypt
            string encryptedMessage = pc.Encrypt(message);

            Assert.AreEqual("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=", encryptedMessage);
        }

        /// <summary>
        /// Tests the hash decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [Test]
        public void TestHashDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string message = "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);

            Assert.AreEqual("{\"foo\":{\"bar\":\"foobar\"}}", decryptedMessage);
        }

        /// <summary>
        /// Tests the unicode chars encryption.
        /// The input is not serialized
        /// </summary>
        [Test]
        public void TestUnicodeCharsEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string message = "漢語";

            message = JsonConvert.SerializeObject(message);
            Console.WriteLine(message);
            string encryptedMessage = pc.Encrypt(message);
            Console.WriteLine(encryptedMessage);
            Assert.AreEqual("+BY5/miAA8aeuhVl4d13Kg==", encryptedMessage);
        }

        /// <summary>
        /// Tests the unicode decryption.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match the unicode chars       
        /// </summary>
        [Test]
        public void TestUnicodeCharsDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string message = "+BY5/miAA8aeuhVl4d13Kg==";
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //deserialize
            message = (decryptedMessage != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(decryptedMessage) : "";

            Assert.AreEqual("漢語", message);
        }

        /// <summary>
        /// Tests the german chars decryption.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match the unicode chars  
        /// </summary>
        [Test]
        public void TestGermanCharsDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string message = "stpgsG1DZZxb44J7mFNSzg==";
            
            //decrypt
            string decryptedMessage = pc.Decrypt(message);
            //deserialize
            message = (decryptedMessage != "**DECRYPT ERROR**") ? JsonConvert.DeserializeObject<string>(decryptedMessage) : "";

            Assert.AreEqual("ÜÖ", message);
        }
        
        /// <summary>
        /// Tests the german encryption.
        /// The input is not serialized
        /// </summary>
        [Test]
        public void TestGermanCharsEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string message = "ÜÖ";

            message = JsonConvert.SerializeObject(message);
            Console.WriteLine(message);
            string encryptedMessage = pc.Encrypt(message);
            Console.WriteLine(encryptedMessage);
            Assert.AreEqual("stpgsG1DZZxb44J7mFNSzg==", encryptedMessage);
        }

        /// <summary>
        /// Tests the cipher.
        /// </summary>
        /*[Test]
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
