using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Web.Script.Serialization;
using System.Linq;
using Newtonsoft.Json.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.ComponentModel;
using Newtonsoft.Json;
using System.Threading;
using System.IO.Compression;
using PubnubCrypto;

/**
 * PubNub 3.1 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package pubnub
 */
namespace Pubnub
{
    public class Channel_status 
    {
        public string channel;
        public bool connected, first;
    }
    public class pubnub
    {
        private string ORIGIN = "pubsub.pubnub.com";
        private string PUBLISH_KEY = "";
        private string SUBSCRIBE_KEY = "";
        private string SECRET_KEY = "";
        private string CIPHER_KEY = "";
        private bool SSL = false;

        private ManualResetEvent webRequestDone;
        volatile private bool abort;
        public delegate bool Procedure(object message);
        private List<Channel_status> subscriptions;

        /**
         * PubNub 3.1 with cipher key
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         * @param string Cipher Key.
         * @param bool SSL Enabled.
         */
        public pubnub(
            string publish_key,
            string subscribe_key,
            string secret_key,
            string cipher_key,
            bool ssl_on
        )
        {
            this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
        }

        /**
         * PubNub 3.0 Compatibility
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         * @param bool SSL Enabled.
         */
        public pubnub(
            string publish_key,
            string subscribe_key,
            string secret_key,
            bool ssl_on
        )
        {
            this.init(publish_key, subscribe_key, secret_key, "", ssl_on);
        }

        /**
         * PubNub 2.0 Compatibility
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         */
        public pubnub(
            string publish_key,
            string subscribe_key
        )
        {
            this.init(publish_key, subscribe_key, "", "", false);
        }

        /**
         * PubNub 3.0 without SSL
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         */
        public pubnub(
            string publish_key,
            string subscribe_key,
            string secret_key
        )
        {
            this.init(publish_key, subscribe_key, secret_key, "", false);
        }

        /**
         * Init
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         * @param string Cipher Key.
         * @param bool SSL Enabled.
         */
        public void init(
            string publish_key,
            string subscribe_key,
            string secret_key,
            string cipher_key,
            bool ssl_on
        )
        {
            this.PUBLISH_KEY = publish_key;
            this.SUBSCRIBE_KEY = subscribe_key;
            this.SECRET_KEY = secret_key;
            this.CIPHER_KEY = cipher_key;
            this.SSL = ssl_on;

            // SSL On?
            if (this.SSL)
            {
                this.ORIGIN = "https://" + this.ORIGIN;
            }
            else
            {
                this.ORIGIN = "http://" + this.ORIGIN;
            }
            webRequestDone = new ManualResetEvent(true);
        }

        /**
         * Publish
         *
         * Send a message to a channel.
         *
         * @param Dictionary<string, object> args 
         * args is string channel name and object message
         * @return List<object> info.
         */
        public List<object> Publish(Dictionary<string, object> args)
        {
            string channel = args["channel"].ToString();
            object message = args["message"];

            JavaScriptSerializer serializer = new JavaScriptSerializer();
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);

            if (this.CIPHER_KEY.Length > 0)
            {
                if (message.GetType() == typeof(string))
                {
                    message = pc.encrypt(message.ToString());
                }                
                else if (message.GetType() == typeof(object[]))
                {
                    message = pc.encrypt((object[])message);
                }
                else if (message.GetType() == typeof(Dictionary<string, object>))
                {
                    Dictionary<string, object> dict = (Dictionary<string, object>)message;
                    message = pc.encrypt(dict);
                }
            }

            // Generate String to Sign
            string signature = "0";
            if (this.SECRET_KEY.Length > 0)
            {
                StringBuilder string_to_sign = new StringBuilder();
                string_to_sign
                    .Append(this.PUBLISH_KEY)
                    .Append('/')
                    .Append(this.SUBSCRIBE_KEY)
                    .Append('/')
                    .Append(this.SECRET_KEY)
                    .Append('/')
                    .Append(channel)
                    .Append('/')
                    .Append(serializer.Serialize(message));

                // Sign Message
                signature = getHMACSHA256(string_to_sign.ToString());
            }

            // Build URL
            List<string> url = new List<string>();
            url.Add("publish");
            url.Add(this.PUBLISH_KEY);
            url.Add(this.SUBSCRIBE_KEY);
            url.Add(signature);
            url.Add(channel);
            url.Add("0");
            url.Add(serializer.Serialize(message));

            // Return JSONArray
            return _request(url);
        }

