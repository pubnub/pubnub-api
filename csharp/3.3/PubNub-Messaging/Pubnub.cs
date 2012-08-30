using System;
using System.IO;
using System.Text;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.ComponentModel;
using System.Reflection;
using System.Web.Script.Serialization;

namespace PubNub_Messaging
{
    // INotifyPropertyChanged provides a standard event for objects to notify clients that one of its properties has changed
    public class Pubnub : INotifyPropertyChanged
    {
        // Common property changed event
        public event PropertyChangedEventHandler PropertyChanged;
        public void RaisePropertyChanged(string propertyName)
        {
            var handler = PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        // Message that is published through Pubnub
        private object _ReturnMessage = new object();
        public object ReturnMessage { get { return _ReturnMessage; } set { _ReturnMessage = value; RaisePropertyChanged("ReturnMessage"); } }

        // Publish
        private List<object> _Publish = new List<object>();
        public List<object> Publish { get { return _Publish; } set { _Publish = value; RaisePropertyChanged("Publish"); } }

        // History of Messages
        private List<object> _History = new List<object>();
        public List<object> History { get { return _History; } set { _History = value; RaisePropertyChanged("History"); } }

        // Detailed History of Message
        private object _DetailedHistory = new List<object>();
        public object DetailedHistory 
        {
            get { return _DetailedHistory; }
            set
            {
                _DetailedHistory = value; RaisePropertyChanged("DetailedHistory");
            }
        }

        // Here Now
        private List<object> _Here_Now = new List<object>();
        public List<object> Here_Now { get { return _Here_Now; } set { _Here_Now = value; RaisePropertyChanged("Here_Now"); } }

        // Subscribe
        private List<object> _Subscribe = new List<object>();
        public List<object> Subscribe
        {
            get
            {
                return _Subscribe;
            }
            set
            {
                _Subscribe = value;
                if (Int64.Parse(value[1].ToString()) > 0)
                    _subscribe(value[2].ToString(), Int64.Parse(value[1].ToString()) + 1);
                RaisePropertyChanged("Subscribe");
            }
        }

        // Presence
        private List<object> _Presence = new List<object>();
        public List<object> Presence
        {
            get
            {
                return _Presence;
            }
            set
            {
                _Presence = value;
                if (Int64.Parse(value[1].ToString()) > 0)
                    _presence(value[2].ToString(), Int64.Parse(value[1].ToString()) + 1);
                RaisePropertyChanged("Presence");
            }

        }
        // Timestamp
        private List<object> _Time = new List<object>();
        public List<object> Time { get { return _Time; } set { _Time = value; RaisePropertyChanged("Time"); } }

        // Pubnub Core API implementation
        private string      ORIGIN = "pubsub.pubnub.com";
        private int         LIMIT = 1800; // Temporary setup, remove limit as server will handle this.
        public string       PUBLISH_KEY = "";
        private string      SUBSCRIBE_KEY = "";
        public string       SECRET_KEY = "";
        private bool        SSL = false;
        private string      sessionUUID = "";
        private string      parameters = "";

        public delegate bool Procedure(object message);

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
        /**
         * Pubnub instance initialization function
         * 
         * @param string pubish_key.
         * @param string subscribe_key.
         * @param string secret_key.
         * @param bool ssl_on
         */
        public void init(string publish_key, string subscribe_key, string secret_key, bool ssl_on)
        {
            this.PUBLISH_KEY = publish_key;
            this.SUBSCRIBE_KEY = subscribe_key;
            this.SECRET_KEY = secret_key;
            this.SSL = ssl_on;
            if (this.sessionUUID == "")
                this.sessionUUID = Guid.NewGuid().ToString();

            // SSL is ON?
            if (this.SSL)
                this.ORIGIN = "https://" + this.ORIGIN;
            else
                this.ORIGIN = "http://" + this.ORIGIN;
        }
        /**
         * PubNub 3.0 API
         * 
         * Prepare Pubnub messaging class initial state
         * 
         * @param string pubish_key.
         * @param string subscribe_key.
         * @param string secret_key.
         * @param bool ssl_on
         */
        public Pubnub(string publish_key, string subscribe_key, string secret_key, bool ssl_on)
        {
            this.init(publish_key, subscribe_key, secret_key, ssl_on);
        }
        /**
         * PubNub 2.0 Compatibility
         * 
         * Prepare Pubnub messaging class initial state
         * 
         * @param string pubish_key.
         * @param string subscribe_key.
         */
        public Pubnub(string publish_key, string subscribe_key)
        {
            this.init(publish_key, subscribe_key, "", false);
        }
        /**
         * PubNub 3.0 without SSL
         * 
         * Prepare Pubnub messaging class initial state
         * 
         * @param string pubish_key.
         * @param string subscribe_key.
         * @param string secret_key.
         */
        public Pubnub(string publish_key, string subscribe_key, string secret_key)
        {
            this.init(publish_key, subscribe_key, secret_key, false);
        }
        /**
         * History
         * 
         * Load history from a channel
         * 
         * @param String channel name.
         * @param int limit history count response
         * @return ListArray of history
         */
        public bool history(string channel, int limit)
        {
            List<string> url = new List<string>();

            url.Add("history");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add(channel);
            url.Add("0");
            url.Add(limit.ToString());

            return _request(url, ResponseType.History);
        }

        /**
         * Detailed History
         */
        public bool detailedHistory(string channel, long start, long end, int count, bool reverse)
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

            return _request(url, ResponseType.DetailedHistory);
        }

