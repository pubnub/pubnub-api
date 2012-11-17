//using System;
//using System.IO;
//using System.Text;
//using System.Net;
//using System.Collections;
//using System.Collections.Generic;
//using System.Security.Cryptography;
//using System.Runtime.Serialization;
//using System.Runtime.Serialization.Json;
//using System.ComponentModel;
//using System.Reflection;
//using System.Web.Script.Serialization;
//using System.Threading;
//using System.Threading.Tasks;
//using System.Diagnostics;
//using System.Collections.Concurrent;
//using System.Net.NetworkInformation;
//using System.Net.Sockets;
//using System.Configuration;
//using Microsoft.Win32;
//using TvdP.Collections;

//namespace PubnubSilverlight.Core
//{
//    // INotifyPropertyChanged provides a standard event for objects to notify clients that one of its properties has changed

//    public class Pubnub : INotifyPropertyChanged
//    {
//        const int PUBNUB_WEBREQUEST_CALLBACK_INTERVAL_IN_SEC = 310;
//        const int PUBNUB_NETWORK_CHECK_CALLBACK_INTERVAL_IN_SEC = 5;
//        const int PUBNUB_NETWORK_CHECK_RETRIES = 50;
//        const int PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC = 15; // -1 = Disable Heartbeat; > 0 = heart beat timeout interval to check internet connection

//        // Common property changed event
//        public event PropertyChangedEventHandler PropertyChanged;
//        public void RaisePropertyChanged(string propertyName)
//        {
//            var handler = PropertyChanged;
//            if (handler != null)
//            {
//                handler(this, new PropertyChangedEventArgs(propertyName));
//            }
//        }

//        ConcurrentDictionary<string, bool> _channelSubscription = new ConcurrentDictionary<string, bool>();
//        ConcurrentDictionary<string, bool> _channelPresence = new ConcurrentDictionary<string, bool>();
//        ConcurrentDictionary<string, RequestState> _channelRequest = new ConcurrentDictionary<string, RequestState>();
//        ConcurrentDictionary<string, Timer> _channelReconnectTimer = new ConcurrentDictionary<string, Timer>();
//        ConcurrentDictionary<string, ReconnectState> _channelReconnectState = new ConcurrentDictionary<string, ReconnectState>();

//        System.Threading.Timer heartBeatTimer;

//        private static bool _pubnetInternetStatus = false;
//        private static bool _pubnetSystemActive = true;

//        //private static TraceSwitch appSwitch = new TraceSwitch("PubnubTraceSwitch", "Pubnub Trace Switch in config file"); *Changed*


//        // Publish
//        private ConcurrentDictionary<string, object> _publishMsg = new ConcurrentDictionary<string, object>();

//        // History of Messages
//        private List<object> _History = new List<object>();
//        public List<object> History { get { return _History; } set { _History = value; RaisePropertyChanged("History"); } }

//        // Subscribe
//        private ConcurrentDictionary<string, object> _subscribeMsg = new ConcurrentDictionary<string, object>();

//        // Presence
//        private ConcurrentDictionary<string, object> _presenceMsg = new ConcurrentDictionary<string, object>();

//        // Timestamp
//        private List<object> _Time = new List<object>();

//        // Pubnub Core API implementation
//        //private string ORIGIN = "pubsub.pubnub.com";
//        private string ORIGIN = "pizza.pubnub.com";
//        private int LIMIT = 1800; // Temporary setup, remove limit as server will handle this.
//        private string PUBLISH_KEY = "";
//        private string SUBSCRIBE_KEY = "";
//        private string SECRET_KEY = "";
//        private string CIPHER_KEY = "";
//        private bool SSL = false;
//        private string sessionUUID = "";
//        private string parameters = "";

//        /**
//         * Pubnub instance initialization function
//         * 
//         * @param string pubish_key.
//         * @param string subscribe_key.
//         * @param string secret_key.
//         * @param bool ssl_on
//         */
//        private void init(string publish_key, string subscribe_key, string secret_key, string cipher_key, bool ssl_on)
//        {
//            this.PUBLISH_KEY = publish_key;
//            this.SUBSCRIBE_KEY = subscribe_key;
//            this.SECRET_KEY = secret_key;
//            this.CIPHER_KEY = cipher_key;
//            this.SSL = ssl_on;
//            if (this.sessionUUID == "")
//                this.sessionUUID = Guid.NewGuid().ToString();

//            // SSL is ON?
//            if (this.SSL)
//                this.ORIGIN = "https://" + this.ORIGIN;
//            else
//                this.ORIGIN = "http://" + this.ORIGIN;

//            //Eventhough heart-beat is disabled, run one time to check internet connection by setting dueTime=0
//            heartBeatTimer = new System.Threading.Timer(
//                new TimerCallback(OnPubnubHeartBeatTimeoutCallback), null, 0,
//                (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? Timeout.Infinite : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000);

//            //Initiate System Events for PowerModeChanged - to monitor suspend/resume
//            initiatePowerModeCheck();
//        }

//        private void reconnectNetwork(ReconnectState netState)
//        {
//            System.Threading.Timer timer = new Timer(new TimerCallback(reconnectNetworkCallback), netState, 0, PUBNUB_NETWORK_CHECK_CALLBACK_INTERVAL_IN_SEC * 1000);
//            _channelReconnectTimer.AddOrUpdate(netState.channel, timer, (key, oldState) => timer);
//        }

//        void reconnectNetworkCallback(Object reconnectState)
//        {
//            try
//            {
//                ReconnectState netState = reconnectState as ReconnectState;
//                int currentRetry = netState.retryNum;
//                currentRetry++;
//                if (netState != null)
//                {
//                    netState.retryNum = currentRetry;
//                    if (!_pubnetInternetStatus && (currentRetry <= PUBNUB_NETWORK_CHECK_RETRIES))
//                    {
//                        //if (appSwitch.TraceInfo) *Changed*
//                        //{
//                        //    Debug.WriteLine(string.Format("DateTime {0} {1} out of {2} tries by callback to connect Internet for channel={3}", DateTime.Now.ToString(), currentRetry, PUBNUB_NETWORK_CHECK_RETRIES, netState.channel));
//                        //}
//                        ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//                        Thread.Sleep(1000);
//                    }
//                    else
//                    {
//                        netState.retryNum = currentRetry++;
//                        if (_channelReconnectTimer.ContainsKey(netState.channel))
//                        {
//                            System.Threading.Timer reconnectTimer = _channelReconnectTimer[netState.channel] as System.Threading.Timer;
//                            reconnectTimer.Change(Timeout.Infinite, Timeout.Infinite);
//                            reconnectTimer.Dispose();
//                            //if (appSwitch.TraceInfo) *Changed*
//                            //{
//                            //    Debug.WriteLine(string.Format("DateTime {0}, reconnectNetworkCallback. Stopped callback timer to connect Internet for channel={1}", DateTime.Now.ToString(), netState.channel));
//                            //}
                         
//                            bool removeFlag = _channelReconnectTimer.TryRemove(netState.channel, out reconnectTimer);
//                            //if (!removeFlag && appSwitch.TraceError) *Changed*
//                            //{
//                            //    Debug.WriteLine(string.Format("DateTime {0}, reconnectNetworkCallback. Unable to remove timer from dictionary for channel={1}", DateTime.Now.ToString(), netState.channel));
//                            //}

//                            if (_pubnetInternetStatus)
//                            {
//                                //if (appSwitch.TraceInfo) *Changed*
//                                //{
//                                //    Debug.WriteLine(string.Format("DateTime {0}, reconnectNetworkCallback. Internet Available : {1}", DateTime.Now.ToString(), _pubnetInternetStatus));
//                                //}
//                                switch (netState.type)
//                                {
//                                    case ResponseType.Subscribe:
//                                        _subscribe(netState.channel, netState.timetoken, netState.callback, false);
//                                        break;
//                                    case ResponseType.Presence:
//                                        _presence(netState.channel, netState.timetoken, netState.callback, false);
//                                        break;
//                                    default:
//                                        break;
//                                }
//                            }
//                            else
//                            {
//                                switch (netState.type)
//                                {
//                                    case ResponseType.Subscribe:
//                                        subscribeExceptionHandler(netState.channel, netState.callback, true);
//                                        break;
//                                    case ResponseType.Presence:
//                                        presenceExceptionHandler(netState.channel, netState.callback, true);
//                                        break;
//                                    default:
//                                        break;
//                                }
//                            }

//                        }
//                    }
//                }
//                else
//                {
//                    //if (appSwitch.TraceError) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime {0}, Unknown request state in reconnectNetworkCallback", DateTime.Now.ToString()));
//                    //}
//                }
//            }
//            catch (Exception ex)
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} method:reconnectNetworkCallback \n Exception Details={1}", DateTime.Now.ToString(), ex.ToString()));
//                //}
//            }
//        }

//        private void initiatePowerModeCheck()
//        {
//            //SystemEvents.PowerModeChanged += new PowerModeChangedEventHandler(SystemEvents_PowerModeChanged); *Changed*
//            //if (appSwitch.TraceInfo)
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, Initiated System Event - PowerModeChanged.", DateTime.Now.ToString()));
//            //}
//        }

//        //void SystemEvents_PowerModeChanged(object sender, PowerModeChangedEventArgs e) *Changed*
//        //{
//        //    if (e.Mode == PowerModes.Suspend)
//        //    {
//        //        _pubnetSystemActive = false;
//        //        TerminatePendingWebRequest(false);
//        //        heartBeatTimer.Change(Timeout.Infinite, Timeout.Infinite);
//        //        if (appSwitch.TraceInfo)
//        //        {
//        //            Debug.WriteLine(string.Format("DateTime {0}, System entered into Suspend Mode.", DateTime.Now.ToString()));
//        //            Debug.WriteLine(string.Format("DateTime {0}, Disabled Timer for heartbeat ", DateTime.Now.ToString()));
//        //        }
//        //    }
//        //    else if (e.Mode == PowerModes.Resume)
//        //    {
//        //        if (appSwitch.TraceInfo)
//        //        {
//        //            Debug.WriteLine(string.Format("DateTime {0}, System entered into Resume/Awake Mode.", DateTime.Now.ToString()));
//        //        }
//        //        _pubnetSystemActive = true;
//        //        heartBeatTimer.Change(
//        //            (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000,
//        //            (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000);
//        //    }
//        //}

