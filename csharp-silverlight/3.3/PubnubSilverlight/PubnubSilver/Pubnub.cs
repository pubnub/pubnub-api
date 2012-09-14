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
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.IO;
using System.Threading;
using System.Windows.Threading;
using System.Net.Browser;
using System.Reflection;
using System.Diagnostics;

namespace PubnubSilver
{
   public class Channel_status 
    {
        public string channel;
        public bool connected, first;
   }
    public class pubnub
    {
        public enum ResponseType
        {
            Publish,
            History,
            Time,
            Subscribe,
            Presence,
            Here_Now,
            DetailedHistory,
        }

        private string ORIGIN = "pubsub.pubnub.com";
        private string PUBLISH_KEY = "";
        private string SUBSCRIBE_KEY = "";
        private string SECRET_KEY = "";
        private string CIPHER_KEY = "";
        private bool SSL = false;
        const int BUFFER_SIZE = 1024;
        private string sessionUUID = "";
        private string parameters = "";

        public delegate void ResponseCallback(object response);
        Callback callback;
        bool is_reconnected = false, is_disconnect = false;
        Int64 previousTimeToken = 0;
        private List<Channel_status> subscriptions = new List<Channel_status>();

        private List<object> _Subscribe = new List<object>();
        public List<object> subscribe
        {
            get
            {
                return _Subscribe;
            }
            set
            {
                string channel = value[2].ToString();
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
                
                // Problem?
                if (value == null || value[1].ToString() == "0")
                {

                    for (int i = 0; i < subscriptions.Count; i++)
                    {
                        Channel_status cs = subscriptions[i];
                        if (cs.channel == channel)
                        {
                            subscriptions.RemoveAt(i);
                            callback.disconnectCallback(channel);
                        }
                    }

                    // Ensure Connected (Call Time Function)
                    while (true)
                    {
                        string time_token = 0.ToString();
                        Time(
                            delegate(object response)
                            {
                                List<object> result = (List<object>)response;
                                time_token = result[0].ToString();
                            });

                        Thread.Sleep(2000);
                        if (time_token == "0")
                        {
                            // Reconnect Callback
                            callback.reconnectCallback(channel);
                            Thread.Sleep(5000);
                        }
                        else
                        {
                            is_reconnected = true;
                            break;
                        }
                    }
                }
                else
                {
                    previousTimeToken = Int64.Parse(value[1].ToString());
                    foreach (Channel_status cs in subscriptions)
                    {
                        if (cs.channel == channel)
                        {
                            // Connect Callback
                            if (!cs.first)
                            {
                                cs.first = true;                                
                                callback.connectCallback(channel);
                                break;
                            }
                        }
                    }
                }
                if (is_reconnected)
                {
                    is_reconnected = false;
                    Dictionary<string, object> tempArgs = new Dictionary<string, object>();
                    tempArgs.Add("channel", channel);
                    tempArgs.Add("timestamp", "0");
                    tempArgs.Add("callback", callback);                    
                    Subscribe(tempArgs);
                }
                else
                {
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
                    args.Add("channel", channel);
                    args.Add("timestamp", Int64.Parse(value[1].ToString()));
                    args.Add("callback", callback);                   
                    if (Int64.Parse(value[1].ToString()) > 0)
                        _subscribe(args);
                }
                
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
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
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

        private List<object> _Presence = new List<object>();
        public List<object> presence
        {
            get
            {
                return _Presence;
            }
            set
            {
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
                if (this.CIPHER_KEY.Length > 0)
                    value = pc.decrypt(value);
                _History = value;
            }
        }

        private List<object> _Here_Now = new List<object>();
        public List<object> here_Now
        {
            get
            {
                return _Here_Now;
            }
            set
            {
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
                if (this.CIPHER_KEY.Length > 0)
                    value = pc.decrypt(value);
                _History = value;
            }
        }

        private List<object> _DetailedHistory = new List<object>();
        public List<object> detailedHistory
        {
            get
            {
                return _DetailedHistory;
            }
            set
            {
                clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
                if (this.CIPHER_KEY.Length > 0)
                    value = pc.decrypt(value);
                _DetailedHistory = value;
            }
        }
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
         * PubNub 3.0
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
                this.ORIGIN = "https://" + this.ORIGIN;
            else
                this.ORIGIN = "http://" + this.ORIGIN;

            if (this.sessionUUID == "")
                this.sessionUUID = Guid.NewGuid().ToString();
        }
        /**
         * Publish
         *
         * Send a message to a channel.
         *
         * @param Dictionary<string, object> args 
         * args is string channel name and object message 
         * and callback to the response back i.e list of history messages
         */
        public void Publish(Dictionary<string, object> args)
        {
            string channel = args["channel"].ToString();
            object message = args["message"];
            ResponseCallback respCallback = (ResponseCallback)args["callback"];

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

            _request(url, respCallback,ResponseType.Publish);
        }

        /**
         * Subscribe
         *
         * This function is NON BLOCKING.
         * Listen for a message on a channel.
         *
         * @param Dictionary<string, object> args .
         *  args contains channel name and a delegate to get response back
         */

        public void Subscribe(Dictionary<string, object> args)
        {
            bool is_alreadyConnect = false;

            if(!args.ContainsKey("timestamp"))
                args.Add("timestamp", 0);
            string channel = args["channel"].ToString();
            // Validate Arguments
            if (args["callback"] != null)
            {
                callback = (Callback)args["callback"];
            }
            else
            {
                Debug.WriteLine("Invalid Callback.");
            }
            if (channel == null || channel == "")
            {
                callback.errorCallback(channel, "Invalid channel.");
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
                                cs.connected = true;                            
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
                        callback.errorCallback(channel ," Already Connected");
                        return;
                    }
            }
            else
            {
                // New Channel
                Channel_status cs = new Channel_status();
                cs.channel = channel;
                cs.connected = true;                
                subscriptions.Add(cs);
            }
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
        	is_disconnect = false;
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);            
            string channel = args["channel"].ToString();
            object timetoken = args["timestamp"];
           
