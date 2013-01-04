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

namespace PubNub_Messaging
{
    public class Instance
    {
        public static UIElement GetPage
        {
            get
            {
                var settings = UnitTestSystem.CreateDefaultSettings();
                settings.ShowTagExpressionEditor = false;
                settings.StartRunImmediately = true;
                return UnitTestSystem.CreateTestPage(settings);
            }
        }
    }
}
