using System;
using System.IO;
using System.Net;
using System.Text;
using System.Xml;
using System.Collections;


public class PubnubTest {
    static public void Main() {
        Pubnub pubnub   = new Pubnub( "demo", "demo" );
        string response = "";

        // Prints JSONP
        response = pubnub.publish( "my_unique_channel", "My Message HERE" );
        Console.WriteLine(response);

        // Prints JSONP
        response = pubnub.publish( "my_unique_channel", "Next Message" );
        Console.WriteLine(response);
    }
}


public class Pubnub {
    private static string ORIGIN        = "http://pubnub-prod.appspot.com";
    private static int LIMIT            = 1700;
    private static int UNIQUE           = 1;
    private static string PUBLISH_KEY   = "";
    private static string SUBSCRIBE_KEY = "";

    public Pubnub( string publish_key, string subscribe_key ) {
        Pubnub.PUBLISH_KEY   = publish_key;
        Pubnub.SUBSCRIBE_KEY = subscribe_key;
    }

    public string publish( string channel, string message ) {
        channel = Pubnub.SUBSCRIBE_KEY + "/" + channel;
        Hashtable pub_params = new Hashtable();

        pub_params.Add( "publish_key", Pubnub.PUBLISH_KEY );
        pub_params.Add( "unique", (Pubnub.UNIQUE++).ToString() );
        pub_params.Add( "channel", channel );
        pub_params.Add( "message", "\"" + message + "\"" );

        // Publish Message Message
        return this._request( Pubnub.ORIGIN + "/pubnub-publish", pub_params );
    }

    private string _request( string url, Hashtable args ) {
        StringBuilder  sb = new StringBuilder();
        byte[]        buf = new byte[8192];

        // Build URL
        url += "?";
        foreach (DictionaryEntry dict in args) {
            url += System.Uri.EscapeDataString((string)dict.Key) + "=" +
                   System.Uri.EscapeDataString((string)dict.Value) + "&";
        }
        url = url.Substring( 0, url.Length -1 );

        if (url.Length > Pubnub.LIMIT) {
            return "Message Too Long";
        }

        // Create Request
        HttpWebRequest  request   = (HttpWebRequest)WebRequest.Create(url);
        HttpWebResponse response  = (HttpWebResponse)request.GetResponse();
        Stream          resStream = response.GetResponseStream();

        string tempString = null;
        int    count      = 0;

        do {
            count = resStream.Read(buf, 0, buf.Length);
            if (count != 0) {
                tempString = Encoding.ASCII.GetString(buf, 0, count);
                sb.Append(tempString);
            }
        } while (count > 0);

        // Return Response
        return sb.ToString();
    }
}
 
