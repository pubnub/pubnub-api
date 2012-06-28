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
using System.Threading;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Text;
using System.IO;
using System.Security.Cryptography;
using ICSharpCode.SharpZipLib.GZip;

namespace CSharp_WP7
{
    public class Pubnub
    {
        public enum ResponseType
        {
            Publish,
            History,
            Time,
            Subscribe
        }

        private string ORIGIN = "pubsub.pubnub.com";
        private string PUBLISH_KEY = "";
        private string SUBSCRIBE_KEY = "";
        private string SECRET_KEY = "";
        private string CIPHER_KEY = "";
        private bool SSL = false;
        const int BUFFER_SIZE = 1024;
        private ManualResetEvent webRequestDone;
        public delegate void ResponseCallback(object response);

        private List<object> _Subscribe = new List<object>();
        public List<object> subscribe
        {
            get
            {
                return _Subscribe;
            }
            set
            {
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                object message = "";
                JArray val = (JArray)value[0];
                object[] valObj = new object[val.Count];
                for (int i = 0; i < val.Count; i++)
                {
                    if (this.CIPHER_KEY.Length > 0)
                    {
                        if (val[i].Type == JTokenType.String)
                        {
                            message = pc.decrypt((string)val[i]);
                            valObj[i] = message;
                        }
                        else if (val[i].Type == JTokenType.Object)
                        {
                            message = pc.decrypt((JObject)val[i]);
                            valObj[i] = message;
                        }
                        else if (val[i].Type == JTokenType.Array)
                        {
                            message = pc.decrypt((JArray)val[i]);
                            valObj[i] = message;
                        }
                    }
                    else
                    {
                        valObj[i] = val[i];
                    }
                }
                value[0] = valObj;
                _Subscribe = value;
                Dictionary<string, object> args = new Dictionary<string, object>();
                args.Add("channel", value[2].ToString());
                args.Add("timestamp", Int64.Parse(value[1].ToString()) - 1);
                args.Add("callback", (ResponseCallback)value[3]);
                if (Int64.Parse(value[1].ToString()) > 0)
                    _subscribe(args);
            }
        }
        private List<object> _History = new List<object>();
        public List<object> history
        {
            get
            {
                return _History;
            }
            set
            {
                PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);
                if (this.CIPHER_KEY.Length > 0)
                {
                    value = pc.decrypt(value);
                    _History = value;
                }
                else
                {
                    _History = value;
                }
            }
        }

