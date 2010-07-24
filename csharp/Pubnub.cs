using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections;
using NetServ.Net.Json;

public class PubnubTest {
    private static string channel       = "my_unique_channel";
    private static string PUBLISH_KEY   = "demo";
    private static string SUBSCRIBE_KEY = "demo";

    static public void Main() {
        // Example Publish Usage
        PubnubTest.test_publish1();
        PubnubTest.test_publish2();

        // Example History Usage
        PubnubTest.test_history();

        // Example Subscribe Usage
        PubnubTest.test_subscribe();
    }

    /// <summary>
    /// Test for Pubnub.publish( string, JsonObject )
    /// </summary>
    private static void test_publish1() {
        Console.WriteLine("TEST PUBLISH 1:");

        // Init Pubnub Class
        Pubnub pubnub  = new Pubnub(
            PubnubTest.PUBLISH_KEY,
            PubnubTest.SUBSCRIBE_KEY
        );

        JsonObject message = new JsonObject();

        // Add Key
        message.Add( "my_var", "Hello World 2!" );

        // Send (Publish) Message
        JsonObject response = pubnub.publish( PubnubTest.channel, message );

        // Print Stuff
        Console.WriteLine("Status: " + response["status"]);
        Console.WriteLine("-----------------------------------------------\n");
    }

    /// <summary>
    /// Test for Pubnub.publish( string, JsonObject )
    /// </summary>
    private static void test_publish2() {
        Console.WriteLine("TEST PUBLISH 2:");

        // Init Pubnub Class
        Pubnub pubnub  = new Pubnub(
            PubnubTest.PUBLISH_KEY,
            PubnubTest.SUBSCRIBE_KEY
        );

        JsonWriter writer  = new JsonWriter();
        JsonObject message = new JsonParser( new StringReader(
            "{\"my_var\" : \"Hello World!\"}"
        ), true ).ParseObject();

        // Send (Publish) Message
        JsonObject response = pubnub.publish( PubnubTest.channel, message );

        // Print Full Response
        response.Write(writer);
        Console.WriteLine("Publish() Response: " + writer.ToString());

        // Print Parts
        Console.WriteLine("Status: " + response["status"]);
        Console.WriteLine("-----------------------------------------------\n");
    }

    /// <summary>
    /// Test for Pubnub.history( string, int )
    /// </summary>
    private static void test_history() {
        Console.WriteLine("TEST HISTORY:");

        // Init Pubnub Class
        Pubnub pubnub  = new Pubnub(
            PubnubTest.PUBLISH_KEY,
            PubnubTest.SUBSCRIBE_KEY
        );

        // Get History
        JsonArray response = pubnub.history( PubnubTest.channel, 10 );
        JsonWriter writer  = new JsonWriter();

        // Print Response
        response.Write(writer);
        Console.WriteLine("History() Response: " + writer.ToString());

        // Print Each Message
        foreach (JsonObject message in response) {
            JsonWriter msg_writer = new JsonWriter();
            message.Write(msg_writer);
            Console.WriteLine(msg_writer.ToString());
        }
        Console.WriteLine("-----------------------------------------------\n");
    }

    /// <summary>
    /// Test for Pubnub.subscribe( string, delegate )
    /// </summary>
    private static void test_subscribe() {
        Console.WriteLine("TEST SUBSCRIBE:");
        Console.WriteLine("TO TEST THIS FUNCTION, PUBLISH MESSAGES:");

        // Init Pubnub Class
        Pubnub pubnub  = new Pubnub(
            PubnubTest.PUBLISH_KEY,
            PubnubTest.SUBSCRIBE_KEY
        );

        // Subscribe
        pubnub.subscribe(
            PubnubTest.channel,
            delegate (JsonObject message) {
                // Print Message
                JsonWriter writer = new JsonWriter();
                message.Write(writer);
                Console.WriteLine("Subscribe() Response: "+writer.ToString());

                // Continue Listening
                return true;
            }
        );
        Console.WriteLine("-----------------------------------------------\n");
    }
}


public class Pubnub {
    private static string ORIGIN        = "http://pubnub-prod.appspot.com";
    private static int    LIMIT         = 1700;
    private static int    UNIQUE        = 1;
    private static string PUBLISH_KEY   = "";
    private static string SUBSCRIBE_KEY = "";

    public delegate bool Procedure(JsonObject message);