//        private void TerminatePendingWebRequest(bool heartbeatTimeout)
//        {
//            ConcurrentDictionary<string, RequestState> webReq = _channelRequest;
//            ICollection<string> keyCol = _channelRequest.Keys;
//            foreach (string key in keyCol)
//            {
//                RequestState currReq = _channelRequest[key];
//                if (currReq.request != null)
//                {
//                    currReq.request.Abort();
//                    //if (appSwitch.TraceInfo) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime {0}, heartbeatTimeout={1}, TerminatePendingWebRequest {2}", DateTime.Now.ToString(), heartbeatTimeout.ToString(), currReq.request.RequestUri.ToString()));
//                    //}

//                    bool removeKey = _channelRequest.TryRemove(key, out currReq);
//                    //if (!removeKey && appSwitch.TraceError) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime {0}, heartbeatTimeout={1}, Unable to remove web request from dictionary in TerminatePendingWebRequest for channel= {1}", DateTime.Now.ToString(), heartbeatTimeout, key));
//                    //}
//                }
//            }
//        }

//        private void updateInternetStatus(bool status)
//        {
//            _pubnetInternetStatus = status;
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, updateInternetStatus. Internet Available : {1}", DateTime.Now.ToString(), status));
//            //}
//        }

//        ~Pubnub()
//        {
//            //detach
//            //SystemEvents.PowerModeChanged -= new PowerModeChangedEventHandler(SystemEvents_PowerModeChanged); *Changed*
//        }

//        /**
//         * PubNub 3.0 API
//         * 
//         * Prepare Pubnub messaging class initial state
//         * 
//         * @param string pubish_key.
//         * @param string subscribe_key.
//         * @param string secret_key.
//         * @param bool ssl_on
//         */
//        public Pubnub(string publish_key, string subscribe_key, string secret_key, string cipher_key, bool ssl_on)
//        {
//            this.init(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
//        }

//        /**
//         * PubNub 2.0 Compatibility
//         * 
//         * Prepare Pubnub messaging class initial state
//         * 
//         * @param string pubish_key.
//         * @param string subscribe_key.
//         */
//        public Pubnub(string publish_key, string subscribe_key)
//        {
//            this.init(publish_key, subscribe_key, "", "", false);
//        }

//        /**
//         * PubNub 3.0 without SSL
//         * 
//         * Prepare Pubnub messaging class initial state
//         * 
//         * @param string pubish_key.
//         * @param string subscribe_key.
//         * @param string secret_key.
//         */
//        public Pubnub(string publish_key, string subscribe_key, string secret_key)
//        {
//            this.init(publish_key, subscribe_key, secret_key, "", false);
//        }

//        /**
//         * History
//         * 
//         * Load history from a channel
//         * 
//         * @param String channel name.
//         * @param int limit history count response
//         * @return ListArray of history
//         */
//        public bool history(string channel, int limit)
//        {
//            List<string> url = new List<string>();

//            url.Add("history");
//            url.Add(this.SUBSCRIBE_KEY);
//            url.Add(channel);
//            url.Add("0");
//            url.Add(limit.ToString());

//            return _request(url, ResponseType.History);
//        }

//        /**
//         * Detailed History
//         */
//        public bool detailedHistory(string channel, long start, long end, int count, bool reverse, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }

//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);

//            parameters = "";
//            if (count <= -1) count = 100;
//            parameters = "?count=" + count;
//            if (reverse)
//                parameters = parameters + "&" + "reverse=" + reverse.ToString().ToLower();
//            if (start != -1)
//                parameters = parameters + "&" + "start=" + start.ToString().ToLower();
//            if (end != -1)
//                parameters = parameters + "&" + "end=" + end.ToString().ToLower();

//            List<string> url = new List<string>();

//            url.Add("v2");
//            url.Add("history");
//            url.Add("sub-key");
//            url.Add(this.SUBSCRIBE_KEY);
//            url.Add("channel");
//            url.Add(channel);

//            return _urlRequest(url, ResponseType.DetailedHistory, usercallback, false);
//        }

//        public bool detailedHistory(string channel, long start, Action<object> usercallback, bool reverse)
//        {
//            return detailedHistory(channel, start, -1, -1, reverse, usercallback);
//        }

//        public bool detailedHistory(string channel, int count, Action<object> usercallback)
//        {
//            return detailedHistory(channel, -1, -1, count, false, usercallback);
//        }

//        /**
//         * Publish
//         * 
//         * Send a message to a channel
//         * 
//         * @param String channel name.
//         * @param List<object> info.
//         * @return bool false on fail
//         */
//        public bool publish(string channel, object message, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel) || message == null)
//            {
//                throw new ArgumentException("Missing Channel or Message");
//            }

//            //TODO: Should we validate at constructor level
//            if (this.PUBLISH_KEY.Length == 0)
//            {
//                throw new MissingFieldException("PUBLISH_KEY cannot be empty for publish");
//            }

//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);

//            string msg = jsonEncodePublishMsg(message);

//            // Generate String to Sign
//            string signature = "0";
//            if (this.SECRET_KEY.Length > 0)
//            {
//                StringBuilder string_to_sign = new StringBuilder();
//                string_to_sign
//                    .Append(this.PUBLISH_KEY)
//                    .Append('/')
//                    .Append(this.SUBSCRIBE_KEY)
//                    .Append('/')
//                    .Append(this.SECRET_KEY)
//                    .Append('/')
//                    .Append(channel)
//                    .Append('/')
//                    .Append(msg); // 1

//                // Sign Message
//                signature = md5(string_to_sign.ToString());
//            }

//            // Build URL
//            List<string> url = new List<string>();
//            url.Add("publish");
//            url.Add(this.PUBLISH_KEY);
//            url.Add(this.SUBSCRIBE_KEY);
//            url.Add(signature);
//            url.Add(channel);
//            url.Add("0");
//            url.Add(msg);

//            return _urlRequest(url, ResponseType.Publish, usercallback, false);
//        }

//        private string jsonEncodePublishMsg(object originalMsg)
//        {
//            string msg = SerializeToJsonString(originalMsg);


//            if (this.CIPHER_KEY.Length > 0)
//            {
//                PubnubCrypto aes = new PubnubCrypto(this.CIPHER_KEY);
//                string encryptMsg = aes.encrypt(msg);
//                msg = SerializeToJsonString(encryptMsg);
//            }

//            return msg;
//        }

//        private object[] decodeMsg(object[] message, ResponseType type)
//        {
//            object[] msg = message;
//            object[] receivedMsg = new object[0];


//            if (type == ResponseType.Presence)
//            {
//                return msg;
//            }
//            else if (type == ResponseType.DetailedHistory)
//            {
//                receivedMsg = decodeDecryptLoop(msg);
//            }
//            else
//            {
//                receivedMsg = decodeDecryptLoop(msg);
//            }
//            return receivedMsg;
//        }

//        private object[] decodeDecryptLoop(object[] messageArray)
//        {
//            if (this.CIPHER_KEY.Length > 0)
//            {
//                List<object> receivedMsg = new List<object>();
//                foreach (object item in messageArray)
//                {
//                    PubnubCrypto aes = new PubnubCrypto(this.CIPHER_KEY);
//                    string decryptMsg = aes.decrypt(item.ToString());
//                    receivedMsg.Add(decryptMsg);
//                }
//                return receivedMsg.ToArray();
//            }
//            else
//            {
//                return messageArray;
//            }
//        }


//        /**
//         * Subscribe
//         * 
//         * Listen for a message on a channel (BLOCKING)
//         * 
//         * @param String channel name.
//         * @param Procedure function callback
//         */
//        public void subscribe(string channel, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }
//            if (usercallback == null)
//            {
//                throw new ArgumentException("Missing Callback");
//            }

//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, requested subscribe for channel={1}", DateTime.Now.ToString(), channel));
//            //}


//            if (_channelSubscription.ContainsKey(channel))
//            {
//                List<object> result = new List<object>();
//                string jsonString = "[0, \"Already subscribed\"]";
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON subscribe response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//            else
//            {
//                _channelSubscription.GetOrAdd(channel, true);
//                _subscribe(channel, 0, usercallback, false);
//            }

//        }

//        void OnPubnubWebRequestTimeout(object state, bool timeout)
//        {
//            if (timeout)
//            {
//                RequestState currentState = state as RequestState;
//                if (currentState != null)
//                {
//                    HttpWebRequest request = currentState.request;
//                    if (request != null)
//                    {
//                        //if (appSwitch.TraceInfo) *Changed*
//                        //{
//                        //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubWebRequestTimeout: client request timeout reached.Request aborted for channel = {1}", DateTime.Now.ToString(), currentState.channel));
//                        //}
//                        request.Abort();
//                    }
//                }
//                else
//                {
//                    //if (appSwitch.TraceError) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubWebRequestTimeout: client request timeout reached. However state is unknown", DateTime.Now.ToString()));
//                    //}
//                }

//                //reset heart beat time because http request already timedout
//                heartBeatTimer.Change(
//                    (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000,
//                    (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubWebRequestTimeout: resetting the heartbeat timeout", DateTime.Now.ToString()));
//                //}
//            }
//            else if (!_pubnetInternetStatus)
//            {
//                RequestState currentState = state as RequestState;
//                if (currentState != null)
//                {
//                    HttpWebRequest request = currentState.request;
//                    if (request != null)
//                    {
//                        //if (appSwitch.TraceInfo) *Changed*
//                        //{
//                        //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubWebRequestTimeout: No network detected. Request aborted for channel = {1}", DateTime.Now.ToString(), currentState.channel));
//                        //}
//                        request.Abort();
//                    }
//                }
//                else
//                {
//                    //if (appSwitch.TraceError) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubWebRequestTimeout: No network detected. However state is unknown", DateTime.Now.ToString()));
//                    //}
//                }
//            }
//        }

//        void OnPubnubHeartBeatTimeoutCallback(Object heartbeatState)
//        {
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime: {0}, **OnPubnubHeartBeatTimeoutCallback**", DateTime.Now.ToString()));
//            //}
//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);
//            if (!_pubnetInternetStatus)
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime: {0}, OnPubnubHeartBeatTimeoutCallback - No internet connection.", DateTime.Now.ToString()));
//                //}
//                TerminatePendingWebRequest(true);
//            }
//        }