                //  Begin Subscribe
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel);
                url.Add("0");
                url.Add(timetoken.ToString());                
                _request(url, null, ResponseType.Subscribe);              
               
            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
            }
        }

        /**
         * Request URL
         *
         * @param List<string> request of url directories.
         * @respCallback is a delegate to get async JSON response back
         */
        private void _request(List<string> url_components, ResponseCallback respCallback,ResponseType type)
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
                RequestState myRequestState = new RequestState();
                myRequestState.request = request;
                myRequestState.cb = respCallback;
                myRequestState.respType = type;
                if (type == ResponseType.Subscribe)
                {
                    myRequestState.channel = url_components[2];
                }
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
            try
            {
                myRequestState.response = (HttpWebResponse)myHttpWebRequest2.EndGetResponse(asyncResult);
                // Read the response into a Stream object.
                myRequestState.streamResponse = myRequestState.response.GetResponseStream();
                // Begin the Reading of the contents of the HTML page and print it to the console.
                IAsyncResult asynchronousInputRead = myRequestState.streamResponse.BeginRead(myRequestState.BufferRead, 0, BUFFER_SIZE, ReadCallBack, myRequestState);
            }
            catch (Exception)
            {
                List<object> error = new List<object>();
                if (myRequestState.respType == ResponseType.Time)
                {
                    error.Add("0");
                }
                else if (myRequestState.respType == ResponseType.History)
                {
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (myRequestState.respType == ResponseType.Publish)
                {
                    error.Add("0");
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (myRequestState.respType == ResponseType.Subscribe)
                {
                    error.Add("0");
                    error.Add("0");
                    error.Add(myRequestState.channel);
                    subscribe = error;
                }
            }
        }

        private void ReadCallBack(IAsyncResult asyncResult)
        {
            RequestState myRequestState = (RequestState)asyncResult.AsyncState;
            Stream responseStream = myRequestState.streamResponse;
            try
            {
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
                        foreach (Channel_status cs in subscriptions)
                        {
                            if (cs.channel == myRequestState.channel && !cs.connected && !is_disconnect)
                            {
                                callback.disconnectCallback(myRequestState.channel);
                                is_disconnect = true;                                
                                break;
                            }
                        }
                        if (is_disconnect)
                            return;
                            
                        subscribe = lstObj;
                        callback.responseCallback(myRequestState.channel, subscribe[0]);                        
                    }                    
                    else
                    {
                        myRequestState.cb(JsonConvert.DeserializeObject<List<object>>(myRequestState.requestData.ToString()));
                    }
                }
            }
            catch (Exception)
            {
                List<object> error = new List<object>();
                if (myRequestState.respType == ResponseType.Time)
                {
                    error.Add("0");
                }
                else if (myRequestState.respType == ResponseType.History)
                {
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (myRequestState.respType == ResponseType.Publish)
                {
                    error.Add("0");
                    error.Add("Error: Failed JSONP HTTP Request.");
                }
                else if (myRequestState.respType == ResponseType.Subscribe)
                {
                    error.Add("0");
                    error.Add("0");
                }
                myRequestState.cb(error);
            }
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
            _request(url, respCallback,ResponseType.Time);
            
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
            _request(url, respCallback,ResponseType.History);
        }

        public void Presence(Dictionary<string, object> args)
        {

        }

        /**
         * Presence
         *
         * This function is NON BLOCKING.
         * Listen for a message on a channel.
         *
         * @param Dictionary<string, object> args .
         *  args contains channel name and a delegate to get response back
         */

        public void Presence(Dictionary<string, object> args)
        {
            bool is_alreadyConnect = false;

            if (!args.ContainsKey("timestamp"))
                args.Add("timestamp", 0);
            string channel = args["channel"].ToString();
            // Validate Arguments
            if (args["callback"] != null)
            {
                callback = (Callback)args["callback"];
            }
            else
            {
                Debug.WriteLine("Invalid Callback.");
            }
            if (channel == null || channel == "")
            {
                callback.errorCallback(channel, "Invalid channel.");
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
                            cs.connected = true;
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
                    callback.errorCallback(channel, " Already Connected");
                    return;
                }
            }
            else
            {
                // New Channel
                Channel_status cs = new Channel_status();
                cs.channel = channel;
                cs.connected = true;
                subscriptions.Add(cs);
            }
            this._presence(args);
        }

        /**
          * _presence - Private Interface
          *
          * @param Dictionary<string, object> args
         *  args contains channel name and Procedure function callback and timetoken
          */
        private void _presence(Dictionary<string, object> args)
        {
            is_disconnect = false;
            clsPubnubCrypto pc = new clsPubnubCrypto(this.CIPHER_KEY);
            string channel = args["channel"].ToString();
            object timetoken = args["timestamp"];

            //  Begin Presence
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel + "-pnpres");
                url.Add("0");
                url.Add(timetoken.ToString());
                _request(url, null, ResponseType.Presence);

            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
            }
        }

        public void Here_Now(string channel)
        {
            List<string> url = new List<string>();

            url.Add("v2");
            url.Add("presence");
            url.Add("sub_key");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add("channel");
            url.Add(channel);

            _request(url, null, ResponseType.Here_Now);
        }

        /**
         * Detailed History
         */
        public void DetailedHistory(string channel, ResponseCallback respCallback, long start, long end, int count, bool reverse)
        {
            parameters = "";
            if (count == -1) count = 100;
            parameters = "?count=" + count;
            if (reverse)
                parameters = parameters + "&" + "reverse=" + reverse.ToString().ToLower();
            if (start != -1)
                parameters = parameters + "&" + "start=" + start.ToString().ToLower();
            if (end != -1)
                parameters = parameters + "&" + "end=" + end.ToString().ToLower();

            List<string> url = new List<string>();

            url.Add("v2");
            url.Add("history");
            url.Add("sub-key");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add("channel");
            url.Add(channel);

            _request(url, respCallback, ResponseType.History);
        }

        public void DetailedHistory(string channel, ResponseCallback respCallback, long start, bool reverse = false)
        {
            DetailedHistory(channel, respCallback,start, -1, -1, reverse);
        }

        public void DetailedHistory(string channel, ResponseCallback respCallback, int count)
        {
            DetailedHistory(channel, respCallback, -1, -1, count, false);
        }
       /**
        * Unsubscribe
        *
        * Unsubscribe/Disconnect to channel.
        *
        * @param Dictionary<String, Object> containing channel name.
        *
        **/
        public void Unsubscribe(Dictionary<String, Object> args)
        {
            String channel = args["channel"].ToString();           
            foreach (Channel_status cs in subscriptions)
            {
                if (cs.channel == channel && cs.connected)
                {
                    cs.connected = false;
                    cs.first = false;
                    callback.disconnectCallback(channel);
                    is_disconnect = true;
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
            byte[] data = Encoding.Unicode.GetBytes(text);
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
    public class RequestState
    {
        // This class stores the State of the request.
        const int BUFFER_SIZE = 1024;
        public StringBuilder requestData;
        public byte[] BufferRead;
        public HttpWebRequest request;
        public HttpWebResponse response;
        public Stream streamResponse;
        public pubnub.ResponseCallback cb;        
        public pubnub.ResponseType respType;
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
