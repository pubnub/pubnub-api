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
using Microsoft.Silverlight.Testing;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PubnubSilverlight.Core;
using System.Collections.Generic;
using System.ComponentModel;


namespace PubnubSilverlight.UnitTest
{
    [TestClass]
    public class WhenAClientIsPresented
    {
        [TestMethod]
        public void ThenItShouldReturnReceivedMessage()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);
           
            string channel = "hello_world";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.presence(channel);
        }

        static void Pubnub_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            //Dictionary<string, object> _message = (Dictionary<string, object>)(((Pubnub)sender).ReturnMessage);

            //if (e.PropertyName != "Here_Now")
            //{
            //    Assert.IsNotNull(_message["text"]);
            //}
            //else
            //{
            //    Assert.AreEqual("", _message["uuid"]);
            //}
        }

        [TestMethod]
        public void IfHereNowIsCalledThenItShouldReturnInfo()
        {
            Pubnub pubnub = new Pubnub("demo", "demo", "", "", false);

            string channel = "hello_world";

            pubnub.PropertyChanged += new PropertyChangedEventHandler(Pubnub_PropertyChanged);

            pubnub.here_now(channel);
        }
    }
}