//        /// <summary>
//        /// Check the response of the REST API and call for re-subscribe
//        /// </summary>
//        /// <param name="subscribeResult"></param>
//        /// <param name="usercallback"></param>
//        private void subscribeInternalCallback(object subscribeResult, Action<object> usercallback)
//        {
//            List<object> message = subscribeResult as List<object>;
//            string channelName = "";
//            if (message != null)
//            {
//                channelName = message[2].ToString();
//            }
//            else
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Lost Channel Name for resubscribe", DateTime.Now.ToString()));
//                //}
//                return;
//            }

//            if (!_channelSubscription.ContainsKey(channelName))
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Due to Unsubscribe, further re-subscription was stopped for channel {1}", DateTime.Now.ToString(), channelName.ToString()));
//                //}
//                return;
//            }


//            if (message != null && message.Count >= 3)
//            {
//                _subscribe(channelName, (object)message[1], usercallback, false); //TODO
//            }
//        }


//        private void presenceInternalCallback(object presenceResult, Action<object> usercallback)
//        {
//            List<object> message = presenceResult as List<object>;
//            string channelName = "";
//            if (message != null)
//            {
//                channelName = message[2].ToString();
//            }
//            else
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Lost Channel Name for re-presence", DateTime.Now.ToString()));
//                //}
//                return;
//            }


//            if (message != null && message.Count >= 3)
//            {
//                _presence(channelName, (object)message[1], usercallback, false);
//            }
//        }

//        /// <summary>
//        /// To unsubscribe a channel
//        /// </summary>
//        /// <param name="channel"></param>
//        /// <param name="usercallback"></param>
//        public void unsubscribe(string channel, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }

//            bool unsubStatus = false;
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, requested unsubscribe for channel={1}", DateTime.Now.ToString(), channel));
//            //}
//            if (_channelSubscription.ContainsKey(channel))
//            {
//                if (_channelRequest.ContainsKey(channel))
//                {
//                    HttpWebRequest storedRequest = _channelRequest[channel].request;
//                    storedRequest.Abort();
//                }
//                _channelSubscription.TryRemove(channel, out unsubStatus);

//                List<object> result = new List<object>();
//                string jsonString = "";
//                if (unsubStatus)
//                {
//                    jsonString = string.Format("[1, \"Unsubscribed from {0}\"]", channel);
//                }
//                else
//                {
//                    jsonString = string.Format("[1, \"Error unsubscribing from {0}\"]", channel);
//                }
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel);

//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON unsubscribe response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//            else
//            {
//                List<object> result = new List<object>();
//                string jsonString = "[0, \"Channel Not Subscribed\"]";
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON unsubscribe response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//        }

//        /**
//         * Subscribe - Private Interface
//         * 
//         * @param String channel name.
//         * @param Procedure function callback
//         * @param String timetoken.
//         */
//        private void _subscribe(string channel, object timetoken, Action<object> usercallback, bool reconnect)
//        {
//            //Exit if the channel is unsubscribed
//            if (!_channelSubscription.ContainsKey(channel))
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Due to Unsubscribe, further subscription was stopped for channel {1}", DateTime.Now.ToString(), channel.ToString()));
//                //}
//                return;
//            }

//            //Check internet connection
//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(1000);

//            //if (!_pubnetInternetStatus && _pubnetSystemActive) *Changed!!!*
//            //{
//            //    //if (appSwitch.TraceInfo) *Changed*
//            //    //{
//            //    //    Debug.WriteLine(string.Format("DateTime {0}, Subscribe - No internet connection for {1}", DateTime.Now.ToString(), channel));
//            //    //}

//            //    ReconnectState netState = new ReconnectState();
//            //    netState.channel = channel;
//            //    netState.type = ResponseType.Subscribe;
//            //    netState.callback = usercallback;
//            //    netState.timetoken = timetoken;

//            //    reconnectNetwork(netState);
//            //    return;
//            //}


//            // Begin recursive subscribe
//            try
//            {
//                // Build URL
//                List<string> url = new List<string>();
//                url.Add("subscribe");
//                url.Add(this.SUBSCRIBE_KEY);
//                url.Add(channel);
//                url.Add("0");
//                url.Add(timetoken.ToString());

//                // Wait for message
//                _urlRequest(url, ResponseType.Subscribe, usercallback, reconnect);
//            }
//            catch (Exception ex)
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} method:_subscribe \n channel={1} \n timetoken={2} \n Exception Details={3}", DateTime.Now.ToString(), channel, timetoken.ToString(), ex.ToString()));
//                //}
//                //TODO: Check if we need sleep time
//                System.Threading.Thread.Sleep(1000);
//                this._subscribe(channel, timetoken, usercallback, false);
//            }
//        }
//        /**
//         * Presence feature
//         * 
//         * Listen for a presence message on a channel (BLOCKING)
//         * 
//         * @param String channel name. (+"pnpres")
//         * @param Procedure function callback
//         */
//        public void presence(string channel, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }

//            if (usercallback == null)
//            {
//                throw new ArgumentException("Missing Callback");
//            }

//            channel = string.Format("{0}-pnpres", channel);
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, requested presence for channel={1}", DateTime.Now.ToString(), channel));
//            //}

//            if (_channelPresence.ContainsKey(channel))
//            {
//                List<object> result = new List<object>();
//                string jsonString = "[0, \"Presence Already subscribed\"]";
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON presence response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//            else
//            {
//                _channelPresence.GetOrAdd(channel, true);
//                this._presence(channel, 0, usercallback, false);
//            }
//        }
//        /**
//         * Presence feature - Private Interface
//         * 
//         * @param String channel name.
//         * @param Procedure function callback
//         * @param String timetoken.
//         */

//        private void _presence(string channel, object timetoken, Action<object> usercallback, bool reconnect)
//        {
//            //Exit if the channel is unsubscribed
//            if (!_channelPresence.ContainsKey(channel))
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Due to Presence-unsubscribe, further presence was stopped for channel {1}", DateTime.Now.ToString(), channel.ToString()));
//                //}
//                return;
//            }

//            //Check internet connection
//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);

//            if (!_pubnetInternetStatus)
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Presence - No internet connection for {1}", DateTime.Now.ToString(), channel));
//                //}

//                ReconnectState netState = new ReconnectState();
//                netState.channel = channel;
//                netState.type = ResponseType.Presence;
//                netState.callback = usercallback;
//                netState.timetoken = timetoken;

//                reconnectNetwork(netState);
//                return;
//            }

//            // Begin recursive subscribe
//            try
//            {
//                // Build URL
//                List<string> url = new List<string>();
//                url.Add("subscribe");
//                url.Add(this.SUBSCRIBE_KEY);
//                url.Add(channel);
//                url.Add("0");
//                url.Add(timetoken.ToString());

//                // Wait for message
//                _urlRequest(url, ResponseType.Presence, usercallback, reconnect);
//            }
//            catch (Exception ex)
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("method:_presence \n channel={0} \n timetoken={1} \n Exception Details={2}", channel, timetoken.ToString(), ex.ToString()));
//                //}
//                //TODO: Check if we need sleep time
//                System.Threading.Thread.Sleep(1000);
//                this._presence(channel, timetoken, usercallback, false);
//            }
//        }

//        public void presence_unsubscribe(string channel, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }

//            channel = string.Format("{0}-pnpres", channel);

//            bool unsubStatus = false;
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, requested presence-unsubscribe for channel={1}", DateTime.Now.ToString(), channel));
//            //}
//            if (_channelPresence.ContainsKey(channel))
//            {
//                if (_channelRequest.ContainsKey(channel))
//                {
//                    HttpWebRequest storedRequest = _channelRequest[channel].request;
//                    storedRequest.Abort();
//                }
//                _channelPresence.TryRemove(channel, out unsubStatus);

//                List<object> result = new List<object>();
//                string jsonString = "";
//                if (unsubStatus)
//                {
//                    jsonString = string.Format("[1, \"Presence-Unsubscribed from {0}\"]", channel.Replace("-pnpres", ""));
//                }
//                else
//                {
//                    jsonString = string.Format("[1, \"Error presence-unsubscribing from {0}\"]", channel.Replace("-pnpres", ""));
//                }
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel.Replace("-pnpres", ""));

//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON presence-unsubscribe response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//            else
//            {
//                List<object> result = new List<object>();
//                string jsonString = "[0, \"Channel Not Subscribed\"]";
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                result.Add(channel.Replace("-pnpres", ""));
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, JSON presence-unsubscribe response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(result.AsReadOnly());
//                }
//            }
//        }

//        public bool here_now(string channel, Action<object> usercallback)
//        {
//            if (string.IsNullOrWhiteSpace(channel))
//            {
//                throw new ArgumentException("Missing Channel");
//            }

//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);

//            List<string> url = new List<string>();

//            url.Add("v2");
//            url.Add("presence");
//            url.Add("sub_key");
//            url.Add(this.SUBSCRIBE_KEY);
//            url.Add("channel");
//            url.Add(channel);

//            return _urlRequest(url, ResponseType.Here_Now, usercallback, false);
//        }

//        /**
//         * Time
//         * 
//         * Timestamp from PubNub Cloud
//         * 
//         * @return object timestamp.
//         */
//        public bool time(Action<object> usercallback)
//        {
//            List<string> url = new List<string>();

//            ClientNetworkStatus.checkInternetStatus(_pubnetSystemActive, updateInternetStatus);
//            Thread.Sleep(2000);

//            url.Add("time");
//            url.Add("0");

//            return _urlRequest(url, ResponseType.Time, usercallback, false);
//        }
//        /**
//         * Http Get Request
//         * 
//         * @param List<string> request of URL directories.
//         * @return List<object> from JSON response.
//         */
//        private bool _request(List<string> url_components, ResponseType type)
//        {
//            List<object> result = new List<object>();
//            StringBuilder url = new StringBuilder();

//            // Add Origin To The Request
//            url.Append(this.ORIGIN);

//            // Generate URL with UTF-8 Encoding
//            foreach (string url_bit in url_components)
//            {
//                url.Append("/");
//                url.Append(_encodeURIcomponent(url_bit));
//            }

//            if (type == ResponseType.Presence || type == ResponseType.Subscribe)
//            {
//                url.Append("?uuid=");
//                url.Append(this.sessionUUID);
//            }

//            if (type == ResponseType.DetailedHistory)
//                url.Append(parameters);

//            // Temporary fail if string too long
//            if (url.Length > this.LIMIT)
//            {
//                result.Add(0);
//                result.Add("Message Too Long.");
//                // return result;
//            }

