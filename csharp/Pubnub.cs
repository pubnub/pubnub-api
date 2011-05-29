using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Web.Script.Serialization;

/**
 * PubNub 3.0 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package pubnub
 */
public class PubnubTEST {
    static public void Main() {
        // -----------------
        // Init Pubnub Class
        // -----------------
        Pubnub pubnub = new Pubnub(
            "demo",  // PUBLISH_KEY
            "demo",  // SUBSCRIBE_KEY
            "",      // SECRET_KEY
            false    // SSL_ON?
        );
        string channel = "test-channel-顶";

        // ---------------
        // Publish Message
        // ---------------
        List<object> info = pubnub.Publish( channel, "Hello World" );

        // ----------------
        // Publish Response
        // ----------------
        Console.WriteLine(
            "Publish Success: " + info[0].ToString() +
            "\nPublish Info: "  + info[1]
        );

        // -------
        // History
        // -------
        List<object> history = pubnub.History( channel, 1 );
        foreach (object history_message in history) {
            Console.Write("History Message: ");
            Console.WriteLine(history_message);
        }

        // ----------------------
        // Get PubNub Server Time
        // ----------------------
        object timestamp = pubnub.Time();
        Console.WriteLine("Server Time: " + timestamp.ToString());

        // ---------
        // Subscribe
        // ---------
        pubnub.Subscribe(
            channel,
            delegate (object message) {
                Console.WriteLine("Received Message -> '" + message + "'");
                return true;
            }
        );
    }
}


/**
 * PubNub 3.0 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package pubnub
 */
public class Pubnub {
    private string ORIGIN        = "pubsub.pubnub.com";
    private int    LIMIT         = 1800;
    private string PUBLISH_KEY   = "";
    private string SUBSCRIBE_KEY = "";
    private string SECRET_KEY    = "";
    private bool   SSL           = false;

    public delegate bool Procedure(object message);

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
    ) {
        this.init( publish_key, subscribe_key, secret_key, ssl_on );
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
    ) {
        this.init( publish_key, subscribe_key, "", false );
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
    ) {
        this.init( publish_key, subscribe_key, secret_key, false );
    }

    /**
     * Init
     *
     * Prepare PubNub Class State.
     *
     * @param string Publish Key.
     * @param string Subscribe Key.
     * @param string Secret Key.
     * @param bool SSL Enabled.
     */
    public void init(
        string publish_key,
        string subscribe_key,
        string secret_key,
        bool ssl_on
    ) {
        this.PUBLISH_KEY   = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY    = secret_key;
        this.SSL           = ssl_on;

        // SSL On?
        if (this.SSL) {
            this.ORIGIN = "https://" + this.ORIGIN;
        }
        else {
            this.ORIGIN = "http://" + this.ORIGIN;
        }
    }

    /**
     * History
     *
     * Load history from a channel.
     *
     * @param String channel name.
     * @param int limit history count response.
     * @return ListArray of history.
     */
    public List<object> History( string channel, int limit ) {
        List<string> url = new List<string>();

        url.Add("history");
        url.Add(this.SUBSCRIBE_KEY);
        url.Add(channel);
        url.Add("0");
        url.Add(limit.ToString());

        return _request(url);
    }

    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param String channel name.
     * @param List<object> info.
     * @return bool false on fail.
     */
    public List<object> Publish( string channel, object message ) {
        JavaScriptSerializer serializer = new JavaScriptSerializer();

        // Generate String to Sign
        string signature = "0";
        if (this.SECRET_KEY.Length > 0) {
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
     * @param string channel name.
     * @param Procedure function callback.
     */
    public void Subscribe( string channel, Procedure callback ) {
        this._subscribe( channel, callback, 0 );
    }

    /**
     * Subscribe - Private Interface
     *
     * @param string channel name.
     * @param Procedure function callback.
     * @param string timetoken.
     */
    private void _subscribe(
        string    channel,
        Procedure callback,
        object    timetoken
    ) {
        // Begin Recusive Subscribe
        try {
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
            if (response[1].ToString().Length  > 0)
                timetoken = (object)response[1];

            // Run user Callback and Reconnect if user permits.
            foreach (object message in (object[])response[0]) {
                if (!callback(message)) return;
            }

            // Keep listening if Okay.
            this._subscribe( channel, callback, timetoken );
        }
        catch {
            System.Threading.Thread.Sleep(1000);
            this._subscribe( channel, callback, timetoken );
        }
    }

    /**
     * Time
     *
     * Timestamp from PubNub Cloud.
     *
     * @return object timestamp.
     */
    public object Time() {
        List<string> url = new List<string>();

        url.Add("time");
        url.Add("0");

        List<object> response = _request(url);
        return response[0];
    }

    /**
     * Request URL
     *
     * @param List<string> request of url directories.
     * @return List<object> from JSON response.
     */
    private List<object> _request(List<string> url_components) {
        string        temp  = null;
        int           count = 0;
        byte[]        buf   = new byte[8192];
        StringBuilder url   = new StringBuilder();
        StringBuilder sb    = new StringBuilder();

        JavaScriptSerializer serializer = new JavaScriptSerializer();

        // Add Origin To The Request
        url.Append(this.ORIGIN);

        // Generate URL with UTF-8 Encoding
        foreach ( string url_bit in url_components) {
            url.Append("/");
            url.Append(_encodeURIcomponent(url_bit));
        }

        // Fail if string too long
        if (url.Length > this.LIMIT) {
            List<object> too_long = new List<object>();
            too_long.Add(0);
            too_long.Add("Message Too Long.");
            return too_long;
        }

        // Create Request
        HttpWebRequest  request   = (HttpWebRequest)
            WebRequest.Create(url.ToString());

        // Set Timeout
        request.Timeout          = 200000;
        request.ReadWriteTimeout = 200000;

        // Receive Response
        HttpWebResponse response  = (HttpWebResponse)request.GetResponse();
        Stream          resStream = response.GetResponseStream();

        // Read
        do {
            count = resStream.Read( buf, 0, buf.Length );
            if (count != 0) {
                temp = Encoding.UTF8.GetString( buf, 0, count );
                sb.Append(temp);
            }
        } while (count > 0);

        // Parse Response
        string message = sb.ToString();

        return serializer.Deserialize<List<object>>(message);
    }

    private string _encodeURIcomponent(string s) {
        StringBuilder o = new StringBuilder();
        foreach (char ch in s.ToCharArray()) {
            if (isUnsafe(ch)) {
                o.Append('%');
                o.Append(toHex(ch / 16));
                o.Append(toHex(ch % 16));
            }
            else o.Append(ch);
        }
        return o.ToString();
    }

    private char toHex(int ch) {
        return (char)(ch < 10 ? '0' + ch : 'A' + ch - 10);
    }

    private bool isUnsafe(char ch) {
        return " ~`!@#$%^&*()+=[]\\{}|;':\",./<>?".IndexOf(ch) >= 0;
    }

    private static string md5(string text) {
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] data = Encoding.Default.GetBytes(text);
        byte[] hash = md5.ComputeHash(data);
        string hexaHash = "";
        foreach (byte b in hash) hexaHash += String.Format("{0:x2}", b);
        return hexaHash;
    }
}
 
