using System;
using PubNubLib;
using NUnit.Framework;
using System.ComponentModel;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;

namespace PubNubTest
{
    [TestFixture]
    public class EncryptionTests
    {
        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is deserialized  
        /// Decrypted string should match yay!
        /// </summary>
        [Test]
        public void TestYayDecryptionBasic ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string strMessage= "q/xJqqN6qbiZMXYmiQC1Fw==";
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //deserialize again
            Assert.AreEqual("yay!", dec);
        }
        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match q/xJqqN6qbiZMXYmiQC1Fw==
        /// </summary>
        [Test]
        public void TestYayEncryptionBasic ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string strMessage= "yay!";
            //Encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);
            Assert.AreEqual("q/xJqqN6qbiZMXYmiQC1Fw==", enc);
        }
        /// <summary>
        /// Tests the yay decryption.
        /// Assumes that the input message is not deserialized  
        /// Decrypted and Deserialized string should match yay!
        /// </summary>
        [Test]
        public void TestYayDecryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //string strMessage= "\"q/xJqqN6qbiZMXYmiQC1Fw==\"";
            //Non deserialized string
            string strMessage= "\"Wi24KS4pcTzvyuGOHubiXg==\"";
            //Deserialize 
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Deserialize<string>(strMessage);
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //deserialize again
            strMessage= js.Deserialize<string>(dec);
            Assert.AreEqual("yay!", strMessage);
        }
        /// <summary>
        /// Tests the yay encryption.
        /// The output is not serialized
        /// Encrypted string should match Wi24KS4pcTzvyuGOHubiXg==
        /// </summary>
        [Test]
        public void TestYayEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string strMessage= "yay!";
            //serialize the string
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            Console.WriteLine(strMessage);
            //Encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);
            Assert.AreEqual("Wi24KS4pcTzvyuGOHubiXg==", enc);
            /*PubnubCrypto pc = new PubnubCrypto("enigma");
            string strMessage= "yay!";
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            string enc = pc.EncryptOrDecrypt(true, strMessage);*/

            //Assert.AreEqual("q/xJqqN6qbiZMXYmiQC1Fw==", enc);
        }
        
        /// <summary>
        /// Tests the array encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestArrayEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an empty array object
            object [] objArr = {};
            //serialize
            JavaScriptSerializer js = new JavaScriptSerializer();
            string strArr = js.Serialize(objArr);
            //Encrypt
            string enc = pc.EncryptOrDecrypt(true, strArr);

            Assert.AreEqual("Ns4TB41JjT2NCXaGLWSPAQ==", enc);
        }

        /// <summary>
        /// Tests the array decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to been deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestArrayDecryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Input the deserialized string
            string strMessage= "Ns4TB41JjT2NCXaGLWSPAQ==";
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //create a serialized object
            object [] objArr = {};
            JavaScriptSerializer js = new JavaScriptSerializer();
            string res = js.Serialize(objArr);
            //compare the serialized object and the return of the Decrypt method
            Assert.AreEqual(res, dec);
        }
        
        /// <summary>
        /// Tests the object encryption.
        /// The output is not serialized
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestObjectEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an object
            Object obj = new Object();
            //serialize
            JavaScriptSerializer js = new JavaScriptSerializer();
            string strObj = js.Serialize(obj);
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strObj);

            Assert.AreEqual("IDjZE9BHSjcX67RddfCYYg==", enc);
        }
        /// <summary>
        /// Tests the object decryption.
        /// Assumes that the input message is deserialized
        /// And the output message has to be deserialized.
        /// Decrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestObjectDecryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized
            string strMessage= "IDjZE9BHSjcX67RddfCYYg==";
            //Decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //create an object
            Object obj = new Object();
            //Serialize the object
            JavaScriptSerializer js = new JavaScriptSerializer();
            string res = js.Serialize(obj);

            Assert.AreEqual(res, dec);
        }
        /// <summary>
        /// Tests my object encryption.
        /// The output is not serialized 
        /// Encrypted string should match the serialized object
        /// </summary>
        [Test]
        public void TestMyObjectEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //create an object of the custom class
            CustomClass cc = new CustomClass();
            //serialize it
            JavaScriptSerializer js = new JavaScriptSerializer();
            string res = js.Serialize(cc);
            //encrypt it
            string enc = pc.EncryptOrDecrypt(true, res);

            Assert.AreEqual("Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=", enc);
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
            string strMessage= "Zbr7pEF/GFGKj1rOstp0tWzA4nwJXEfj+ezLtAr8qqE=";
            //Decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //create an object of the custom class
            CustomClass cc = new CustomClass();
            JavaScriptSerializer js = new JavaScriptSerializer();
            //Serialize it
            string res = js.Serialize(cc);

            Assert.AreEqual(res, dec);
        }

        /// <summary>
        /// Tests the pub nub encryption2.
        /// The output is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=
        /// </summary>
        [Test]
        public void TestPubNubEncryption2 ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized
            string strMessage= "Pubnub Messaging API 2";
            //serialize the message
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);

            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=", enc);
        }

        /// <summary>
        /// Tests the pub nub decryption2.
        /// Assumes that the input message is deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 2
        /// </summary>
        [Test]
        public void TestPubNubDecryption2 ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //Deserialized string    
            string strMessage= "f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=";
            //Decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //Deserialize
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Deserialize<string>(dec);
            Assert.AreEqual("Pubnub Messaging API 2", strMessage);
        }

        /// <summary>
        /// Tests the pub nub encryption1.
        /// The input is not serialized
        /// Encrypted string should match f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=
        /// </summary>
        [Test]
        public void TestPubNubEncryption1 ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //non serialized string
            string strMessage= "Pubnub Messaging API 1";
            //serialize
            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);

            Assert.AreEqual("f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=", enc);
        }

        /// <summary>
        /// Tests the pub nub decryption1.
        /// Assumes that the input message is  deserialized  
        /// Decrypted and Deserialized string should match Pubnub Messaging API 1        
        /// </summary>
        [Test]
        public void TestPubNubDecryption1 ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string strMessage= "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=";
            JavaScriptSerializer js = new JavaScriptSerializer();
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //deserialize
            strMessage= js.Deserialize<string>(dec);
            Assert.AreEqual("Pubnub Messaging API 1", strMessage);
        }

        /// <summary>
        /// Tests the stuff can encryption.
        /// The input is serialized
        /// Encrypted string should match zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF
        /// </summary>
        [Test]
        public void TestStuffCanEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //input serialized string
            string strMessage= "{\"this stuff\":{\"can get\":\"complicated!\"}}";
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);

            Assert.AreEqual("zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF", enc);
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
            string strMessage= "zMqH/RTPlC8yrAZ2UhpEgLKUVzkMI2cikiaVg30AyUu7B6J0FLqCazRzDOmrsFsF";
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);

            Assert.AreEqual("{\"this stuff\":{\"can get\":\"complicated!\"}}", dec);
        }

        /// <summary>
        /// Tests the hash encryption.
        /// The input is serialized
        /// Encrypted string should match GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=
        /// </summary>
        [Test]
        public void TestHashEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //serialized string
            string strMessage= "{\"foo\":{\"bar\":\"foobar\"}}";
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);

            Assert.AreEqual("GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=", enc);
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
            string strMessage= "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g=";
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);

            Assert.AreEqual("{\"foo\":{\"bar\":\"foobar\"}}", dec);
        }

        /// <summary>
        /// Tests the null encryption.
        /// The input is serialized
        /// </summary>
        [Test]
        public void TestNullEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //serialized string
            string strMessage= null;
            //encrypt
            string enc = pc.EncryptOrDecrypt(true, strMessage);

            Assert.AreEqual("", enc);
        }

        /// <summary>
        /// Tests the null decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [Test]
        public void TestNullDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string strMessage= null;
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);

            Assert.AreEqual("", dec);
        }
        /// <summary>
        /// Tests the unicode chars encryption.
        /// The input is not serialized
        /// </summary>
        [Test]
        public void TestUnicodeCharsEncryption ()
        {
            /*string unicodeString = "漢語";

            Console.WriteLine( unicodeString );

            string encoded = EncodeNonAsciiCharacters(unicodeString);
            Console.WriteLine( encoded );

            string decoded = DecodeEncodedNonAsciiCharacters( encoded );
            Console.WriteLine( decoded );*/

            PubnubCrypto pc = new PubnubCrypto("enigma");
            string strMessage= "漢語";

            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            Console.WriteLine(strMessage);
            string enc = pc.EncryptOrDecrypt(true, strMessage);
            Console.WriteLine(enc);
            Assert.AreEqual("+BY5/miAA8aeuhVl4d13Kg==", enc);
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
            string strMessage= "+BY5/miAA8aeuhVl4d13Kg==";
            JavaScriptSerializer js = new JavaScriptSerializer();
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //deserialize
            strMessage= js.Deserialize<string>(dec);

            Assert.AreEqual("漢語", strMessage);
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
            string strMessage= "stpgsG1DZZxb44J7mFNSzg==";
            JavaScriptSerializer js = new JavaScriptSerializer();
            //decrypt
            string dec = pc.EncryptOrDecrypt(false, strMessage);
            //deserialize
            strMessage= js.Deserialize<string>(dec);

            Assert.AreEqual("ÜÖ", strMessage);
        }
       /// <summary>
        /// Tests the german encryption.
        /// The input is not serialized
        /// </summary>
        [Test]
        public void TestGermanCharsEncryption ()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            string strMessage= "ÜÖ";

            JavaScriptSerializer js = new JavaScriptSerializer();
            strMessage= js.Serialize(strMessage);
            Console.WriteLine(strMessage);
            string enc = pc.EncryptOrDecrypt(true, strMessage);
            Console.WriteLine(enc);
            Assert.AreEqual("stpgsG1DZZxb44J7mFNSzg==", enc);
        }

        /// <summary>
        /// Test for Publish the and history.
        /// </summary>
        /*[Test]
        public void PublishAndHistory ()
        {
            //demo init
            Pubnub pubnub = new Pubnub(
                    "demo",
                    "demo",
                    "",
                    "",
                    false);
            //cipher key
            pubnub.CIPHER_KEY = "enigma";
            //channel
            string channel = "hello_world";
            //string message
            string strMsg = "yay!";
            //publish the message
            pubnub.publish(channel, strMsg);

            bool deliveryStatus = false;

            string strResponse = "empty";
            //create an event handler for the proertyChanged event. 
            //This will be called when we get a response from the server
            pubnub.PropertyChanged += delegate(object sender, PropertyChangedEventArgs e)
            {
                if (e.PropertyName == "DetailedHistory")
                {
                    Console.WriteLine("\n*********** DetailedHistory Messages *********** ");
                    List<object> lstResponse  = (List<object>)((Pubnub)sender).DetailedHistory;
                    strResponse = lstResponse[0].ToString();
                    deliveryStatus = true;
                }
            };
            
            pubnub.detailedHistory(channel, 1);
            //wait till the deliveryStatus is true. 
            //the variable is modified on the PropertyChanged event
            while (!deliveryStatus) ;

            Assert.AreEqual(strMsg, strResponse);
        }*/
        
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
        
        static string EncodeNonAsciiCharacters( string value ) {
            StringBuilder sb = new StringBuilder();
            foreach( char c in value ) {
                if( c > 127 ) {
                    // This character is too big for ASCII
                    string encodedValue = "\\u" + ((int) c).ToString( "x4" );
                    sb.Append( encodedValue );
                }
                else {
                    sb.Append( c );
                }
            }
            return sb.ToString();
        }

        static string DecodeEncodedNonAsciiCharacters( string value ) {
            return Regex.Replace(
                value,
                @"\\u(?<Value>[a-zA-Z0-9]{4})",
                m => {
                    return ((char) int.Parse( m.Groups["Value"].Value, NumberStyles.HexNumber )).ToString();
                } );
        }
    }

  /// <summary>
  /// Custom class for testing the encryption and decryption 
  /// </summary>
  class CustomClass
  {
    public string foo = "hi!"; 
    public int [] bar = {1, 2, 3, 4, 5};
  }
}