//            Uri requestUri = new Uri(url.ToString());

//            // Force canonical path and query
//            //string paq = requestUri.PathAndQuery; *Changed*
//            string paq = requestUri.AbsolutePath + requestUri.Query;
//            //
//            FieldInfo flagsFieldInfo = typeof(Uri).GetField("m_Flags", BindingFlags.Instance | BindingFlags.NonPublic);
//            ulong flags = (ulong)flagsFieldInfo.GetValue(requestUri);
//            flags &= ~((ulong)0x30); // Flags.PathNotCanonical|Flags.QueryNotCanonical
//            flagsFieldInfo.SetValue(requestUri, flags);

//            // Create Request
//            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestUri);

//            try
//            {
//                // Make request with the following inline Asynchronous callback
//                IAsyncResult asyncResult = request.BeginGetResponse(new AsyncCallback((asynchronousResult) =>
//                {
//                    HttpWebRequest aRequest = (HttpWebRequest)asynchronousResult.AsyncState;
//                    HttpWebResponse aResponse = (HttpWebResponse)aRequest.EndGetResponse(asynchronousResult);
//                    using (StreamReader streamReader = new StreamReader(aResponse.GetResponseStream()))
//                    {
//                        // Deserialize the result
//                        string jsonString = streamReader.ReadToEnd();
//                        result = WrapResultBasedOnResponseType(type, jsonString, url_components, false);
//                        //result = DeserializeToListOfObject(jsonString);
//                    }
//                }), request

//                );

//                return true;
//            }
//            catch (System.Exception ex)
//            {
//                Console.WriteLine(ex.ToString());
//                return false;
//            }
//        }

//        /* COPY OF _request method START  */
//        /**
//         * Http Get Request
//         * 
//         * @param List<string> request of URL directories.
//         * @return List<object> from JSON response.
//         */
//        private bool _urlRequest(List<string> url_components, ResponseType type, Action<object> usercallback, bool reconnect)
//        {
//            List<object> result = new List<object>();
//            string channelName = getChannelName(url_components, type);

//            StringBuilder url = new StringBuilder();

//            // Add Origin To The Request
//            url.Append(this.ORIGIN);

//            // Generate URL with UTF-8 Encoding
//            foreach (string url_bit in url_components)
//            {
//                url.Append("/");
//                url.Append(_encodeURIcomponent(url_bit));
//            }

//            if (type == ResponseType.Presence || type == ResponseType.Subscribe)
//            {
//                url.Append("?uuid=");
//                url.Append(this.sessionUUID);
//            }

//            if (type == ResponseType.DetailedHistory)
//                url.Append(parameters);

//            // Temporary fail if string too long
//            if (url.Length > this.LIMIT)
//            {
//                result.Add(0);
//                result.Add("Message Too Long.");
//                // return result;
//            }

//            Uri requestUri = new Uri(url.ToString());
            
//            // Force canonical path and query
//            //string paq = requestUri.PathAndQuery; *Changed*
//            string paq = requestUri.AbsolutePath + requestUri.Query;
//            //
//            //FieldInfo flagsFieldInfo = typeof(Uri).GetField("m_Flags", BindingFlags.Instance | BindingFlags.NonPublic);
//            //ulong flags = (ulong)flagsFieldInfo.GetValue(requestUri);
//            //flags &= ~((ulong)0x30); // Flags.PathNotCanonical|Flags.QueryNotCanonical
//            //flagsFieldInfo.SetValue(requestUri, flags);
           
           
//            try
//            {
//                // Create Request
//                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestUri);
               
//                //request.Timeout = PUBNUB_WEBREQUEST_CALLBACK_INTERVAL_IN_SEC * 1000; *Changed*

//                //
//                if ((!_channelSubscription.ContainsKey(channelName) && type == ResponseType.Subscribe)
//                    || (!_channelPresence.ContainsKey(channelName) && type == ResponseType.Presence))
//                {
//                    //if (appSwitch.TraceInfo) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime {0}, Due to Unsubscribe, request aborted for channel={1}", DateTime.Now.ToString(), channelName));
//                    //}
//                    request.Abort();
//                }

//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Request={1}", DateTime.Now.ToString(), requestUri.ToString()));
//                //}
                
//                RequestState pubnubRequestState = new RequestState();
//                pubnubRequestState.request = request;
//                pubnubRequestState.channel = channelName;

//                if (type == ResponseType.Subscribe || type == ResponseType.Presence)
//                {
//                    _channelRequest.AddOrUpdate(channelName, pubnubRequestState, (key, oldState) => pubnubRequestState);
//                }

//                try
//                {
//                    //Request(request.RequestUri.ToString());
//                }
//                catch (Exception)
//                {
                    
//                    throw;
//                }


//                // Make request with the following inline Asynchronous callback
//                #region a

//                IAsyncResult asyncResult = request.BeginGetResponse(new AsyncCallback((asynchronousResult) =>
//                {
//                    try
//                    {
//                        RequestState asynchRequestState = (RequestState)asynchronousResult.AsyncState;
//                        HttpWebRequest aRequest = (HttpWebRequest)asynchRequestState.request;

//                        if (aRequest != null)
//                        {
//                            using (HttpWebResponse aResponse = (HttpWebResponse)aRequest.EndGetResponse(asynchronousResult))
//                            {
//                                pubnubRequestState.response = aResponse;

//                                using (StreamReader streamReader = new StreamReader(aResponse.GetResponseStream()))
//                                {
//                                    // Deserialize the result
//                                    string jsonString = streamReader.ReadToEnd();
//                                    streamReader.Close();

//                                    heartBeatTimer.Change(
//                                        (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000,
//                                        (-1 == PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC) ? -1 : PUBNUB_HEARTBEAT_TIMEOUT_CALLBACK_IN_SEC * 1000);

//                                    //if (appSwitch.TraceInfo) *Changed*
//                                    //{
//                                    //    Debug.WriteLine(string.Format("DateTime {0}, JSON for channel={1} ({2}) ={3}", DateTime.Now.ToString(), channelName, type.ToString(), jsonString));
//                                    //}

//                                    result = WrapResultBasedOnResponseType(type, jsonString, url_components, reconnect);
//                                }
//                                aResponse.Close();
//                            }
//                        }
//                        else
//                        {
//                            //if (appSwitch.TraceInfo) *Changed*
//                            //{
//                            //    Debug.WriteLine(string.Format("DateTime {0}, Request aborted for channel={1}", DateTime.Now.ToString(), channelName));
//                            //}
//                        }

//                        if (result != null && result.Count >= 1 && usercallback != null)
//                        {
//                            responseToUserCallback(result, type, channelName, usercallback);
//                        }

//                        switch (type)
//                        {
//                            case ResponseType.Subscribe:
//                                subscribeInternalCallback(result, usercallback);
//                                break;
//                            case ResponseType.Presence:
//                                presenceInternalCallback(result, usercallback);
//                                break;
//                            default:
//                                break;
//                        }
//                    }
//                    catch (WebException webEx)
//                    {
//                        RequestState state = (RequestState)asynchronousResult.AsyncState;
//                        if (state.response != null)
//                            state.response.Close();

//                        //if (appSwitch.TraceError) *Changed*
//                        //{
//                        //    Debug.WriteLine(string.Format("DateTime {0}, WebException: {1} for URL: {2}", DateTime.Now.ToString(), webEx.Message, requestUri.ToString()));
//                        //}
//                        if (type == ResponseType.Subscribe)
//                        {
//                            subscribeExceptionHandler(channelName, usercallback, false);
//                        }
//                        else if (type == ResponseType.Presence)
//                        {
//                            presenceExceptionHandler(channelName, usercallback, false);
//                        }
//                        else if (type == ResponseType.Publish)
//                        {
//                            publishExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.Here_Now)
//                        {
//                            hereNowExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.DetailedHistory)
//                        {
//                            detailedHistoryExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.Time)
//                        {
//                            timeExceptionHandler(usercallback);
//                        }
//                    }
//                    catch (Exception ex)
//                    {
//                        RequestState state = (RequestState)asynchronousResult.AsyncState;
//                        if (state.response != null)
//                            state.response.Close();

//                        //if (appSwitch.TraceError) *Changed*
//                        //{
//                        //    Debug.WriteLine(string.Format("DateTime {0} Exception= {1} for URL: {2}", DateTime.Now.ToString(), ex.ToString(), requestUri.ToString()));
//                        //}
//                        if (type == ResponseType.Subscribe)
//                        {
//                            subscribeExceptionHandler(channelName, usercallback, false);
//                        }
//                        else if (type == ResponseType.Presence)
//                        {
//                            presenceExceptionHandler(channelName, usercallback, false);
//                        }
//                        else if (type == ResponseType.Publish)
//                        {
//                            publishExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.Here_Now)
//                        {
//                            hereNowExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.DetailedHistory)
//                        {
//                            detailedHistoryExceptionHandler(channelName, usercallback);
//                        }
//                        else if (type == ResponseType.Time)
//                        {
//                            timeExceptionHandler(usercallback);
//                        }
//                    }

//                }),pubnubRequestState);

//                #endregion
                
//                //ThreadPool.RegisterWaitForSingleObject(asyncResult.AsyncWaitHandle, new WaitOrTimerCallback(OnPubnubWebRequestTimeout), pubnubRequestState, PUBNUB_WEBREQUEST_CALLBACK_INTERVAL_IN_SEC * 1000, true);

//                return true;
//            }
//            catch (System.Exception ex)
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} Exception={1}", DateTime.Now.ToString(), ex.ToString()));
//                //}
//                return false;
//            }
//        }
//        /* COPY OF _request method END  */

