using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Web.Script.Serialization;

/**
 * PubNub Customer API TEST CLASS
 */
public class PubnubTEST {
    static public void Main() {
        // ------------------------------------------------
        // USE MASTER CUSTOMER PUB/SUB/SEC Keys
        // ------------------------------------------------
        PubnubCustomer pubnub_customer = new PubnubCustomer(
            "",  // Master Account PUBLISH_KEY
            "",  // Master Account SUBSCRIBE_KEY
            ""   // Master Account SECRET_KEY
        );

        // ===================================================================
        // Customer Create /w Custom Data
        // ===================================================================
        Dictionary<object,object> data = new Dictionary<object,object>();

        data.Add( "internal_uid", "123456" );
        data.Add( "anything", "anything" );

        Dictionary<object,object> new_customer = pubnub_customer.Create(data);

        if ((int)new_customer["status"] != 200) {
            Console.WriteLine("Error, Unalbe to Create Customer:");
            Console.WriteLine(new_customer["message"]);
            return;
        }

        Console.WriteLine("================================================");
        Console.WriteLine("NEW CUSTOMER:");
        Console.WriteLine("status: "        + new_customer["status"]);
        Console.WriteLine("uid: "           + new_customer["uid"]);
        Console.WriteLine("publish_key: "   + new_customer["publish_key"]);
        Console.WriteLine("subscribe_key: " + new_customer["subscribe_key"]);
        Console.WriteLine("secret_key: "    + new_customer["secret_key"]);
        Console.WriteLine("CUSTOM VALUES:");
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("internal_uid: "  + new_customer["internal_uid"]);
        Console.WriteLine("anything: "      + new_customer["anything"]);
        Console.WriteLine("================================================");

        // ===================================================================
        // Customer Update
        // ===================================================================
        Dictionary<object,object> updates = new Dictionary<object,object>();

        updates.Add( "anything", "something else" );
        updates.Add( "more-data", "more custom data" );

        Dictionary<object,object> updated_customer = pubnub_customer.Update(
            (string)new_customer["uid"], // CUSTOMER'S UID
            updates                      // CUSTOM VALUE UPDATES
        );

        if ((int)updated_customer["status"] != 200) {
            Console.WriteLine("Error, Unalbe to Update Customer:");
            Console.WriteLine(updated_customer["message"]);
            return;
        }

        Console.WriteLine("================================================");
        Console.WriteLine("UPDATED CUSTOMER:");
        Console.WriteLine("status: "       + updated_customer["status"]);
        Console.WriteLine("UPDATED VALUES:");
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("internal_uid: " + updated_customer["internal_uid"]);
        Console.WriteLine("anything: "     + updated_customer["anything"]);
        Console.WriteLine("more-data: "    + updated_customer["more-data"]);
        Console.WriteLine("================================================");

        // ===================================================================
        // Customer Get
        // ===================================================================
        Dictionary<object,object> get_customer = pubnub_customer.Get(
            (string)updated_customer["uid"] // CUSTOMER'S UID
        );

        if ((int)get_customer["status"] != 200) {
            Console.WriteLine("Error, Unalbe to Get Customer:");
            Console.WriteLine(get_customer["message"]);
            return;
        }

        Console.WriteLine("================================================");
        Console.WriteLine("GET CUSTOMER:");
        Console.WriteLine("status: "        + get_customer["status"]);
        Console.WriteLine("uid: "           + get_customer["uid"]);
        Console.WriteLine("publish_key: "   + get_customer["publish_key"]);
        Console.WriteLine("subscribe_key: " + get_customer["subscribe_key"]);
        Console.WriteLine("secret_key: "    + get_customer["secret_key"]);
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("BALANCE VALUES:");
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("balance: " + get_customer["balance"]);
        Console.WriteLine("free_credits_used: " + get_customer["free_credits_used"]);
        Console.WriteLine("total_credits_used: " + get_customer["total_credits_used"]);
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("CUSTOM VALUES:");
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("internal_uid: "  + get_customer["internal_uid"]);
        Console.WriteLine("anything: "      + get_customer["anything"]);
        Console.WriteLine("more-data: "     + get_customer["more-data"]);
        Console.WriteLine("================================================");

        // ===================================================================
        // Disable Customer
        // ===================================================================
        Dictionary<object,object> disable_customer = pubnub_customer.Disable(
            (string)updated_customer["uid"] // CUSTOMER'S UID
        );

        Console.WriteLine("================================================");
        Console.WriteLine("DISABLE CUSTOMER:");
        Console.WriteLine("status: "   + disable_customer["status"]);
        Console.WriteLine("message: "  + disable_customer["message"]);
        Console.WriteLine("================================================");

        // ===================================================================
        // Enable Customer
        // ===================================================================
        Dictionary<object,object> enable_customer = pubnub_customer.Enable(
            (string)updated_customer["uid"] // CUSTOMER'S UID
        );

        Console.WriteLine("================================================");
        Console.WriteLine("ENABLE CUSTOMER:");
        Console.WriteLine("status: "   + enable_customer["status"]);
        Console.WriteLine("message: "  + enable_customer["message"]);
        Console.WriteLine("================================================");
    }
}


/**
 * PubNub Customer API
 *
 * @author Stephen Blum
 * @package PubnubCustomer
 */