        /**
         * Subscribe
         *
         * This function is BLOCKING.
         * Listen for a message on a channel.
         *
         * @param Dictionary<string,object> args.
         * args contains  channel name and Procedure function callback.
         */
        public void Subscribe(Dictionary<string, object> args)
        {
            args.Add("timestamp", 0);
            this._subscribe(args);
        }

        /**
          * _subscribe - Private Interface
          *
          * @param Dictionary<string, object> args
          *  args is channel name and Procedure function callback and timetoken
          * 
          */
        private void _subscribe(Dictionary<string, object> args)
        {
            bool is_disconnect = false;
            bool is_alreadyConnect = false;
            Procedure callback=null, connect_cb, disconnect_cb, reconnect_cb, error_cb;
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);

            string channel = args["channel"].ToString();
            object timetoken = args["timestamp"];
            // Validate Arguments
            if (args["callback"] != null)
            {
                callback = (Procedure)args["callback"];
            }
            else 
            {
                Console.WriteLine("Invalid Callback.");
            }
            if(args.ContainsKey("connect_cb") && args["connect_cb"] != null)            
                connect_cb = (Procedure)args["connect_cb"];
            else
                connect_cb = new Procedure(doNothing);
            if (args.ContainsKey("disconnect_cb") && args["disconnect_cb"] != null)
                disconnect_cb = (Procedure)args["disconnect_cb"];
            else
                disconnect_cb = new Procedure(doNothing);
            if (args.ContainsKey("reconnect_cb") && args["reconnect_cb"] != null)
                reconnect_cb = (Procedure)args["reconnect_cb"];
            else
                reconnect_cb = new Procedure(doNothing);
            if (args.ContainsKey("error_cb") && args["error_cb"] != null)
                error_cb = (Procedure)args["error_cb"];
            else
                error_cb = (Procedure)args["callback"];
            if (channel == null || channel =="")
            {
                error_cb("Invalid Channel.");
                return;
            }
            // Ensure Single Connection
            if (subscriptions != null && subscriptions.Count > 0)
            {
                bool channel_exist = false;
                foreach (Channel_status cs in subscriptions)
                {
                    if (cs.channel == channel)
                    {
                        channel_exist = true;
                        if (!cs.connected)
                        {
                            cs.connected = true;
                        }
                        else
                            is_alreadyConnect = true;
                        break;
                    }
                }
                if (!channel_exist)
                {
                    Channel_status cs = new Channel_status();
                    cs.channel = channel;
                    cs.connected = true;
                    subscriptions.Add(cs);
                }
                else if (is_alreadyConnect)
                {
                    error_cb("Already Connected");
                    return;
                }
                
            }
            else
            {
                // New Channel
                Channel_status cs = new Channel_status();
                cs.channel = channel;
                cs.connected = true;
                subscriptions = new List<Channel_status>();
                subscriptions.Add(cs);
            }

