using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace csharp_webApp
{
    public partial class UnsubscribeExample : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // channel name
            string channel = "test-iis";

            pubnub objPubnub = new pubnub(
               "demo",  // PUBLISH_KEY
               "demo",  // SUBSCRIBE_KEY
               "demo",  // SECRET_KEY
               "",      // CIPHER_KEY   (Cipher key is Optional)
               false    // SSL_ON?
           );

            pubnub.Procedure Receiver = delegate(object message)
            {
                Debug.WriteLine(message);
                Dictionary<string, object> arg = new Dictionary<string, object>();
                arg.Add("channel", channel);
                //Unsubscribe messages
                objPubnub.Unsubscribe(arg); 
                return true;
            };
            pubnub.Procedure ConnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                // Publish String Message
                Dictionary<string, object> publish = new Dictionary<string, object>();
                publish.Add("channel", channel);
                publish.Add("message", "Hello World!!!!");

                // publish Response
                objPubnub.Publish(publish);
                return true;
            };
            pubnub.Procedure DisconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ReconnectCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };
            pubnub.Procedure ErrorCallback = delegate(object message)
            {
                Debug.WriteLine(message);
                return true;
            };

            Dictionary<string, object> args = new Dictionary<string, object>();
            args.Add("channel", channel);
            args.Add("callback", Receiver);                 // callback to get response
            args.Add("connect_cb", ConnectCallback);        // callback to get connect event
            args.Add("disconnect_cb", DisconnectCallback);  // callback to get disconnect event
            args.Add("reconnect_cb", ReconnectCallback);    // callback to get reconnect event
            args.Add("error_cb", ErrorCallback);            // callback to get error event


            // Subscribe messages
            objPubnub.Subscribe(args);
        }
    }
}