public class PubnubCustomer {
    private string ORIGIN        = "http://pubnub-prod.appspot.com/";
    private string PUBLISH_KEY   = "";
    private string SUBSCRIBE_KEY = "";
    private string SECRET_KEY    = "";

    /**
     * Constructor
     *
     * Prepare PubNub Class State.
     *
     * @param string Publish Key.
     * @param string Subscribe Key.
     * @param string Secret Key.
     */
    public PubnubCustomer(
        string publish_key,
        string subscribe_key,
        string secret_key
    ) {
        this.PUBLISH_KEY   = publish_key;
        this.SUBSCRIBE_KEY = subscribe_key;
        this.SECRET_KEY    = secret_key;
    }

    /**
     * Create Customer
     *
     * Create a new customer and receive API Keys
     *
     * @param object custom_data with key/value dictionary data.
     * @return Dictionary<object,object> customer new API keys.
     */
    public Dictionary<object,object> Create( object custom_data ) {
        List<string> url = new List<string>();
        JavaScriptSerializer serializer = new JavaScriptSerializer();

        url.Add("customer-api-2.0-create?");
        url.Add(
            "custom-data=" +
            this.encodeURIcomponent(serializer.Serialize(custom_data))
        );

        return this.request(url);
    }

    /**
     * Update Customer
     *
     * Update a new customer and receive API Keys
     *
     * @param string cuuid PubNub Customer ID.
     * @param object custom_data with key/value dictionary data.
     * @return Dictionary<object,object> customer with updates and keys.
     */
    public Dictionary<object,object> Update(
        string cuuid,
        object custom_data
    ) {
        List<string> url = new List<string>();
        JavaScriptSerializer serializer = new JavaScriptSerializer();

        url.Add("customer-api-2.0-create?");
        url.Add("cuuid=" + cuuid);
        url.Add(
            "custom-data=" +
            this.encodeURIcomponent(serializer.Serialize(custom_data))
        );

        return this.request(url);
    }

    /**
     * Get Customer
     *
     * Get a customer and receive API Keys and Custom Data
     *
     * @param string cuuid PubNub Customer ID.
     * @param object custom_data with key/value dictionary data.
     * @return Dictionary<object,object> customer with updates and keys.
     */
    public Dictionary<object,object> Get( string cuuid ) {
        List<string> url = new List<string>();

        url.Add("customer-api-2.0-get?");
        url.Add("cuuid=" + cuuid);

        return this.request(url);
    }

    /**
     * Enable Customer
     *
     * Enable a Customer
     *
     * @param string cuuid PubNub Customer ID.
     * @return Dictionary<object,object> success info.
     */
    public Dictionary<object,object> Enable(string cuuid) {
        List<string> url = new List<string>();

        url.Add("customer-api-2.0-enable?");
        url.Add("cuuid=" + cuuid);
        url.Add("enabled=1");

        return this.request(url);
    }

    /**
     * Disable Customer
     *
     * Disable a Customer
     *
     * @param string cuuid PubNub Customer ID.
     * @return Dictionary<object,object> success info.
     */
    public Dictionary<object,object> Disable(string cuuid) {
        List<string> url = new List<string>();

        url.Add("customer-api-2.0-enable?");
        url.Add("cuuid=" + cuuid);
        url.Add("enabled=0");

        return this.request(url);
    }

    /**
     * Request URL
     *
     * @param List<string> request of url directories.
     * @return Dictionary<object,object> from JSON response.
     */
    private Dictionary<object,object> request(List<string> url_components) {
        string        temp      = null;
        int           count     = 0;
        byte[]        buf       = new byte[8192];
        StringBuilder url       = new StringBuilder();
        StringBuilder sb        = new StringBuilder();
        long          timestamp = this.unixTimeNow();

        JavaScriptSerializer serializer = new JavaScriptSerializer();

        // Add Origin To The Request
        url.Append(this.ORIGIN);

        // Add Signature
        url_components.Add("pub-key=" + this.PUBLISH_KEY);
        url_components.Add("timestamp=" + timestamp.ToString());
        url_components.Add("signature=" + this.createSignature(timestamp));
        url_components.Add("end=1");

        // Generate URL with UTF-8 Encoding
        foreach ( string url_bit in url_components) {
            url.Append(url_bit);
            url.Append("&");
        }

        /*
        Console.WriteLine("REQUEST:");
        Console.WriteLine(url.ToString());
        */

        // Create Request
        HttpWebRequest request = (HttpWebRequest)
            WebRequest.Create(url.ToString());

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

        /*
        Console.WriteLine("RESPONSE:");
        Console.WriteLine(message);
        */

        return serializer.Deserialize<Dictionary<object,object>>(message);
    }

    private string createSignature(long timestamp) {
        StringBuilder string_to_sign = new StringBuilder();
        string_to_sign
            .Append(this.PUBLISH_KEY)
            .Append('/')
            .Append(this.SUBSCRIBE_KEY)
            .Append('/')
            .Append(this.SECRET_KEY)
            .Append('/')
            .Append(timestamp);

        return md5(string_to_sign.ToString());
    }

    private long unixTimeNow() {
        TimeSpan _TimeSpan = (
            DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)
        );
        return (long)_TimeSpan.TotalSeconds;
    }

    private string encodeURIcomponent(string s) {
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
 
