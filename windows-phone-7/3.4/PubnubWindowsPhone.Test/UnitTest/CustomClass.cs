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

using System.Runtime.Serialization.Json;
using Newtonsoft.Json;


namespace PubnubWindowsPhone.Test.UnitTest
{
    /// <summary>
    /// Custom class for testing the encryption and decryption 
    /// </summary>
    public class CustomClass
    {
        public string foo = "hi!";
        public int[] bar = { 1, 2, 3, 4, 5 };
    }

    //[Seri
    public class SecretCustomClass
    {
        public string foo = "hello!";

        public int[] bar = { 10, 20, 30, 40, 50 };
    }
}