        public bool detailedHistory(string channel, long start, bool reverse = false)
        {
            return detailedHistory(channel, start, -1, -1, reverse);
        }

        public bool detailedHistory(string channel, int count)
        {
            return detailedHistory(channel, -1, -1, count, false);
        }
        /**
         * Publish
         * 
         * Send a message to a channel
         * 
         * @param String channel name.
         * @param List<object> info.
         * @return bool false on fail
         */
        public bool publish(string channel, object message)
        {
            if (this.PUBLISH_KEY.Length == 0) return false;
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
                    .Append(SerializeToJsonString(message)); // 1
                ;
                // Sign Message
                signature = md5(string_to_sign.ToString());
            }

            // Build URL
            List<string> url = new List<string>();
            url.Add("publish");
            url.Add(this.PUBLISH_KEY);
            url.Add(this.SUBSCRIBE_KEY);
            url.Add(signature);
            url.Add(channel);
            url.Add("0");
            url.Add(SerializeToJsonString(message));

            return _request(url, ResponseType.Publish);
        }
        /**
         * Subscribe
         * 
         * Listen for a message on a channel (BLOCKING)
         * 
         * @param String channel name.
         * @param Procedure function callback
         */
        public void subscribe(string channel)
        {
            this._subscribe(channel, 0);
        }
        /**
         * Subscribe - Private Interface
         * 
         * @param String channel name.
         * @param Procedure function callback
         * @param String timetoken.
         */
        private void _subscribe(string channel, object timetoken)
        {
            // Begin recursive subscribe
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel);
                url.Add("0");
                url.Add(timetoken.ToString());
                
                // Wait for message
                _request(url, ResponseType.Subscribe);