//        private void responseToUserCallback(List<object> result, ResponseType type, string channelName, Action<object> usercallback)
//        {
//            switch (type)
//            {
//                case ResponseType.Subscribe:
//                    //*Changed*
//                    IList msgs = result[0] as IList;
//                    if (msgs != null && msgs.Count > 0 && _channelSubscription.ContainsKey(channelName))
//                    {
//                        usercallback(result.AsReadOnly());
//                        removeChannelRequest(channelName);
//                    }
//                    break;
//                case ResponseType.Presence:
//                    //*Changed*
//                    IList msgp = result[0] as IList;
//                    if (msgp != null && msgp.Count > 0 && _channelPresence.ContainsKey(channelName))
//                    {
//                        List<object> dupResult = result.GetRange(0, result.Count);
//                        dupResult[2] = ((string)dupResult[2]).Replace("-pnpres", "");
//                        usercallback(dupResult.AsReadOnly());
//                        removeChannelRequest(channelName);
//                    }
//                    break;
//                case ResponseType.Publish:
//                    if (result != null && result.Count > 0)
//                    {
//                        usercallback(result.AsReadOnly());
//                    }
//                    break;
//                case ResponseType.DetailedHistory:
//                    if (result != null && result.Count > 0)
//                    {
//                        usercallback(result.AsReadOnly());
//                    }
//                    break;
//                case ResponseType.Here_Now:
//                    if (result != null && result.Count > 0)
//                    {
//                        usercallback(result.AsReadOnly());
//                    }
//                    break;
//                case ResponseType.Time:
//                    if (result != null && result.Count > 0)
//                    {
//                        usercallback(result.AsReadOnly());
//                    }
//                    break;
//                default:
//                    break;
//            }
//        }

//        private void removeChannelRequest(string channelName)
//        {
//            if (_channelRequest.ContainsKey(channelName))
//            {
//                RequestState currentReq = _channelRequest[channelName];
//                currentReq.request = null;
//                currentReq.response = null;
//                bool remove = _channelRequest.TryRemove(channelName, out currentReq);
//                //if (!remove && appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} Unable to remove request from dictionary for channel ={1}", DateTime.Now.ToString(), channelName));
//                //}
//            }
//        }

//        private void subscribeExceptionHandler(string channelName, Action<object> usercallback, bool reconnectTry)
//        {
//            if (reconnectTry)
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, MAX retries reached. Exiting the subscribe for channel = {1}", DateTime.Now.ToString(), channelName));
//                //}

//                unsubscribe(channelName, null);

//                List<object> errorResult = new List<object>();
//                string jsonString = string.Format("[0, \"Unsubscribed after {0} failed retries\"]", PUBNUB_NETWORK_CHECK_RETRIES);
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                errorResult = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                errorResult.Add(channelName);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Subscribe JSON network error response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(errorResult.AsReadOnly());
//                }
//            }
//            else
//            {
//                List<object> result = new List<object>();
//                result.Add("0");
//                if (_subscribeMsg.ContainsKey(channelName))
//                {
//                    List<object> lastResult = _subscribeMsg[channelName] as List<object>;
//                    result.Add((lastResult != null) ? lastResult[1] : "0"); //get last timetoken
//                }
//                else
//                {
//                    result.Add("0"); //timetoken
//                }
//                result.Add(channelName); //send channel name

//                subscribeInternalCallback(result, usercallback);
//            }
//        }

//        private void presenceExceptionHandler(string channelName, Action<object> usercallback, bool reconnectTry)
//        {
//            if (reconnectTry)
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, MAX retries reached. Exiting the presence for channel = {1}", DateTime.Now.ToString(), channelName));
//                //}

//                presence_unsubscribe(channelName.Replace("-pnpres", ""), null);

//                List<object> errorResult = new List<object>();
//                string jsonString = string.Format("[0, \"Presence-unsubscribed after {0} failed retries\"]", PUBNUB_NETWORK_CHECK_RETRIES);
//                JavaScriptSerializer jS = new JavaScriptSerializer();
//                errorResult = (List<object>)jS.Deserialize<List<object>>(jsonString);
//                errorResult.Add(channelName);
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0}, Presence JSON network error response={1}", DateTime.Now.ToString(), jsonString));
//                //}
//                if (usercallback != null)
//                {
//                    usercallback(errorResult.AsReadOnly());
//                }
//            }
//            else
//            {
//                List<object> result = new List<object>();
//                result.Add("0");
//                if (_presenceMsg.ContainsKey(channelName))
//                {
//                    List<object> lastResult = _presenceMsg[channelName] as List<object>;
//                    result.Add((lastResult != null) ? lastResult[1] : "0"); //get last timetoken
//                }
//                else
//                {
//                    result.Add("0"); //timetoken
//                }
//                result.Add(channelName); //send channel name

//                presenceInternalCallback(result, usercallback);
//            }
//        }

//        private void publishExceptionHandler(string channelName, Action<object> usercallback)
//        {
//            List<object> result = new List<object>();
//            string jsonString = "[0, \"Network connnect error\"]";
//            JavaScriptSerializer jS = new JavaScriptSerializer();
//            result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//            result.Add(channelName);
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, JSON publish response={1}", DateTime.Now.ToString(), jsonString));
//            //}
//            if (usercallback != null)
//            {
//                usercallback(result.AsReadOnly());
//            }
//        }

//        private void hereNowExceptionHandler(string channelName, Action<object> usercallback)
//        {
//            List<object> result = new List<object>();
//            string jsonString = "[0, \"Network connnect error\"]";
//            JavaScriptSerializer jS = new JavaScriptSerializer();
//            result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//            result.Add(channelName);
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, JSON here_now response={1}", DateTime.Now.ToString(), jsonString));
//            //}
//            if (usercallback != null)
//            {
//                usercallback(result.AsReadOnly());
//            }
//        }

//        private void detailedHistoryExceptionHandler(string channelName, Action<object> usercallback)
//        {
//            List<object> result = new List<object>();
//            string jsonString = "[0, \"Network connnect error\"]";
//            JavaScriptSerializer jS = new JavaScriptSerializer();
//            result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//            result.Add(channelName);
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //    Debug.WriteLine(string.Format("DateTime {0}, JSON detailedHistoryExceptionHandler response={1}", DateTime.Now.ToString(), jsonString));
//            //}
//            if (usercallback != null)
//            {
//                usercallback(result.AsReadOnly());
//            }
//        }

//        private void timeExceptionHandler(Action<object> usercallback)
//        {
//            List<object> result = new List<object>();
//            string jsonString = "[0, \"Network connnect error\"]";
//            JavaScriptSerializer jS = new JavaScriptSerializer();
//            result = (List<object>)jS.Deserialize<List<object>>(jsonString);
//            //if (appSwitch.TraceInfo) *Changed*
//            //{
//            //   Debug.WriteLine(string.Format("DateTime {0}, JSON timeExceptionHandler response={1}", DateTime.Now.ToString(), jsonString));
//            //}
//            if (usercallback != null)
//            {
//                usercallback(result.AsReadOnly());
//            }
//        }

//        /// <summary>
//        /// Gets the result by wrapping the json response based on the request
//        /// </summary>
//        /// <param name="type"></param>
//        /// <param name="jsonString"></param>
//        /// <param name="url_components"></param>
//        /// <returns></returns>
//        private List<object> WrapResultBasedOnResponseType(ResponseType type, string jsonString, List<string> url_components, bool reconnect)
//        {
//            List<object> result = new List<object>();
//            string channelName = getChannelName(url_components, type);

//            JavaScriptSerializer jS = new JavaScriptSerializer();
//            result = jS.Deserialize<List<object>>(jsonString) as List<object>;

//            if (result != null && result.Count > 0 && result[0] is object[])
//            {
//                result[0] = decodeMsg((object[])result[0], type);
//            }


//            switch (type)
//            {
//                case ResponseType.Publish:
//                    result.Add(channelName);
//                    _publishMsg.AddOrUpdate(channelName, result, (key, oldValue) => result);
//                    break;
//                case ResponseType.History:
//                    if (this.CIPHER_KEY.Length > 0)
//                    {
//                        List<object> historyDecrypted = new List<object>();
//                        PubnubCrypto aes = new PubnubCrypto(this.CIPHER_KEY);
//                        foreach (object message in result)
//                        {
//                            historyDecrypted.Add(aes.decrypt(message.ToString()));
//                        }
//                        History = historyDecrypted;
//                    }
//                    else
//                    {
//                        History = result;
//                    }
//                    break;
//                case ResponseType.DetailedHistory:
//                    result.Add(channelName);
//                    break;
//                case ResponseType.Here_Now:
//                    var resultOccupancy = jS.DeserializeObject(jsonString);
//                    Dictionary<string, object> dic = (Dictionary<string, object>)resultOccupancy;
//                    result = new List<object>();
//                    result.Add(dic);
//                    result.Add(channelName);
//                    break;
//                case ResponseType.Time:
//                    _Time = result;
//                    break;
//                case ResponseType.Subscribe:
//                    result.Add(channelName);
//                    _subscribeMsg.AddOrUpdate(channelName, result, (key, oldValue) =>
//                    {
//                        if (reconnect)
//                        {
//                            List<object> oldResult = oldValue as List<object>;
//                            if (oldResult != null)
//                            {
//                                result[1] = oldResult[1];
//                            }
//                            return result;
//                        }
//                        else
//                        {
//                            return result;
//                        }
//                    });
//                    break;
//                case ResponseType.Presence:
//                    result.Add(channelName);
//                    _presenceMsg.AddOrUpdate(channelName, result, (key, oldValue) =>
//                    {
//                        if (reconnect)
//                        {
//                            List<object> oldResult = oldValue as List<object>;
//                            if (oldResult != null)
//                            {
//                                result[1] = oldResult[1];
//                            }
//                            return result;
//                        }
//                        else
//                        {
//                            return result;
//                        }
//                    });

//                    break;
//                default:
//                    break;
//            };//switch stmt end

//            return result;
//        }

//        /// <summary>
//        /// Retrieves the channel name from the url components
//        /// </summary>
//        /// <param name="url_components"></param>
//        /// <param name="type"></param>
//        /// <returns></returns>
//        private string getChannelName(List<string> url_components, ResponseType type)
//        {
//            string channelName = "";
//            switch (type)
//            {
//                case ResponseType.Subscribe:
//                    channelName = url_components[2];
//                    break;
//                case ResponseType.Publish:
//                    channelName = url_components[4];
//                    break;
//                case ResponseType.Presence:
//                    channelName = url_components[2];
//                    break;
//                case ResponseType.DetailedHistory:
//                    channelName = url_components[5];
//                    break;
//                case ResponseType.Here_Now:
//                    channelName = url_components[5];
//                    break;
//                default:
//                    break;
//            };
//            return channelName;
//        }

//        // Serialize the given object into JSON string
//        public static string SerializeToJsonString(object objectToSerialize)
//        {
//            using (MemoryStream ms = new MemoryStream())
//            {
//                DataContractJsonSerializer serializer = new DataContractJsonSerializer(objectToSerialize.GetType());
//                serializer.WriteObject(ms, objectToSerialize);
//                ms.Position = 0;

