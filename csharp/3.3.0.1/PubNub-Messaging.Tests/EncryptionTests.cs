using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.ComponentModel;
using System.Threading;
using System.Web.Script.Serialization;
using System.Collections;
using PubNub_Messaging;

namespace PubNub_Messaging.Tests
{
    [TestClass]
    public class EncryptionTests
    {
        /// <summary>
        /// Tests the null encryption.
        /// The input is serialized
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void TestNullEncryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //serialized string
            string strMessage = null;
            
            //encrypt
            string enc = pc.encrypt(strMessage);
        }

        /// <summary>
        /// Tests the null decryption.
        /// Assumes that the input message is  deserialized  
        /// </summary>        
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void TestNullDecryption()
        {
            PubnubCrypto pc = new PubnubCrypto("enigma");
            //deserialized string
            string strMessage = null;
            //decrypt
            string dec = pc.decrypt(strMessage);

            Assert.AreEqual("", dec);
        }

    }
}