                if (Subscribe.Count > 0)
                {
                    // Update TimeToken
                    if (Subscribe[1].ToString().Length > 0)
                        timetoken = (object)Subscribe[1];
                }
            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
                this._subscribe(channel, timetoken);
            }
        }
        /**
         * Presence feature
         * 
         * Listen for a presence message on a channel (BLOCKING)
         * 
         * @param String channel name. (+"pnpres")
         * @param Procedure function callback
         */
        public void presence(string channel)
        {
            this._presence(channel + "-pnpres", 0);
        }
        /**
         * Presence feature - Private Interface
         * 
         * @param String channel name.
         * @param Procedure function callback
         * @param String timetoken.
         */
        
        private void _presence(string channel, object timetoken)
        {
            // Begin recursive subscribe
            try
            {
                // Build URL
                List<string> url = new List<string>();
                url.Add("subscribe");
                url.Add(this.SUBSCRIBE_KEY);
                url.Add(channel);
                url.Add("0");
                url.Add(timetoken.ToString());

                // Wait for message
                _request(url, ResponseType.Presence);

                if (Presence.Count > 0)
                {
                    // Update TimeToken
                    if (Presence[1].ToString().Length > 0)
                        timetoken = (object)Presence[1];
                }
            }
            catch
            {
                System.Threading.Thread.Sleep(1000);
                this._presence(channel, timetoken);
            }
        }

        public bool here_now(string channel)
        {
            List<string> url = new List<string>();

            url.Add("v2");
            url.Add("presence");
            url.Add("sub_key");
            url.Add(this.SUBSCRIBE_KEY);
            url.Add("channel");
            url.Add(channel);
            
            return _request(url, ResponseType.Here_Now);
        }
        /**
         * Time
         * 
         * Timestamp from PubNub Cloud
         * 
         * @return object timestamp.
         */
        public bool time()
        {
            List<string> url = new List<string>();

            url.Add("time");
            url.Add("0");

            return _request(url, ResponseType.Time);
        }
        /**
         * Http Get Request
         * 
         * @param List<string> request of URL directories.
         * @return List<object> from JSON response.
         */
        private bool _request(List<string> url_components, ResponseType type)
        {
            List<object> result = new List<object>();
            StringBuilder url = new StringBuilder();

            // Add Origin To The Request
            url.Append(this.ORIGIN);

            // Generate URL with UTF-8 Encoding
            foreach (string url_bit in url_components)
            {
                url.Append("/");
                url.Append(_encodeURIcomponent(url_bit));
            }

            if (type == ResponseType.Presence || type == ResponseType.Subscribe)
            {
                url.Append("?uuid=");
                url.Append(this.sessionUUID);
            }

            if (type == ResponseType.DetailedHistory)
                url.Append(parameters);

            // Temporary fail if string too long
            if (url.Length > this.LIMIT)
            {
                result.Add(0);
                result.Add("Message Too Long.");
                // return result;
            }

            Uri requestUri = new Uri(url.ToString());

            // Force canonical path and query
            string paq = requestUri.PathAndQuery;
            FieldInfo flagsFieldInfo = typeof(Uri).GetField("m_Flags", BindingFlags.Instance | BindingFlags.NonPublic);
            ulong flags = (ulong)flagsFieldInfo.GetValue(requestUri);
            flags &= ~((ulong)0x30); // Flags.PathNotCanonical|Flags.QueryNotCanonical
            flagsFieldInfo.SetValue(requestUri, flags);

            // Create Request
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestUri);
            
            try
            {
                // Make request with the following inline Asynchronous callback
                request.BeginGetResponse(new AsyncCallback((asynchronousResult) =>
                    {
                        HttpWebRequest aRequest = (HttpWebRequest)asynchronousResult.AsyncState;
                        HttpWebResponse aResponse = (HttpWebResponse)aRequest.EndGetResponse(asynchronousResult);

                        using (StreamReader streamReader = new StreamReader(aResponse.GetResponseStream()))
                        {
                            // Deserialize the result
                            string jsonString = streamReader.ReadToEnd();
                            result = DeserializeToListOfObject(jsonString);

                            JavaScriptSerializer jS = new JavaScriptSerializer();
                            result = (List<object>)jS.Deserialize<List<object>>(jsonString);
                            var resultOccupancy = jS.DeserializeObject(jsonString);
                            
                            if ((result.Count != 0) && (type != ResponseType.DetailedHistory))
                            {
                                if (result[0] is object[])
                                {
                                    foreach (object message in (object[])result[0])
                                    {
                                        this.ReturnMessage = message;
                                    }
                                }
                            }
                            
                            switch (type)
                            {
                                case ResponseType.Publish:
                                    result.Add(url_components[4]);
                                    Publish = result;
                                    break;
                                case ResponseType.History:
                                    History = result;
                                    break;
                                case ResponseType.DetailedHistory:
                                    DetailedHistory = jsonString;
                                    break;
                                case ResponseType.Here_Now:
                                    Dictionary<string, object> dic = (Dictionary<string, object>)resultOccupancy;
                                    List<object> presented = new List<object>();
                                    presented.Add(dic);
                                    Here_Now = (List<object>)presented;
                                    break;
                                case ResponseType.Time:
                                    Time = result;
                                    break;
                                case ResponseType.Subscribe:
                                    result.Add(url_components[2]);
                                    Subscribe = result;
                                    break;
                                case ResponseType.Presence:
                                    result.Add(url_components[2]);
                                    Presence = result;
                                    break;
                                default:                                    
                                    break;
                            }
                        }
                    }), request
                    
                );
                return true;
            }
            catch (System.Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return false;
            }
        }

        // Serialize the given object into JSON string
        public static string SerializeToJsonString(object objectToSerialize)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                DataContractJsonSerializer serializer = new DataContractJsonSerializer(objectToSerialize.GetType());
                serializer.WriteObject(ms, objectToSerialize);
                ms.Position = 0;

                using (StreamReader reader = new StreamReader(ms))
                {
                    return reader.ReadToEnd();
                }
            }
        }

        // Deserialize JSON string into List of Objects
        public static List<object> DeserializeToListOfObject(string jsonString)
        {
            using (MemoryStream ms = new MemoryStream(Encoding.Unicode.GetBytes(jsonString)))
            {
                DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(List<object>));
                
                return (List<object>)serializer.ReadObject(ms);
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

        public Guid generateGUID()
        {
            return Guid.NewGuid();
        }

        public static string md5(string text)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] data = Encoding.Unicode.GetBytes(text);
            byte[] hash = md5.ComputeHash(data);
            string hexaHash = "";
            foreach (byte b in hash) hexaHash += String.Format("{0:x2}", b);
            return hexaHash;
        }
        
    }

    /// <summary>
    /// MD5 Service provider
    /// </summary>
    public class MD5CryptoServiceProvider : MD5
    {
        public MD5CryptoServiceProvider()
            : base()
        {
        }
    }
    /// <summary>
    /// MD5 messaging-digest algorithm is a widely used cryptographic hash function that produces 128-bit hash value.
    /// </summary>
    public class MD5 : IDisposable
    {
        static public MD5 Create(string hashName)
        {
            if (hashName == "MD5")
                return new MD5();
            else
                throw new NotSupportedException();
        }

        static public String GetMd5String(String source)
        {
            MD5 md = MD5CryptoServiceProvider.Create();
            byte[] hash;

            //Create a new instance of ASCIIEncoding to 
            //convert the string into an array of Unicode bytes.
            UTF8Encoding enc = new UTF8Encoding();
            //            ASCIIEncoding enc = new ASCIIEncoding();

            //Convert the string into an array of bytes.
            byte[] buffer = enc.GetBytes(source);

            //Create the hash value from the array of bytes.
            hash = md.ComputeHash(buffer);

            StringBuilder sb = new StringBuilder();
            foreach (byte b in hash)
                sb.Append(b.ToString("x2"));
            return sb.ToString();
        }

        static public MD5 Create()
        {
            return new MD5();
        }

        #region base implementation of the MD5
        #region constants
        private const byte S11 = 7;
        private const byte S12 = 12;
        private const byte S13 = 17;
        private const byte S14 = 22;
        private const byte S21 = 5;
        private const byte S22 = 9;
        private const byte S23 = 14;
        private const byte S24 = 20;
        private const byte S31 = 4;
        private const byte S32 = 11;
        private const byte S33 = 16;
        private const byte S34 = 23;
        private const byte S41 = 6;
        private const byte S42 = 10;
        private const byte S43 = 15;
        private const byte S44 = 21;
        static private byte[] PADDING = new byte[] {
														0x80, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
														0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
														0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
													};
        #endregion

        #region F, G, H and I are basic MD5 functions.
        static private uint F(uint x, uint y, uint z)
        {
            return (((x) & (y)) | ((~x) & (z)));
        }
        static private uint G(uint x, uint y, uint z)
        {
            return (((x) & (z)) | ((y) & (~z)));
        }
        static private uint H(uint x, uint y, uint z)
        {
            return ((x) ^ (y) ^ (z));
        }
        static private uint I(uint x, uint y, uint z)
        {
            return ((y) ^ ((x) | (~z)));
        }
        #endregion

        #region rotates x left n bits.
        /// <summary>
        /// rotates x left n bits.
        /// </summary>
        /// <param name="x"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        static private uint ROTATE_LEFT(uint x, byte n)
        {
            return (((x) << (n)) | ((x) >> (32 - (n))));
        }
        #endregion

        #region FF, GG, HH, and II transformations
        /// FF, GG, HH, and II transformations 
        /// for rounds 1, 2, 3, and 4.
        /// Rotation is separate from addition to prevent re-computation.
        static private void FF(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
        {
            (a) += F((b), (c), (d)) + (x) + (uint)(ac);
            (a) = ROTATE_LEFT((a), (s));
            (a) += (b);
        }
        static private void GG(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
        {
            (a) += G((b), (c), (d)) + (x) + (uint)(ac);
            (a) = ROTATE_LEFT((a), (s));
            (a) += (b);
        }
        static private void HH(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
        {
            (a) += H((b), (c), (d)) + (x) + (uint)(ac);
            (a) = ROTATE_LEFT((a), (s));
            (a) += (b);
        }
        static private void II(ref uint a, uint b, uint c, uint d, uint x, byte s, uint ac)
        {
            (a) += I((b), (c), (d)) + (x) + (uint)(ac);
            (a) = ROTATE_LEFT((a), (s));
            (a) += (b);
        }
        #endregion

        #region context info
        /// <summary>
        /// state (ABCD)
        /// </summary>
        uint[] state = new uint[4];

        /// <summary>
        /// number of bits, modulo 2^64 (LSB first)
        /// </summary>
        uint[] count = new uint[2];

        /// <summary>
        /// input buffer
        /// </summary>
        byte[] buffer = new byte[64];
        #endregion

        internal MD5()
        {
            Initialize();
        }

        /// <summary>
        /// MD5 initialization. Begins an MD5 operation, writing a new context.
        /// </summary>
        /// <remarks>
        /// The RFC named it "MD5Init"
        /// </remarks>
        public virtual void Initialize()
        {
            count[0] = count[1] = 0;

            // Load magic initialization constants.
            state[0] = 0x67452301;
            state[1] = 0xefcdab89;
            state[2] = 0x98badcfe;
            state[3] = 0x10325476;
        }

        /// <summary>
        /// MD5 block update operation. Continues an MD5 message-digest
        /// operation, processing another message block, and updating the
        /// context.
        /// </summary>
        /// <param name="input"></param>
        /// <param name="offset"></param>
        /// <param name="count"></param>
        /// <remarks>The RFC Named it MD5Update</remarks>
        protected virtual void HashCore(byte[] input, int offset, int count)
        {
            int i;
            int index;
            int partLen;

            // Compute number of bytes mod 64
            index = (int)((this.count[0] >> 3) & 0x3F);

            // Update number of bits
            if ((this.count[0] += (uint)((uint)count << 3)) < ((uint)count << 3))
                this.count[1]++;
            this.count[1] += ((uint)count >> 29);

            partLen = 64 - index;

            // Transform as many times as possible.
            if (count >= partLen)
            {
                Buffer.BlockCopy(input, offset, this.buffer, index, partLen);
                Transform(this.buffer, 0);

                for (i = partLen; i + 63 < count; i += 64)
                    Transform(input, offset + i);

                index = 0;
            }
            else
                i = 0;

            // Buffer remaining input 
            Buffer.BlockCopy(input, offset + i, this.buffer, index, count - i);
        }

        /// <summary>
        /// MD5 finalization. Ends an MD5 message-digest operation, writing the
        /// the message digest and zeroizing the context.
        /// </summary>
        /// <returns>message digest</returns>
        /// <remarks>The RFC named it MD5Final</remarks>
        protected virtual byte[] HashFinal()
        {
            byte[] digest = new byte[16];
            byte[] bits = new byte[8];
            int index, padLen;

            // Save number of bits
            Encode(bits, 0, this.count, 0, 8);

            // Pad out to 56 mod 64.
            index = (int)((uint)(this.count[0] >> 3) & 0x3f);
            padLen = (index < 56) ? (56 - index) : (120 - index);
            HashCore(PADDING, 0, padLen);

            // Append length (before padding)
            HashCore(bits, 0, 8);

            // Store state in digest 
            Encode(digest, 0, state, 0, 16);

            // Zeroize sensitive information.
            count[0] = count[1] = 0;
            state[0] = 0;
            state[1] = 0;
            state[2] = 0;
            state[3] = 0;

            // initialize again, to be ready to use
            Initialize();

            return digest;
        }

        /// <summary>
        /// MD5 basic transformation. Transforms state based on 64 bytes block.
        /// </summary>
        /// <param name="block"></param>
        /// <param name="offset"></param>
        private void Transform(byte[] block, int offset)
        {
            uint a = state[0], b = state[1], c = state[2], d = state[3];
            uint[] x = new uint[16];
            Decode(x, 0, block, offset, 64);

            // Round 1
            FF(ref a, b, c, d, x[0], S11, 0xd76aa478); /* 1 */
            FF(ref d, a, b, c, x[1], S12, 0xe8c7b756); /* 2 */
            FF(ref c, d, a, b, x[2], S13, 0x242070db); /* 3 */
            FF(ref b, c, d, a, x[3], S14, 0xc1bdceee); /* 4 */
            FF(ref a, b, c, d, x[4], S11, 0xf57c0faf); /* 5 */
            FF(ref d, a, b, c, x[5], S12, 0x4787c62a); /* 6 */
            FF(ref c, d, a, b, x[6], S13, 0xa8304613); /* 7 */
            FF(ref b, c, d, a, x[7], S14, 0xfd469501); /* 8 */
            FF(ref a, b, c, d, x[8], S11, 0x698098d8); /* 9 */
            FF(ref d, a, b, c, x[9], S12, 0x8b44f7af); /* 10 */
            FF(ref c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
            FF(ref b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
            FF(ref a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
            FF(ref d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
            FF(ref c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
            FF(ref b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

            // Round 2
            GG(ref a, b, c, d, x[1], S21, 0xf61e2562); /* 17 */
            GG(ref d, a, b, c, x[6], S22, 0xc040b340); /* 18 */
            GG(ref c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
            GG(ref b, c, d, a, x[0], S24, 0xe9b6c7aa); /* 20 */
            GG(ref a, b, c, d, x[5], S21, 0xd62f105d); /* 21 */
            GG(ref d, a, b, c, x[10], S22, 0x2441453); /* 22 */
            GG(ref c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
            GG(ref b, c, d, a, x[4], S24, 0xe7d3fbc8); /* 24 */
            GG(ref a, b, c, d, x[9], S21, 0x21e1cde6); /* 25 */
            GG(ref d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
            GG(ref c, d, a, b, x[3], S23, 0xf4d50d87); /* 27 */
            GG(ref b, c, d, a, x[8], S24, 0x455a14ed); /* 28 */
            GG(ref a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
            GG(ref d, a, b, c, x[2], S22, 0xfcefa3f8); /* 30 */
            GG(ref c, d, a, b, x[7], S23, 0x676f02d9); /* 31 */
            GG(ref b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */

            // Round 3
            HH(ref a, b, c, d, x[5], S31, 0xfffa3942); /* 33 */
            HH(ref d, a, b, c, x[8], S32, 0x8771f681); /* 34 */
            HH(ref c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
            HH(ref b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
            HH(ref a, b, c, d, x[1], S31, 0xa4beea44); /* 37 */
            HH(ref d, a, b, c, x[4], S32, 0x4bdecfa9); /* 38 */
            HH(ref c, d, a, b, x[7], S33, 0xf6bb4b60); /* 39 */
            HH(ref b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
            HH(ref a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
            HH(ref d, a, b, c, x[0], S32, 0xeaa127fa); /* 42 */
            HH(ref c, d, a, b, x[3], S33, 0xd4ef3085); /* 43 */
            HH(ref b, c, d, a, x[6], S34, 0x4881d05); /* 44 */
            HH(ref a, b, c, d, x[9], S31, 0xd9d4d039); /* 45 */
            HH(ref d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
            HH(ref c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
            HH(ref b, c, d, a, x[2], S34, 0xc4ac5665); /* 48 */

            // Round 4
            II(ref a, b, c, d, x[0], S41, 0xf4292244); /* 49 */
            II(ref d, a, b, c, x[7], S42, 0x432aff97); /* 50 */
            II(ref c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
            II(ref b, c, d, a, x[5], S44, 0xfc93a039); /* 52 */
            II(ref a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
            II(ref d, a, b, c, x[3], S42, 0x8f0ccc92); /* 54 */
            II(ref c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
            II(ref b, c, d, a, x[1], S44, 0x85845dd1); /* 56 */
            II(ref a, b, c, d, x[8], S41, 0x6fa87e4f); /* 57 */
            II(ref d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
            II(ref c, d, a, b, x[6], S43, 0xa3014314); /* 59 */
            II(ref b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
            II(ref a, b, c, d, x[4], S41, 0xf7537e82); /* 61 */
            II(ref d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
            II(ref c, d, a, b, x[2], S43, 0x2ad7d2bb); /* 63 */
            II(ref b, c, d, a, x[9], S44, 0xeb86d391); /* 64 */

            state[0] += a;
            state[1] += b;
            state[2] += c;
            state[3] += d;

            // Zeroize sensitive information.
            for (int i = 0; i < x.Length; i++)
                x[i] = 0;
        }

        /// <summary>
        /// Encodes input (uint) into output (byte). Assumes len is
        ///  multiple of 4.
        /// </summary>
        /// <param name="output"></param>
        /// <param name="outputOffset"></param>
        /// <param name="input"></param>
        /// <param name="inputOffset"></param>
        /// <param name="count"></param>
        private static void Encode(byte[] output, int outputOffset, uint[] input, int inputOffset, int count)
        {
            int i, j;
            int end = outputOffset + count;
            for (i = inputOffset, j = outputOffset; j < end; i++, j += 4)
            {
                output[j] = (byte)(input[i] & 0xff);
                output[j + 1] = (byte)((input[i] >> 8) & 0xff);
                output[j + 2] = (byte)((input[i] >> 16) & 0xff);
                output[j + 3] = (byte)((input[i] >> 24) & 0xff);
            }
        }

        /// <summary>
        /// Decodes input (byte) into output (uint). Assumes len is
        /// a multiple of 4.
        /// </summary>
        /// <param name="output"></param>
        /// <param name="outputOffset"></param>
        /// <param name="input"></param>
        /// <param name="inputOffset"></param>
        /// <param name="count"></param>
        static private void Decode(uint[] output, int outputOffset, byte[] input, int inputOffset, int count)
        {
            int i, j;
            int end = inputOffset + count;
            for (i = outputOffset, j = inputOffset; j < end; i++, j += 4)
                output[i] = ((uint)input[j]) | (((uint)input[j + 1]) << 8) | (((uint)input[j + 2]) << 16) | (((uint)input[j + 3]) <<
24);
        }
        #endregion

        #region expose the same interface as the regular MD5 object

        protected byte[] HashValue;
        protected int State;
        public virtual bool CanReuseTransform
        {
            get
            {
                return true;
            }
        }

        public virtual bool CanTransformMultipleBlocks
        {
            get
            {
                return true;
            }
        }
        public virtual byte[] Hash
        {
            get
            {
                if (this.State != 0)
                    throw new InvalidOperationException();
                return (byte[])HashValue.Clone();
            }
        }
        public virtual int HashSize
        {
            get
            {
                return HashSizeValue;
            }
        }
        protected int HashSizeValue = 128;

        public virtual int InputBlockSize
        {
            get
            {
                return 1;
            }
        }
        public virtual int OutputBlockSize
        {
            get
            {
                return 1;
            }
        }

        public void Clear()
        {
            Dispose(true);
        }

        public byte[] ComputeHash(byte[] buffer)
        {
            return ComputeHash(buffer, 0, buffer.Length);
        }
        public byte[] ComputeHash(byte[] buffer, int offset, int count)
        {
            Initialize();
            HashCore(buffer, offset, count);
            HashValue = HashFinal();
            return (byte[])HashValue.Clone();
        }

        public byte[] ComputeHash(Stream inputStream)
        {
            Initialize();
            int count;
            byte[] buffer = new byte[4096];
            while (0 < (count = inputStream.Read(buffer, 0, 4096)))
            {
                HashCore(buffer, 0, count);
            }
            HashValue = HashFinal();
            return (byte[])HashValue.Clone();
        }

        public int TransformBlock(
            byte[] inputBuffer,
            int inputOffset,
            int inputCount,
            byte[] outputBuffer,
            int outputOffset
            )
        {
            if (inputBuffer == null)
            {
                throw new ArgumentNullException("inputBuffer");
            }
            if (inputOffset < 0)
            {
                throw new ArgumentOutOfRangeException("inputOffset");
            }
            if ((inputCount < 0) || (inputCount > inputBuffer.Length))
            {
                throw new ArgumentException("inputCount");
            }
            if ((inputBuffer.Length - inputCount) < inputOffset)
            {
                throw new ArgumentOutOfRangeException("inputOffset");
            }
            if (this.State == 0)
            {
                Initialize();
                this.State = 1;
            }

            HashCore(inputBuffer, inputOffset, inputCount);
            if ((inputBuffer != outputBuffer) || (inputOffset != outputOffset))
            {
                Buffer.BlockCopy(inputBuffer, inputOffset, outputBuffer, outputOffset, inputCount);
            }
            return inputCount;
        }
        public byte[] TransformFinalBlock(
            byte[] inputBuffer,
            int inputOffset,
            int inputCount
            )
        {
            if (inputBuffer == null)
            {
                throw new ArgumentNullException("inputBuffer");
            }
            if (inputOffset < 0)
            {
                throw new ArgumentOutOfRangeException("inputOffset");
            }
            if ((inputCount < 0) || (inputCount > inputBuffer.Length))
            {
                throw new ArgumentException("inputCount");
            }
            if ((inputBuffer.Length - inputCount) < inputOffset)
            {
                throw new ArgumentOutOfRangeException("inputOffset");
            }
            if (this.State == 0)
            {
                Initialize();
            }
            HashCore(inputBuffer, inputOffset, inputCount);
            HashValue = HashFinal();
            byte[] buffer = new byte[inputCount];
            Buffer.BlockCopy(inputBuffer, inputOffset, buffer, 0, inputCount);
            this.State = 0;
            return buffer;
        }
        #endregion

        protected virtual void Dispose(bool disposing)
        {
            if (!disposing)
                Initialize();
        }
        public void Dispose()
        {
            Dispose(true);
        }
    }

    public class PubnubCrypto
    {
        private string CIPHER_KEY = "";
        public PubnubCrypto(string cipher_key)
        {
            this.CIPHER_KEY = cipher_key;
        }

        /**
         * EncryptOrDecrypt
         * 
         * Basic function for encrypt or decrypt a string
         * for encrypt type = true
         * for decrypt type = false
         */
        public string EncryptOrDecrypt(bool type, string plainStr)
        {
            RijndaelManaged aesEncryption = new RijndaelManaged();
            aesEncryption.KeySize = 256;
            aesEncryption.BlockSize = 128;
            aesEncryption.Mode = CipherMode.CBC;
            aesEncryption.Padding = PaddingMode.PKCS7;
            aesEncryption.IV = ASCIIEncoding.UTF8.GetBytes("0123456789012345");
            aesEncryption.Key = md5(this.CIPHER_KEY);
            if (type)
            {
                ICryptoTransform crypto = aesEncryption.CreateEncryptor();
                byte[] plainText = ASCIIEncoding.UTF8.GetBytes(plainStr);
                byte[] cipherText = crypto.TransformFinalBlock(plainText, 0, plainText.Length);
                return Convert.ToBase64String(cipherText);
            }
            else
            {
                ICryptoTransform decrypto = aesEncryption.CreateDecryptor();
                byte[] encryptedBytes = Convert.FromBase64CharArray(plainStr.ToCharArray(), 0, plainStr.Length);
                return ASCIIEncoding.UTF8.GetString(decrypto.TransformFinalBlock(encryptedBytes, 0, encryptedBytes.Length));
            }
        }

        // encrypt string
        public string encrypt(string plainStr)
        {
            return EncryptOrDecrypt(true, plainStr);
        }

        // decrypt string
        public string decrypt(string cipherStr)
        {
            return EncryptOrDecrypt(false, cipherStr);
        }

        //md5 used for AES encryption key
        private static byte[] md5(string cipher_key)
        {
            MD5 obj = new MD5CryptoServiceProvider();
            byte[] data = Encoding.Default.GetBytes(cipher_key);
            return obj.ComputeHash(data);
        }
    }
}