        /**
         * PubNub 3.1         
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         * @param string Cipher Key.
         * @param bool SSL Enabled.
         */
        public Pubnub(
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
         * PubNub 3.0
         *
         * Prepare PubNub Class State.
         *
         * @param string Publish Key.
         * @param string Subscribe Key.
         * @param string Secret Key.
         * @param bool SSL Enabled.
         */
        public Pubnub(
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
        public Pubnub(
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
        public Pubnub(
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
         * and callback to the response back 
         */
        public void Publish(Dictionary<string, object> args)
        {
            string channel = args["channel"].ToString();
            object message = args["message"];
            ResponseCallback respCallback = (ResponseCallback)args["callback"];

            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);

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

            _request(url, respCallback, ResponseType.Publish);
        }

        /**
         * Subscribe
         *
         * Listen for a message on a channel.
         *
         * @param Dictionary<string, object> args .
         *  args contains channel name and a delegate to get response back
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
         *  args contains channel name and Procedure function callback and timetoken
          */
        private void _subscribe(Dictionary<string, object> args)
        {
            PubnubCrypto pc = new PubnubCrypto(this.CIPHER_KEY);

            string channel = args["channel"].ToString();
            ResponseCallback respCallback = (ResponseCallback)args["callback"];
            object timetoken = args["timestamp"];
            //  Begin Recusive Subscribe
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel);
                url.Add("0");
                url.Add(timetoken.ToString());
                _request(url, respCallback, ResponseType.Subscribe);
            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
                this._subscribe(args);
            }
        }
        
        /**
        * History
        *
        * Load history from a channel.
        *
        * @param Dictionary<string, string> args
        * args is channel name and int limit history count response.
        * and callback to the response back i.e list of history messages
        */
        public void History(Dictionary<string, object> args)
        {
            string channel = args["channel"].ToString();
            int limit = Convert.ToInt32(args["limit"].ToString());
            ResponseCallback respCallback = (ResponseCallback)args["callback"];
            List<string> url = new List<string>();

            url.Add("history");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add(channel);
            url.Add("0");
            url.Add(limit.ToString());
            _request(url, respCallback, ResponseType.History);
        }
        
        /**
         * Time
         *
         * Timestamp from PubNub Cloud.
         *@param respCallback gets the response back i.e time
         * 
         */
        public void Time(ResponseCallback respCallback)
        {
            List<string> url = new List<string>();

            url.Add("time");
            url.Add("0");
            _request(url, respCallback, ResponseType.Time);

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
         * Request URL
         *
         * @param List<string> request of url directories.
         * @respCallback is a delegate to get async JSON response back
         */
        private void _request(List<string> url_components, ResponseCallback respCallback, ResponseType type)
        {
            try
            {
                StringBuilder url = new StringBuilder();

                // Add Origin To The Request
                url.Append(this.ORIGIN);

                // Generate URL with UTF-8 Encoding
                foreach (string url_bit in url_components)
                {
                    url.Append("/");
                    url.Append(_encodeURIcomponent(url_bit));
                }
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url.ToString());
                request.UserAgent = "C#-WP7";
                request.Headers["V"] = "3.1";
                request.Headers[HttpRequestHeader.AcceptEncoding] = "gzip";
                RequestState myRequestState = new RequestState();
                myRequestState.request = request;
                myRequestState.cb = respCallback;
                myRequestState.respType = type;
                if (url_components.Count > 2)
                {
                    myRequestState.channel = url_components[2];
                }
                request.Method = "GET";
                IAsyncResult result = (IAsyncResult)request.BeginGetResponse(requestCallBack, myRequestState);
            }
            catch (Exception)
            {

            }
        }
        private void requestCallBack(IAsyncResult asyncResult)
        {
            // State of request is asynchronous.
            RequestState myRequestState = (RequestState)asyncResult.AsyncState;
            HttpWebRequest myHttpWebRequest2 = myRequestState.request;
            myRequestState.response = (HttpWebResponse)myHttpWebRequest2.EndGetResponse(asyncResult);
            // Read the response into a Stream object.
            Stream stream = myRequestState.response.GetResponseStream();
            if (myRequestState.response.Headers[HttpRequestHeader.ContentEncoding].ToLower().Contains("gzip"))
                myRequestState.streamResponse  =  new GZipInputStream(stream);
            else
                myRequestState.streamResponse = stream;
            // Begin the Reading of the contents of the HTML page and print it to the console.
            IAsyncResult asynchronousInputRead = myRequestState.streamResponse.BeginRead(myRequestState.BufferRead, 0, BUFFER_SIZE, ReadCallBack, myRequestState);
        }

        private void ReadCallBack(IAsyncResult asyncResult)
        {
            RequestState myRequestState = (RequestState)asyncResult.AsyncState;
            Stream responseStream = myRequestState.streamResponse;
            int read = responseStream.EndRead(asyncResult);
            // Read the HTML page and then do something with it
            if (read > 0)
            {
                myRequestState.requestData.Append(Encoding.UTF8.GetString(myRequestState.BufferRead, 0, read));
                IAsyncResult asynchronousResult = responseStream.BeginRead(myRequestState.BufferRead, 0, BUFFER_SIZE, ReadCallBack, myRequestState);

                if (myRequestState.respType == ResponseType.History)
                {
                    history = JsonConvert.DeserializeObject<List<object>>(myRequestState.requestData.ToString());
                    myRequestState.cb(history);
                }
                else if (myRequestState.respType == ResponseType.Subscribe)
                {
                    List<object> lstObj = JsonConvert.DeserializeObject<List<object>>(myRequestState.requestData.ToString());
                    lstObj.Add(myRequestState.channel);
                    lstObj.Add(myRequestState.cb);
                    subscribe = lstObj;
                    myRequestState.cb(subscribe[0]);
                }
                else
                {
                    myRequestState.cb(JsonConvert.DeserializeObject<List<object>>(myRequestState.requestData.ToString()));
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
            byte[] data = Encoding.Unicode.GetBytes(text);
            byte[] hash = sha256.ComputeHash(data);
            string hexaHash = "";
            foreach (byte b in hash) hexaHash += String.Format("{0:x2}", b);
            return hexaHash;
        }
    }

    public class RequestState
    {
        // This class stores the State of the request.
        const int BUFFER_SIZE = 1024;
        public StringBuilder requestData;
        public byte[] BufferRead;
        public HttpWebRequest request;
        public HttpWebResponse response;
        public Stream streamResponse;
        public Pubnub.ResponseCallback cb;
        public Pubnub.ResponseType respType;
        public string channel;

        public RequestState()
        {
            BufferRead = new byte[BUFFER_SIZE];
            requestData = new StringBuilder("");
            request = null;
            streamResponse = null;
            cb = null;
        }
    }
}