            bool is_reconnected = false;
            //  Begin Recusive Subscribe
            while (true)
            {
                try
                {
                    // Build URL
                    List<string> url = new List<string>();
                    url.Add("subscribe");
                    url.Add(this.SUBSCRIBE_KEY);
                    url.Add(channel);
                    url.Add("0");
                    url.Add(timetoken.ToString());

                    // Stop Connection?     
                    is_disconnect = false;
                    foreach (Channel_status cs in subscriptions)
                    {
                        if (cs.channel == channel)
                        {
                            if (!cs.connected)
                            {
                                disconnect_cb("Disconnected to channel : " + channel);
                                is_disconnect = true;
                                break;
                            }
                        }
                    }
                    if (is_disconnect)
                        return;

                    // Wait for Message
                    List<object> response = _request(url);

                    // Stop Connection?
                    foreach (Channel_status cs in subscriptions)
                    {
                        if (cs.channel == channel)
                        {
                            if (!cs.connected)
                            {
                                disconnect_cb("Disconnected to channel : " + channel);
                                is_disconnect = true;
                                break;
                            }
                        }
                    }
                    if (is_disconnect)
                        return;
                    // Problem?
                    if (response == null || response[1].ToString() == "0")
                    {
                        
                        for (int i = 0; i < subscriptions.Count(); i++)
                        {
                            Channel_status cs = subscriptions[i];
                            if (cs.channel == channel)
                            {
                                subscriptions.RemoveAt(i);
                                disconnect_cb("Disconnected to channel : " + channel);
                            }
                        }

                        // Ensure Connected (Call Time Function)
                        while (true)
                        {
                            string time_token = Time().ToString();
                            if (time_token == "0")
                            {
                                // Reconnect Callback
                                reconnect_cb("Reconnecting to channel : " + channel);
                                Thread.Sleep(5000);
                            }
                            else
                            {
                                is_reconnected = true;
                                break;
                            }
                        }
                        if (is_reconnected)
                        {
                            break;
                        }
                    }
                    else
                    {
                        foreach (Channel_status cs in subscriptions)
                        {
                            if (cs.channel == channel)
                            {
                                // Connect Callback
                                if (!cs.first)
                                {
                                    cs.first = true;
                                    connect_cb("Connected to channel : " + channel);
                                    break;
                                }
                            }
                        }
                    }
                    // Update TimeToken
                    if (response[1].ToString().Length > 0)
                        timetoken = (object)response[1];

                    // Run user Callback and Reconnect if user permits.
                    object message = "";
                    foreach (object msg in (object[])response[0])
                    {
                        if (this.CIPHER_KEY.Length > 0)
                        {
                            if (msg.GetType() == typeof(string))
                            {
                                message = pc.decrypt(msg.ToString());
                            }
                            else if (msg.GetType() == typeof(object[]))
                            {
                                message = pc.decrypt((object[])msg);
                            }
                            else if (msg.GetType() == typeof(Dictionary<string, object>))
                            {
                                Dictionary<string, object> dict = (Dictionary<string, object>)msg;
                                message = pc.decrypt(dict);
                            }
                        }
                        else
                        {
                            if (msg.GetType() == typeof(object[]))
                            {
                                object[] obj = (object[])msg;
                                JArray jArr = new JArray();
                                for (int i = 0; i < obj.Count(); i++)
                                {
                                    jArr.Add(obj[i]);
                                }
                                message = jArr;
                            }
                            else if (msg.GetType() == typeof(Dictionary<string, object>))
                            {
                                message = extractObject((Dictionary<string, object>)msg);                                
                            }
                            else
                            {
                                message = msg;
                            }
                        }
                        if (!callback(message)) return;
                    }
                }
                catch
                {
                    System.Threading.Thread.Sleep(1000);
                }
            }
            if (is_reconnected)
            {
                // Reconnect Callback
                args["channel"] = channel;
                args["callback"] = callback;
                args["timestamp"] = timetoken;
                this._subscribe(args);
            }
        }

        /**
         * Request URL
         *
         * @param List<string> request of url directories.
         * @return List<object> from JSON response.
         */
        private List<object> _request(List<string> url_components)
        {
            try
            {

                string temp = null;
                int count = 0;
                byte[] buf = new byte[8192];
                StringBuilder url = new StringBuilder();
                StringBuilder sb = new StringBuilder();

                JavaScriptSerializer serializer = new JavaScriptSerializer();

                // Add Origin To The Request
                url.Append(this.ORIGIN);

                // Generate URL with UTF-8 Encoding
                foreach (string url_bit in url_components)
                {
                    url.Append("/");
                    url.Append(_encodeURIcomponent(url_bit));
                }
                // Create Request
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url.ToString());

                // Set Timeout
                request.Timeout = 310000;
                request.ReadWriteTimeout = 310000;

                request.Headers.Add(HttpRequestHeader.AcceptEncoding, "gzip");
                request.Headers.Add("V", "3.1");
                request.UserAgent = "C#-Mono";

                webRequestDone.Reset();
                IAsyncResult asyncResult = request.BeginGetResponse(new AsyncCallback(requestCallBack), null);
                webRequestDone.WaitOne();
                if (abort)
                {
                    return new List<object>();
                }

                // Receive Response
                HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(asyncResult);

                // Read
                using (Stream stream = response.GetResponseStream())
                {
                    Stream resStream = stream;
                    if (response.ContentEncoding.ToLower().Contains("gzip"))
                    {
                        resStream = new GZipStream(stream, CompressionMode.Decompress);
                    }
                    else
                    {
                        resStream = stream;
                    }
                    do
                    {
                        count = resStream.Read(buf, 0, buf.Length);
                        if (count != 0)
                        {
                            temp = Encoding.UTF8.GetString(buf, 0, count);
                            sb.Append(temp);
                        }
                    } while (count > 0);
                }

                // Parse Response
                string message = sb.ToString();

                return serializer.Deserialize<List<object>>(message);
            }
            catch (Exception ex)
            {
                List<object> error = new List<object>();
                if (url_components[0] == "time")
                {
                    error.Add("0");
                }
                else if (url_components[0] == "history")
                {
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (url_components[0] == "publish")
                {
                    error.Add("0");
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (url_components[0] == "subscribe")
                {
                    error.Add("0");
                    error.Add("0");
                }
                return error;
            }
        }

        private void requestCallBack(IAsyncResult result)
        {
            // release thread block
            webRequestDone.Set();
        }

        public void Abort()
        {
            abort = true;
            webRequestDone.Set();
        }

        /**
         * Time
         *
         * Timestamp from PubNub Cloud.
         *
         * @return object timestamp.
         */
        public object Time()
        {
            List<string> url = new List<string>();

            url.Add("time");
            url.Add("0");

            List<object> response = _request(url);
            return response[0];
        }

        /**
        * UUID
        * @return string unique identifier         
        */
        public string UUID()
        {
            return Guid.NewGuid().ToString();
        }

        /**
        * History
        *
        * Load history from a channel.
        *
        * @param Dictionary<string, string> args
        * args is channel name and int limit history count response.
        * @return List<object> of history.
        */
        public List<object> History(Dictionary<string, string> args)
        {
            string channel = args["channel"];
            int limit = Convert.ToInt32(args["limit"]);
            List<string> url = new List<string>();

            url.Add("history");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add(channel);
            url.Add("0");
            url.Add(limit.ToString());
            if (this.CIPHER_KEY.Length > 0)
            {
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
                return pc.decrypt(_request(url));
            }
            else
            {
               List<object> objTop = _request(url);
               List<object> result = new List<object>();
               foreach (object o in objTop)
               {
                   if(o.GetType() == typeof(Dictionary<string,object>))
                   {
                       JObject jobj = new JObject();
                       foreach (KeyValuePair<string, object> pair in (Dictionary<string, object>)o)
                       {
                           jobj.Add(pair.Key, pair.Value.ToString());
                       }
                       result.Add(jobj);
                   }
                   else if (o.GetType() == typeof(object[]))
                   {
                       object[] obj = (object[])o;
                       JArray jArr = new JArray();
                       for (int i = 0; i < obj.Count(); i++)
                       {
                           jArr.Add(obj[i]);
                       }
                       result.Add(jArr);
                   }
                   else
                   {
                       result.Add(o);
                   }
               }
                return result;
            }
        }

       /**
        * Unsubscribe
        *
        * Unsubscribe/Disconnect to channel.
        *
        * @param Dictionary<String, Object> containing channel name.
        */
        public void Unsubscribe(Dictionary<String, Object> args)
        {
            String channel = args["channel"].ToString();
            foreach (Channel_status cs in subscriptions)
            {
                if (cs.channel == channel && cs.connected)
                {
                    cs.connected = false;
                    cs.first = false;
                    break;
                }
            }
        }

        private string _encodeURIcomponent(string s)
        {
            StringBuilder o = new StringBuilder();
            foreach (char ch in s.ToCharArray())
            {
                if (isUnsafe(ch))
                {
                    o.Append('%');
                    o.Append(toHex(ch / 16));
                    o.Append(toHex(ch % 16));
                }
                else o.Append(ch);
            }
            return o.ToString();
        }

        private char toHex(int ch)
        {
            return (char)(ch < 10 ? '0' + ch : 'A' + ch - 10);
        }

        private bool isUnsafe(char ch)
        {
            return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".IndexOf(ch) >= 0;
        }

        private static string getHMACSHA256(string text)
        {
            HMACSHA256 sha256 = new HMACSHA256();
            byte[] data = Encoding.Default.GetBytes(text);
            byte[] hash = sha256.ComputeHash(data);
            string hexaHash = "";
            foreach (byte b in hash) hexaHash += String.Format("{0:x2}", b);
            return hexaHash;
        }
        private JObject extractObject(Dictionary<string, object> msg)
        {
            JObject jobj = new JObject();
            foreach (KeyValuePair<string, object> pair in (Dictionary<string, object>)msg)
            {
                if (pair.Value.GetType() == typeof(Dictionary<string, object>))
                {
                    JObject tempObj = extractObject((Dictionary<string, object>)pair.Value);
                    jobj.Add(pair.Key, tempObj);
                }
                else
                {
                    jobj.Add(pair.Key, pair.Value.ToString());
                }
            }
            return jobj;
        }
        private bool doNothing(object result)
        {
            // do nothing
            return false;
        }
    }
}

