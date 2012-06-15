using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using Newtonsoft.Json.Linq;
using System.Net;
using Newtonsoft.Json;
using System.IO;
using System.IO.Compression;

namespace csharp_webApp
{
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

        /**
         * PubNub 3.1
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
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);

            if (this.CIPHER_KEY.Length > 0)
            {
                if (message.GetType() == typeof(string))
                {
                    message = pc.encrypt(message.ToString());
                    message = "\"" + message.ToString() + "\"";
                }
                else if (message.GetType() == typeof(JArray))
                {
                    message = pc.encrypt((JArray)message);
                }
                else if (message.GetType() == typeof(JObject))
                {
                    message = pc.encrypt((JObject)message);
                }
            }
            else
            {
                message = JsonConvert.SerializeObject(message);
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
                    .Append(message);

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
            url.Add(message.ToString());

            // Return JSONArray
            return _request(url);
        }

        /**
         * Subscribe
         *
         * This function is NON BLOCKING.
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
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);

            string channel = args["channel"].ToString();
            Procedure callback = (Procedure)args["callback"];
            object timetoken = args["timestamp"];
            //  Begin Recursive Subscribe
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel);
                url.Add("0");
                url.Add(timetoken.ToString());

                // Wait for Message
                List<object> response = _request(url);

                // Update TimeToken
                if (response[1].ToString().Length > 0)
                    timetoken = (object)response[1];

                // Run user Callback and Reconnect if user permits.
                object message = "";
                JArray val = (JArray)response[0];
                for (int i = 0; i < val.Count; i++)
                {
                    if (this.CIPHER_KEY.Length > 0)
                    {
                        if (val[i].Type == JTokenType.String)
                        {
                            message = pc.decrypt((string)val[i]);
                        }
                        else if (val[i].Type == JTokenType.Object)
                        {
                            message = pc.decrypt((JObject)val[i]);
                        }
                        else if (val[i].Type == JTokenType.Array)
                        {
                            message = pc.decrypt((JArray)val[i]);
                        }
                    }
                    else
                    {
                        message = val[i];
                    }

                    if (!callback(message)) return;
                }

                // Keep listening if Okay.
                args["channel"] = channel;
                args["callback"] = callback;
                args["timestamp"] = timetoken;
                this._subscribe(args);
            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
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
                request.UserAgent = "C#-IIS";

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
                return JsonConvert.DeserializeObject<List<object>>(message);
            }
            catch (Exception)
            {
                return null;
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
                return _request(url);
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

        /**
        * UUID
        * @return string unique identifier         
        */
        public string UUID()
        {
            return Guid.NewGuid().ToString();
        }
    }
}