//                using (StreamReader reader = new StreamReader(ms))
//                {
//                    return reader.ReadToEnd();
//                }
//            }
//        }

//        // Deserialize JSON string into List of Objects
//        public static List<object> DeserializeToListOfObject(string jsonString)
//        {
//            using (MemoryStream ms = new MemoryStream(Encoding.Unicode.GetBytes(jsonString)))
//            {
//                DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(List<object>));

//                return (List<object>)serializer.ReadObject(ms);
//            }
//        }

//        private string _encodeURIcomponent(string s)
//        {
//            StringBuilder o = new StringBuilder();
//            foreach (char ch in s.ToCharArray())
//            {
//                if (isUnsafe(ch))
//                {
//                    o.Append('%');
//                    o.Append(toHex(ch / 16));
//                    o.Append(toHex(ch % 16));
//                }
//                else o.Append(ch);
//            }
//            return o.ToString();
//        }

//        private char toHex(int ch)
//        {
//            return (char)(ch < 10 ? '0' + ch : 'A' + ch - 10);
//        }

//        private bool isUnsafe(char ch)
//        {
//            return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".IndexOf(ch) >= 0;
//        }

//        public Guid generateGUID()
//        {
//            return Guid.NewGuid();
//        }

//        private static string md5(string text)
//        {
//            MD5 md5 = new MD5CryptoServiceProvider();
//            byte[] data = Encoding.Unicode.GetBytes(text);
//            byte[] hash = md5.ComputeHash(data);
//            string hexaHash = "";
//            foreach (byte b in hash) hexaHash += String.Format("{0:x2}", b);
//            return hexaHash;
//        }


//    }

//    /// <summary>
//    /// MD5 Service provider
//    /// </summary>
//    public class MD5CryptoServiceProvider : MD5
//    {
//        public MD5CryptoServiceProvider()
//            : base()
//        {
//        }
//    }
//    /// <summary>
//    /// MD5 messaging-digest algorithm is a widely used cryptographic hash function that produces 128-bit hash value.
//    /// </summary>
//    public class MD5 : IDisposable
//    {
//        static public MD5 Create(string hashName)
//        {
//            if (hashName == "MD5")
//                return new MD5();
//            else
//                throw new NotSupportedException();
//        }

//        static public String GetMd5String(String source)
//        {
//            MD5 md = MD5CryptoServiceProvider.Create();
//            byte[] hash;

//            //Create a new instance of ASCIIEncoding to 
//            //convert the string into an array of Unicode bytes.
//            UTF8Encoding enc = new UTF8Encoding();
//            //            ASCIIEncoding enc = new ASCIIEncoding();

//            //Convert the string into an array of bytes.
//            byte[] buffer = enc.GetBytes(source);

//            //Create the hash value from the array of bytes.
//            hash = md.ComputeHash(buffer);

//            StringBuilder sb = new StringBuilder();
//            foreach (byte b in hash)
//                sb.Append(b.ToString("x2"));
//            return sb.ToString();
//        }

//        static public MD5 Create()
//        {
//            return new MD5();
//        }

//        #region base implementation of the MD5
//        #region constants
//        private const byte S11 = 7;
//        private const byte S12 = 12;
//        private const byte S13 = 17;
//        private const byte S14 = 22;
//        private const byte S21 = 5;
//        private const byte S22 = 9;
//        private const byte S23 = 14;
//        private const byte S24 = 20;
//        private const byte S31 = 4;
//        private const byte S32 = 11;
//        private const byte S33 = 16;
//        private const byte S34 = 23;
//        private const byte S41 = 6;
//        private const byte S42 = 10;
//        private const byte S43 = 15;
//        private const byte S44 = 21;
//        static private byte[] PADDING = new byte[] {
//                                                        0x80, 0, 0, 0, 0, 0, 
//0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
//                                                        0, 0, 0, 0, 0, 0, 0, 
//0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
//                                                        0, 0, 0, 0, 0, 0, 0, 
//0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
//                                                    };
//        #endregion

//        #region F, G, H and I are basic MD5 functions.
//        static private uint F(uint x, uint y, uint z)
//        {
//            return (((x) & (y)) | ((~x) & (z)));
//        }
//        static private uint G(uint x, uint y, uint z)
//        {
//            return (((x) & (z)) | ((y) & (~z)));
//        }
//        static private uint H(uint x, uint y, uint z)
//        {
//            return ((x) ^ (y) ^ (z));
//        }
//        static private uint I(uint x, uint y, uint z)
//        {
//            return ((y) ^ ((x) | (~z)));
//        }
//        #endregion

//        #region rotates x left n bits.
//        /// <summary>
//        /// rotates x left n bits.
//        /// </summary>
//        /// <param name="x"></param>
//        /// <param name="n"></param>
//        /// <returns></returns>
//        static private uint ROTATE_LEFT(uint x, byte n)
//        {
//            return (((x) << (n)) | ((x) >> (32 - (n))));
//        }
//        #endregion

//        #region FF, GG, HH, and II transformations
//        /// FF, GG, HH, and II transformations 
//        /// for rounds 1, 2, 3, and 4.
//        /// Rotation is separate from addition to prevent re-computation.
//        static private void FF(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
//        {
//            (a) += F((b), (c), (d)) + (x) + (uint)(ac);
//            (a) = ROTATE_LEFT((a), (s));
//            (a) += (b);
//        }
//        static private void GG(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
//        {
//            (a) += G((b), (c), (d)) + (x) + (uint)(ac);
//            (a) = ROTATE_LEFT((a), (s));
//            (a) += (b);
//        }
//        static private void HH(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
//        {
//            (a) += H((b), (c), (d)) + (x) + (uint)(ac);
//            (a) = ROTATE_LEFT((a), (s));
//            (a) += (b);
//        }
//        static private void II(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
//        {
//            (a) += I((b), (c), (d)) + (x) + (uint)(ac);
//            (a) = ROTATE_LEFT((a), (s));
//            (a) += (b);
//        }
//        #endregion

//        #region context info
//        /// <summary>
//        /// state (ABCD)
//        /// </summary>
//        uint[] state = new uint[4];

//        /// <summary>
//        /// number of bits, modulo 2^64 (LSB first)
//        /// </summary>
//        uint[] count = new uint[2];

//        /// <summary>
//        /// input buffer
//        /// </summary>
//        byte[] buffer = new byte[64];
//        #endregion

//        internal MD5()
//        {
//            Initialize();
//        }

//        /// <summary>
//        /// MD5 initialization. Begins an MD5 operation, writing a new context.
//        /// </summary>
//        /// <remarks>
//        /// The RFC named it "MD5Init"
//        /// </remarks>
//        public virtual void Initialize()
//        {
//            count[0] = count[1] = 0;

//            // Load magic initialization constants.
//            state[0] = 0x67452301;
//            state[1] = 0xefcdab89;
//            state[2] = 0x98badcfe;
//            state[3] = 0x10325476;
//        }

//        /// <summary>
//        /// MD5 block update operation. Continues an MD5 message-digest
//        /// operation, processing another message block, and updating the
//        /// context.
//        /// </summary>
//        /// <param name="input"></param>
//        /// <param name="offset"></param>
//        /// <param name="count"></param>
//        /// <remarks>The RFC Named it MD5Update</remarks>
//        protected virtual void HashCore(byte[] input, int offset, int count)
//        {
//            int i;
//            int index;
//            int partLen;

//            // Compute number of bytes mod 64
//            index = (int)((this.count[0] >> 3) & 0x3F);

//            // Update number of bits
//            if ((this.count[0] += (uint)((uint)count << 3)) < ((uint)count << 3))
//                this.count[1]++;
//            this.count[1] += ((uint)count >> 29);

//            partLen = 64 - index;

//            // Transform as many times as possible.
//            if (count >= partLen)
//            {
//                Buffer.BlockCopy(input, offset, this.buffer, index, partLen);
//                Transform(this.buffer, 0);

//                for (i = partLen; i + 63 < count; i += 64)
//                    Transform(input, offset + i);

//                index = 0;
//            }
//            else
//                i = 0;

//            // Buffer remaining input 
//            Buffer.BlockCopy(input, offset + i, this.buffer, index, count - i);
//        }

//        /// <summary>
//        /// MD5 finalization. Ends an MD5 message-digest operation, writing the
//        /// the message digest and zeroizing the context.
//        /// </summary>
//        /// <returns>message digest</returns>
//        /// <remarks>The RFC named it MD5Final</remarks>
//        protected virtual byte[] HashFinal()
//        {
//            byte[] digest = new byte[16];
//            byte[] bits = new byte[8];
//            int index, padLen;

//            // Save number of bits
//            Encode(bits, 0, this.count, 0, 8);

//            // Pad out to 56 mod 64.
//            index = (int)((uint)(this.count[0] >> 3) & 0x3f);
//            padLen = (index < 56) ? (56 - index) : (120 - index);
//            HashCore(PADDING, 0, padLen);

//            // Append length (before padding)
//            HashCore(bits, 0, 8);

//            // Store state in digest 
//            Encode(digest, 0, state, 0, 16);

//            // Zeroize sensitive information.
//            count[0] = count[1] = 0;
//            state[0] = 0;
//            state[1] = 0;
//            state[2] = 0;
//            state[3] = 0;

//            // initialize again, to be ready to use
//            Initialize();

//            return digest;
//        }

//        /// <summary>
//        /// MD5 basic transformation. Transforms state based on 64 bytes block.
//        /// </summary>
//        /// <param name="block"></param>
//        /// <param name="offset"></param>
//        private void Transform(byte[] block, int offset)
//        {
//            uint a = state[0], b = state[1], c = state[2], d = state[3];
//            uint[] x = new uint[16];
//            Decode(x, 0, block, offset, 64);

//            // Round 1
//            FF(ref a, b, c, d, x[0], S11, 0xd76aa478); /* 1 */
//            FF(ref d, a, b, c, x[1], S12, 0xe8c7b756); /* 2 */
//            FF(ref c, d, a, b, x[2], S13, 0x242070db); /* 3 */
//            FF(ref b, c, d, a, x[3], S14, 0xc1bdceee); /* 4 */
//            FF(ref a, b, c, d, x[4], S11, 0xf57c0faf); /* 5 */
//            FF(ref d, a, b, c, x[5], S12, 0x4787c62a); /* 6 */
//            FF(ref c, d, a, b, x[6], S13, 0xa8304613); /* 7 */
//            FF(ref b, c, d, a, x[7], S14, 0xfd469501); /* 8 */
//            FF(ref a, b, c, d, x[8], S11, 0x698098d8); /* 9 */
//            FF(ref d, a, b, c, x[9], S12, 0x8b44f7af); /* 10 */
//            FF(ref c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
//            FF(ref b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
//            FF(ref a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
//            FF(ref d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
//            FF(ref c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
//            FF(ref b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