    public Pubnub( string publish_key, string subscribe_key ) {
        Pubnub.PUBLISH_KEY   = publish_key;
        Pubnub.SUBSCRIBE_KEY = subscribe_key;
    }

    public JsonArray history( string channel, int limit ) {
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;
        Hashtable hist_params = new Hashtable();

        hist_params.Add( "channel", channel );
        hist_params.Add( "limit", limit.ToString() );

        // Get History
        JsonObject response = this._request(
            Pubnub.ORIGIN + "/pubnub-history",
            hist_params
        );

        // Return Array of Historical Messages
        return (JsonArray)response["messages"];
    }

    public JsonObject publish( string channel, JsonObject message ) {
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;
        Hashtable pub_params = new Hashtable();
        JsonWriter writer    = new JsonWriter();

        message.Write(writer);

        pub_params.Add( "publish_key", Pubnub.PUBLISH_KEY );
        pub_params.Add( "channel", channel );
        pub_params.Add( "message", writer.ToString() );

        // Publish Message Message
        return this._request( Pubnub.ORIGIN + "/pubnub-publish", pub_params );
    }

    private void _subscribe(
        string channel,
        Procedure callback,
        string timetoken,
        string server
    ) {
        bool keep_listening = true;

        // Find a PubNub Server
        if (server.Length == 0) {
            Hashtable sub_params = new Hashtable();

            sub_params.Add( "channel", channel );

            JsonObject resp_for_server = this._request(
                Pubnub.ORIGIN + "/pubnub-subscribe",
                sub_params
            );

            try {
                server = resp_for_server["server"].ToString();
            }
            catch {
                return;
            }
        }

        try {
            Hashtable conn_params = new Hashtable();

            conn_params.Add( "channel", channel );
            conn_params.Add( "timetoken", timetoken );

            // Listen for a Message
            JsonObject response = this._request(
                "http://" + server + "/",
                conn_params
            );

            // Test for Message
            if (((JsonArray)response["messages"]).Count == 0) {
                this._subscribe( channel, callback, timetoken, "" );
                return;
            }

            // Was it a Timeout
            JsonArray messages = (JsonArray)response["messages"];
            if (messages[0].ToString() == "xdr.timeout") {
                timetoken = response["timetoken"].ToString();
                this._subscribe( channel, callback, timetoken, server );
                return;
            }

            // Run user Callback and Reconnect if user permits.
            foreach (JsonObject message in messages) {
                keep_listening = keep_listening && callback(message);
            }

            // Keep listening if Okay.
            if (keep_listening) {
                timetoken = response["timetoken"].ToString();
                this._subscribe( channel, callback, timetoken, server );
                return;
            }
        }
        catch {
            this._subscribe( channel, callback, timetoken, "" );
            return;
        }

        // Done Listening.
        return;
    }

    public void subscribe( string channel, Procedure callback ) {
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;
        this._subscribe( channel, callback, "0", "" );
    }

    private JsonObject _request( string url, Hashtable args ) {
        StringBuilder  sb = new StringBuilder();
        byte[]        buf = new byte[8192];

        // Add Unique
        args.Add( "unique", (Pubnub.UNIQUE).ToString() );

        // Build URL
        url += "?";
        foreach (DictionaryEntry dict in args) {
            url += System.Uri.EscapeDataString((string)dict.Key) + "=" +
                   System.Uri.EscapeDataString((string)dict.Value) + "&";
        }
        url = url.Substring( 0, url.Length -1 );

        if (url.Length > Pubnub.LIMIT) {
            return new JsonParser( new StringReader(
                "{\"message\" : \"Message Too Long\"}"
            ), true ).ParseObject();
        }

        // Create Request
        HttpWebRequest  request   = (HttpWebRequest)WebRequest.Create(url);
        HttpWebResponse response  = (HttpWebResponse)request.GetResponse();
        Stream          resStream = response.GetResponseStream();

        string tempString = null;
        int    count      = 0;

        do {
            count = resStream.Read( buf, 0, buf.Length );
            if (count != 0) {
                tempString = Encoding.ASCII.GetString( buf, 0, count );
                sb.Append(tempString);
            }
        } while (count > 0);

        // Parse Response
        string message = sb.ToString();
               message = message.Substring( 10, message.Length - 11 );

        JsonParser parser = new JsonParser( new StringReader(message), true );
        JsonObject json   = parser.ParseObject();

        // Return Response
        return json;
    }
}
 