//            // Round 2
//            GG(ref a, b, c, d, x[1], S21, 0xf61e2562); /* 17 */
//            GG(ref d, a, b, c, x[6], S22, 0xc040b340); /* 18 */
//            GG(ref c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
//            GG(ref b, c, d, a, x[0], S24, 0xe9b6c7aa); /* 20 */
//            GG(ref a, b, c, d, x[5], S21, 0xd62f105d); /* 21 */
//            GG(ref d, a, b, c, x[10], S22, 0x2441453); /* 22 */
//            GG(ref c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
//            GG(ref b, c, d, a, x[4], S24, 0xe7d3fbc8); /* 24 */
//            GG(ref a, b, c, d, x[9], S21, 0x21e1cde6); /* 25 */
//            GG(ref d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
//            GG(ref c, d, a, b, x[3], S23, 0xf4d50d87); /* 27 */
//            GG(ref b, c, d, a, x[8], S24, 0x455a14ed); /* 28 */
//            GG(ref a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
//            GG(ref d, a, b, c, x[2], S22, 0xfcefa3f8); /* 30 */
//            GG(ref c, d, a, b, x[7], S23, 0x676f02d9); /* 31 */
//            GG(ref b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */

//            // Round 3
//            HH(ref a, b, c, d, x[5], S31, 0xfffa3942); /* 33 */
//            HH(ref d, a, b, c, x[8], S32, 0x8771f681); /* 34 */
//            HH(ref c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
//            HH(ref b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
//            HH(ref a, b, c, d, x[1], S31, 0xa4beea44); /* 37 */
//            HH(ref d, a, b, c, x[4], S32, 0x4bdecfa9); /* 38 */
//            HH(ref c, d, a, b, x[7], S33, 0xf6bb4b60); /* 39 */
//            HH(ref b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
//            HH(ref a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
//            HH(ref d, a, b, c, x[0], S32, 0xeaa127fa); /* 42 */
//            HH(ref c, d, a, b, x[3], S33, 0xd4ef3085); /* 43 */
//            HH(ref b, c, d, a, x[6], S34, 0x4881d05); /* 44 */
//            HH(ref a, b, c, d, x[9], S31, 0xd9d4d039); /* 45 */
//            HH(ref d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
//            HH(ref c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
//            HH(ref b, c, d, a, x[2], S34, 0xc4ac5665); /* 48 */

//            // Round 4
//            II(ref a, b, c, d, x[0], S41, 0xf4292244); /* 49 */
//            II(ref d, a, b, c, x[7], S42, 0x432aff97); /* 50 */
//            II(ref c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
//            II(ref b, c, d, a, x[5], S44, 0xfc93a039); /* 52 */
//            II(ref a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
//            II(ref d, a, b, c, x[3], S42, 0x8f0ccc92); /* 54 */
//            II(ref c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
//            II(ref b, c, d, a, x[1], S44, 0x85845dd1); /* 56 */
//            II(ref a, b, c, d, x[8], S41, 0x6fa87e4f); /* 57 */
//            II(ref d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
//            II(ref c, d, a, b, x[6], S43, 0xa3014314); /* 59 */
//            II(ref b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
//            II(ref a, b, c, d, x[4], S41, 0xf7537e82); /* 61 */
//            II(ref d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
//            II(ref c, d, a, b, x[2], S43, 0x2ad7d2bb); /* 63 */
//            II(ref b, c, d, a, x[9], S44, 0xeb86d391); /* 64 */

//            state[0] += a;
//            state[1] += b;
//            state[2] += c;
//            state[3] += d;

//            // Zeroize sensitive information.
//            for (int i = 0; i < x.Length; i++)
//                x[i] = 0;
//        }

//        /// <summary>
//        /// Encodes input (uint) into output (byte). Assumes len is
//        ///  multiple of 4.
//        /// </summary>
//        /// <param name="output"></param>
//        /// <param name="outputOffset"></param>
//        /// <param name="input"></param>
//        /// <param name="inputOffset"></param>
//        /// <param name="count"></param>
//        private static void Encode(byte[] output, int outputOffset, uint[] input, int inputOffset, int count)
//        {
//            int i, j;
//            int end = outputOffset + count;
//            for (i = inputOffset, j = outputOffset; j < end; i++, j += 4)
//            {
//                output[j] = (byte)(input[i] & 0xff);
//                output[j + 1] = (byte)((input[i] >> 8) & 0xff);
//                output[j + 2] = (byte)((input[i] >> 16) & 0xff);
//                output[j + 3] = (byte)((input[i] >> 24) & 0xff);
//            }
//        }

//        /// <summary>
//        /// Decodes input (byte) into output (uint). Assumes len is
//        /// a multiple of 4.
//        /// </summary>
//        /// <param name="output"></param>
//        /// <param name="outputOffset"></param>
//        /// <param name="input"></param>
//        /// <param name="inputOffset"></param>
//        /// <param name="count"></param>
//        static private void Decode(uint[] output, int outputOffset, byte[] input, int inputOffset, int count)
//        {
//            int i, j;
//            int end = inputOffset + count;
//            for (i = outputOffset, j = inputOffset; j < end; i++, j += 4)
//                output[i] = ((uint)input[j]) | (((uint)input[j + 1]) << 8) | (((uint)input[j + 2]) << 16) | (((uint)input[j + 3]) <<
//24);
//        }
//        #endregion

//        #region expose the same interface as the regular MD5 object

//        protected byte[] HashValue;
//        protected int State;
//        public virtual bool CanReuseTransform
//        {
//            get
//            {
//                return true;
//            }
//        }

//        public virtual bool CanTransformMultipleBlocks
//        {
//            get
//            {
//                return true;
//            }
//        }
//        public virtual byte[] Hash
//        {
//            get
//            {
//                if (this.State != 0)
//                    throw new InvalidOperationException();
//                return (byte[])HashValue.Clone();
//            }
//        }
//        public virtual int HashSize
//        {
//            get
//            {
//                return HashSizeValue;
//            }
//        }
//        protected int HashSizeValue = 128;

//        public virtual int InputBlockSize
//        {
//            get
//            {
//                return 1;
//            }
//        }
//        public virtual int OutputBlockSize
//        {
//            get
//            {
//                return 1;
//            }
//        }

//        public void Clear()
//        {
//            Dispose(true);
//        }

//        public byte[] ComputeHash(byte[] buffer)
//        {
//            return ComputeHash(buffer, 0, buffer.Length);
//        }
//        public byte[] ComputeHash(byte[] buffer, int offset, int count)
//        {
//            Initialize();
//            HashCore(buffer, offset, count);
//            HashValue = HashFinal();
//            return (byte[])HashValue.Clone();
//        }

//        public byte[] ComputeHash(Stream inputStream)
//        {
//            Initialize();
//            int count;
//            byte[] buffer = new byte[4096];
//            while (0 < (count = inputStream.Read(buffer, 0, 4096)))
//            {
//                HashCore(buffer, 0, count);
//            }
//            HashValue = HashFinal();
//            return (byte[])HashValue.Clone();
//        }

//        public int TransformBlock(
//            byte[] inputBuffer,
//            int inputOffset,
//            int inputCount,
//            byte[] outputBuffer,
//            int outputOffset
//            )
//        {
//            if (inputBuffer == null)
//            {
//                throw new ArgumentNullException("inputBuffer");
//            }
//            if (inputOffset < 0)
//            {
//                throw new ArgumentOutOfRangeException("inputOffset");
//            }
//            if ((inputCount < 0) || (inputCount > inputBuffer.Length))
//            {
//                throw new ArgumentException("inputCount");
//            }
//            if ((inputBuffer.Length - inputCount) < inputOffset)
//            {
//                throw new ArgumentOutOfRangeException("inputOffset");
//            }
//            if (this.State == 0)
//            {
//                Initialize();
//                this.State = 1;
//            }

//            HashCore(inputBuffer, inputOffset, inputCount);
//            if ((inputBuffer != outputBuffer) || (inputOffset != outputOffset))
//            {
//                Buffer.BlockCopy(inputBuffer, inputOffset, outputBuffer, outputOffset, inputCount);
//            }
//            return inputCount;
//        }
//        public byte[] TransformFinalBlock(
//            byte[] inputBuffer,
//            int inputOffset,
//            int inputCount
//            )
//        {
//            if (inputBuffer == null)
//            {
//                throw new ArgumentNullException("inputBuffer");
//            }
//            if (inputOffset < 0)
//            {
//                throw new ArgumentOutOfRangeException("inputOffset");
//            }
//            if ((inputCount < 0) || (inputCount > inputBuffer.Length))
//            {
//                throw new ArgumentException("inputCount");
//            }
//            if ((inputBuffer.Length - inputCount) < inputOffset)
//            {
//                throw new ArgumentOutOfRangeException("inputOffset");
//            }
//            if (this.State == 0)
//            {
//                Initialize();
//            }
//            HashCore(inputBuffer, inputOffset, inputCount);
//            HashValue = HashFinal();
//            byte[] buffer = new byte[inputCount];
//            Buffer.BlockCopy(inputBuffer, inputOffset, buffer, 0, inputCount);
//            this.State = 0;
//            return buffer;
//        }
//        #endregion

//        protected virtual void Dispose(bool disposing)
//        {
//            if (!disposing)
//                Initialize();
//        }
//        public void Dispose()
//        {
//            Dispose(true);
//        }
//    }

//    public class PubnubCrypto
//    {
//        private string CIPHER_KEY = "";
//        public PubnubCrypto(string cipher_key)
//        {
//            this.CIPHER_KEY = cipher_key;
//        }

//        /// <summary>
//        /// Computes the hash using the specified algo
//        /// </summary>
//        /// <returns>
//        /// The hash.
//        /// </returns>
//        /// <param name='input'>
//        /// Input string
//        /// </param>
//        /// <param name='algorithm'>
//        /// Algorithm to use for Hashing
//        /// </param>
//        public static string ComputeHash(string input, HashAlgorithm algorithm)
//        {
//            //Byte[] inputBytes = System.Text.Encoding.ASCII.GetBytes(input); *Changed*
//            Byte[] inputBytes = System.Text.Encoding.UTF8.GetBytes(input);
//            //
//            Byte[] hashedBytes = algorithm.ComputeHash(inputBytes);
//            return BitConverter.ToString(hashedBytes);
//        }

//        public string GetEncryptionKey()
//        {
//            //Compute Hash using the SHA256 
//            //string strKeySHA256HashRaw = ComputeHash(this.CIPHER_KEY, new SHA256CryptoServiceProvider()); *Changed*
//            string strKeySHA256HashRaw = ComputeHash(this.CIPHER_KEY, new System.Security.Cryptography.SHA256Managed());
//            //
//            //delete the "-" that appear after every 2 chars
//            string strKeySHA256Hash = (strKeySHA256HashRaw.Replace("-", "")).Substring(0, 32);
//            //convert to lower case
//            return strKeySHA256Hash.ToLower();
//        }

//        /**
//         * EncryptOrDecrypt
//         * 
//         * Basic function for encrypt or decrypt a string
//         * for encrypt type = true
//         * for decrypt type = false
//         */
//        public string EncryptOrDecrypt(bool type, string plainStr)
//        {
//            //RijndaelManaged aesEncryption = new RijndaelManaged(); *Changed*
//            //aesEncryption.KeySize = 256;
//            //aesEncryption.BlockSize = 128;
//            ////Mode CBC
//            //aesEncryption.Mode = CipherMode.CBC;
//            ////padding
//            //aesEncryption.Padding = PaddingMode.PKCS7;
//            ////get ASCII bytes of the string
//            //aesEncryption.IV = System.Text.Encoding.ASCII.GetBytes("0123456789012345");

//            //aesEncryption.Key = System.Text.Encoding.ASCII.GetBytes(GetEncryptionKey());
//            //JavaScriptSerializer ser = new JavaScriptSerializer();
//            //------
//            AesManaged aesEncryption = new AesManaged();
//            aesEncryption.KeySize = 256;
//            aesEncryption.BlockSize = 128;
     
//            aesEncryption.IV = Encoding.UTF8.GetBytes("0123456789012345");
//            aesEncryption.Key = Encoding.UTF8.GetBytes(GetEncryptionKey());

//            JavaScriptSerializer ser = new JavaScriptSerializer();
//            //
//            if (type)
//            {
//                ICryptoTransform crypto = aesEncryption.CreateEncryptor();

//                plainStr = EncodeNonAsciiCharacters(plainStr);
//                //Console.WriteLine(plainStr);

//                //byte[] plainText = Encoding.ASCII.GetBytes(plainStr); *Changed*
//                byte[] plainText = Encoding.UTF8.GetBytes(plainStr);
//                //
//                //byte[] plainText = Encoding.Unicode.GetBytes(plainStr);
//                //byte[] plainText = Encoding.GetEncoding(1252).GetBytes(plainStr);

//                //encrypt
//                byte[] cipherText = crypto.TransformFinalBlock(plainText, 0, plainText.Length);
//                return Convert.ToBase64String(cipherText);
//            }
//            else
//            {
//                ICryptoTransform decrypto = aesEncryption.CreateDecryptor();
//                //decode
//                byte[] decryptedBytes = Convert.FromBase64CharArray(plainStr.ToCharArray(), 0, plainStr.Length);
//                //byte[] decryptedBytes = Convert.FromBase64String(plainStr);
//                //decrypt

//                //string strDecrypted = System.Text.Encoding.ASCII.GetString(decrypto.TransformFinalBlock(decryptedBytes, 0, decryptedBytes.Length)); *Changed*
//                var data = decrypto.TransformFinalBlock(decryptedBytes, 0, decryptedBytes.Length);
//                string strDecrypted = Encoding.UTF8.GetString(data, 0, data.Length);
//                //
//                return strDecrypted;
//            }
//        }

//        // encrypt string
//        public string encrypt(string plainStr)
//        {
//            return EncryptOrDecrypt(true, plainStr);
//        }

//        // decrypt string
//        public string decrypt(string cipherStr)
//        {
//            return EncryptOrDecrypt(false, cipherStr);
//        }

//        //md5 used for AES encryption key
//        private static byte[] md5(string cipher_key)
//        {
//            MD5 obj = new MD5CryptoServiceProvider();
//            //byte[] data = Encoding.Default.GetBytes(cipher_key); *Changed*
//            byte[] data = Encoding.UTF8.GetBytes(cipher_key);
//            //
//            return obj.ComputeHash(data);
//        }
//        /// <summary>
//        /// Encodes the non ASCII characters.
//        /// </summary>
//        /// <returns>
//        /// The non ASCII characters.
//        /// </returns>
//        /// <param name='value'>
//        /// Value.
//        /// </param>
//        private string EncodeNonAsciiCharacters(string value)
//        {
//            StringBuilder sb = new StringBuilder();
//            foreach (char c in value)
//            {
//                if (c > 127)
//                {
//                    // This character is too big for ASCII
//                    string encodedValue = "\\u" + ((int)c).ToString("x4");
//                    sb.Append(encodedValue);
//                }
//                else
//                {
//                    sb.Append(c);
//                }
//            }
//            return sb.ToString();
//        }

//    }

//    internal enum ResponseType
//    {
//        Publish,
//        History,
//        Time,
//        Subscribe,
//        Presence,
//        Here_Now,
//        DetailedHistory,
//    }


//    internal class ReconnectState
//    {
//        public int retryNum;
//        public string channel;
//        public ResponseType type;
//        public Action<object> callback;
//        public object timetoken;

//        public ReconnectState()
//        {
//            retryNum = 0;
//            channel = "";
//            callback = null;
//            timetoken = null;
//        }
//    }

//    internal class RequestState
//    {
//        public HttpWebRequest request;
//        public HttpWebResponse response;
//        public string channel;

//        public RequestState()
//        {
//            request = null;
//            response = null;
//            channel = "";
//        }
//    }

//    internal class InternetState
//    {
//        public Action<bool> callback;
//        public IPAddress ipaddr;

//        public InternetState()
//        {
//            callback = null;
//            ipaddr = null;
//        }
//    }

//    internal class ClientNetworkStatus
//    {
//        //private static TraceSwitch appSwitch = new TraceSwitch("PubnubTraceSwitch", "Pubnub Trace Switch in config file"); *Changed*

//        internal static void checkInternetStatus(bool systemActive, Action<bool> callback)
//        {
//            if (callback != null)
//            {
//                try
//                {
//                    if (systemActive)
//                    {
//                        checkClientNetworkAvailability(callback);
//                    }
//                    else
//                    {
//                        callback(false);
//                    }
//                }
//                catch (Exception ex)
//                {
//                    //if (appSwitch.TraceError) *Changed*
//                    //{
//                    //    Debug.WriteLine(string.Format("DateTime {0} checkInternetStatus Error. {1}", DateTime.Now.ToString(), ex.ToString()));
//                    //}
//                }
//            }
//        }

//        private static void checkClientNetworkAvailability(Action<bool> callback)
//        {

//            //if (NetworkInterface.GetIsNetworkAvailable()) *Changed*
//            //{
//            //    NetworkInterface[] netInterfaces = NetworkInterface.GetAllNetworkInterfaces();
//            //    foreach (NetworkInterface netInterface in netInterfaces)
//            //    {
//            //        IPInterfaceProperties ip = netInterface.GetIPProperties();
//            //        if (netInterface.OperationalStatus == OperationalStatus.Up)
//            //        {
//            //            if (netInterface.NetworkInterfaceType != NetworkInterfaceType.Tunnel
//            //                && netInterface.NetworkInterfaceType != NetworkInterfaceType.Loopback)
//            //            {
//            //                //if (appSwitch.TraceInfo) *Changed*
//            //                //{
//            //                //    Debug.WriteLine(string.Format("DateTime {0} Network Interface = {1}", DateTime.Now.ToString(), netInterface.Description));
//            //                //}
//            //                IPInterfaceProperties prop = netInterface.GetIPProperties();
//            //                UnicastIPAddressInformationCollection unicast = prop.UnicastAddresses;

//            //                foreach (UnicastIPAddressInformation uniIP in unicast)
//            //                {
//            //                    IPAddress addrip = uniIP.Address;
//            //                    if (addrip.AddressFamily == AddressFamily.InterNetworkV6) continue;

//            //                    if (appSwitch.TraceInfo)
//            //                    {
//            //                        Debug.WriteLine(string.Format("DateTime {0} IP Address = {1}", DateTime.Now.ToString(), addrip.ToString()));
//            //                    }

//            //                    InternetState state = new InternetState();
//            //                    state.ipaddr = addrip;
//            //                    state.callback = callback;
//            //                    ThreadPool.QueueUserWorkItem(checkSocketConnect, state);
//            //                }
//            //            }
//            //        }
//            //    }
//            //}
//            //else
//            //{
//            //    callback(false);
//            //}
//        }

//        private static void checkSocketConnect(object internetState)
//        {
//            bool connected = false;
//            InternetState state = internetState as InternetState;
//            IPAddress ipaddr = state.ipaddr;
//            Action<bool> callback = state.callback;
//            try
//            {
//                using (Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp))
//                {
//                    //socket.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Linger, false); *Changed*
//                    //socket.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReceiveTimeout, 1000); *Changed*
             
//                    //IPEndPoint local = new IPEndPoint(ipaddr, 0); *Chenged*
//                    //socket.Bind(local);
//                    //socket.Connect("pubsub.pubnub.com", 80);
//                    //connected = true;
//                    //socket.Shutdown(SocketShutdown.Both);
//                    //socket.Disconnect(true);
//                    //socket.Close();
//                }
//            }
//            catch (ObjectDisposedException objEx)
//            {
//                //if (appSwitch.TraceInfo) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} checkSocketConnect Error. {1}", DateTime.Now.ToString(), objEx.ToString()));
//                //}
//            }
//            catch (Exception ex)
//            {
//                //if (appSwitch.TraceError) *Changed*
//                //{
//                //    Debug.WriteLine(string.Format("DateTime {0} checkSocketConnect Error. {1}", DateTime.Now.ToString(), ex.ToString()));
//                //}
//            }
//            callback(connected);
//        }

//    }
//}
