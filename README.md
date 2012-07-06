#Connecting everyone on Earth in < 0.25s !
PubNub is a cross-platform client-to-client (1:1 and 1:many) push service in the cloud, capable of broadcasting real-time messages to millions of web and mobile clients simultaneously, in less than a quarter second!

Optimized for both web and mobile, our scalable, global network of redundant data centers provides lightning-fast, reliable message delivery.  We're up to 100 messages/second faster than possible with WebSockets alone, and **cross-platform compatibility across all phones, tablets, browsers, programming languages, and APIs is always guaranteed!**

#Current Version
The current version number for communication with PubNub Cloud is 3.1.

#Supported Languages and Frameworks
The current list of supported languages and frameworks can be found on our [github page](http://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fpubnub%2Fpubnub-api&sa=D&sntz=1&usg=AFQjCNE-eofH-mEn6I8uFXa7P2y72ds02Q).

#Contact Us
Contact information for support, sales, and general purpose inquiries can found at http://www.pubnub.com/contact-us.

#Demo and Webcast Links

    Vimeo: [https://vimeo.com/pubnub](https://vimeo.com/pubnub)
    YouTube: [http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF](http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF)
    Showcase: [http://www.pubnub.com/blog](http://www.pubnub.com/blog)
    Interview: [http://techzinglive.com/?p=227](http://techzinglive.com/?p=227)


#Using Encryption with PubNub
For higher security applications, PubNub provides SSL and AES-based encryption features to help safeguard your data.  Additional information and higher-level overviews of [Cross-Platform AES Symmetric Key Encryption](http://www.google.com/url?q=http%3A%2F%2Fblog.pubnub.com%2Fpubnub-adds-cross-platform-aes-symmetric-key-encryption%2F&sa=D&sntz=1&usg=AFQjCNF3tjXOJ99EIJLMM-_2Vapd2NJElQ) in general can be found in our blog post.  A lower level diagram which details the [PubNub encryption-communication flow can be found here](http://www.google.com/url?q=http%3A%2F%2Fblog.pubnub.com%2Fwp-content%2Fuploads%2F2012%2F07%2FPubNubACLForPublishAndSubscribeRealTimeSystems-6.png&sa=D&sntz=1&usg=AFQjCNGA908A_y0YNRWU1HQ6XE_K0E4Jrw).
##HTTPS (SSL) 2048-bit Encryption
HTTPS is recommended for the highest level of security for REST requests to PubNub. Using REST over HTTPS is not required – however, for secure communication, you should make sure the client or REST toolkit you're using is configured to use SSL. The PubNub Cloud service will continue to support both HTTP and HTTPS.
##AES Encryption
To enable AES encryption, instantiate a PubNub instance with the presence of the optional cipher_key attribute. The instance will use the value of the cipher_key attribute as the cipher key.
##Message Signing with HMAC/SHA256
If the client is publishing, you must also include the secret_key attribute when instantiating the PubNub instance.  If the client will only be subscribing, you do not need to include the secret_key  attribute. The instance will use the value of the secret_key as the key to sign the message.
##Secure Key Exchange
The exchange of the cipher key (and if the client is publishing, the secret key) must occur using a secure communication system, external to PubNub, in order to maintain secrecy of the keys.

For an example of using encryption with the PubNub JavaScript API, check out the [PubNub Javascript Cryptography Demo](http://www.google.com/url?q=http%3A%2F%2Fpubnub.github.com%2Fpubnub-api%2Fcrypto%2Findex.html&sa=D&sntz=1&usg=AFQjCNE9NvQJbOVu6hn4H-FNirbNxxJyjA) page.  The demo shows usage of the Cipher Key + SSL at the same time.  There is not exchange however with a central authority server, which is a recommended step for distributing security keys.  [This example diagram with illustrate the recommended Central Authority Server model for proper Security Key Exchange](http://www.google.com/url?q=http%3A%2F%2Fblog.pubnub.com%2Fwp-content%2Fuploads%2F2012%2F07%2FPubNubACLForPublishAndSubscribeRealTimeSystems-6.png&sa=D&sntz=1&usg=AFQjCNGA908A_y0YNRWU1HQ6XE_K0E4Jrw).

#REST API Considerations
In addition to platform-specific APIs, PubNub also supports a REST API.
##Mandatory Headers
When using the REST API, it is **mandatory** to pass the following HTTP headers to the PubNub server for each request:

**V**: Version-Number<br>
**User-Agent**: NAME-OF-THE-CLIENT-INTERFACE<br>
**Accept**: \*/\*<br>

###Example Headers###
V: 3.1<br>
User-Agent: PHP<br>
Accept: \*/\*<br>

##Selecting a User-agent
Use one of the following User-Agents, based on your client platform, when making a REST-based request: *PHP, JavaScript, Node.JS, Ruby, Ruby-Rhomobile, Python, Python-Twisted, Python-Tornado, C-LibEV, C-LibEvent, C-Qt, VB, C#, Java, Java-Android, Erlang, Titanium, Corona, C-Arduino, C-Unity, C#-Mono, Lua, Obj-C-iOS, C#-WP7, Cocoa, Perl5, Perl6, Go-Google, Bash, Haskell*

###HTTP Request Example###
    GET /time/0 HTTP/1.1
    Host: pubsub.pubnub.com
    V: 3.1
    User-Agent: Java-Android
    Accept: */*

> **NOTE**: Only the **V**, **User-agent**, and **Accept** headers are recognized by the REST server. It is not recommended to send any other headers -- they will be ignored, and only serve to add latency to the request.

#API Reference
The following section details usage of native client and RESTful API calls. Native client examples are demonstrated in JavaScript.

#\#init(options)
Create a new PubNub Entity for Publishing/Subscribing. This entity associates itself with account-level credentials and a selected origin. Also Security Options are Specified. **options** is a hash (or similar object, based on platform) which contains initialization parameters, such as your publisher key, encryption options, and channel information.
>available in version 1+, cipher_key option available in version 3.1+

##Usage Example: Native Client
    var pubnub = PubNub.init({
        publish_key   : "CUSTOMER_PUBLISH_KEY",
        subscribe_key : "CUSTOMER_SUBSCRIBE_KEY",
        secret_key    : "CUSTOMER_SECRET_KEY", # Required only when client publishes.
        ssl           : true,
        origin        : "pubsub.pubnub.com",
        cipher_key    : "AES-Crypto-Cipher-Key" # Optional. Use to enable encryption.
    })

##Usage Example: RESTful

> **NOTE**: This class method is only available when using the platform-specific API libraries – it is not available via the REST API.

* * *

#\#.time()
This function is a utility only and has not functional value other than a PING to the PubNub Cloud.
>available in version 1+

##Usage Example: Native Client

    PubNub.time(function(time){
        log(time)
    })

##Usage Example: RESTful
###URL Params
/time/**JSONP_CALLBACK**

**JSONP_CALLBACK** is the name of the JSONP callback function. Use the JSONP callback's function name, or **0** if you are not using JSONP.
###Request Example
    GET /time/0 HTTP/1.1
###Response
[7529152783414]
* * *

#\#.uuid()
Utility function for generating a UUID. This is a utility function that is useful for creating random, unique channel IDs on the fly.
>available in version 1+

##Usage Example: Native Client
    PubNub.uuid(function(uuid){
        log(uuid)
    })

##Usage Example: RESTful

> **NOTE**: This instance method is only available when using the platform-specific API libraries – it is not available via the REST API.
* * *

#\#.publish(options)
Broadcast a message on a specific channel. options contains channel name, message, and callback values. The message may be any valid JSON type including objects, arrays, strings, and numbers.
>available in version 1+

##Usage Example: Native Client

    PubNub.publish({
        channel  : "hello_world",
        message  : "Hi.",
        callback : function(response) { log(response) }
    })

##Usage Example: RESTful
When this request is made, the server will hold the connection until the message is successfully published.
###URL Params
/publish/**PUBLISH_KEY**/**SUBSCRIBE_KEY**/**SECRET_KEY**/**CHANNEL**/**JSONP_CALLBACK**/**JSON_MESSAGE**

**JSONP_CALLBACK** is the name of the JSONP callback function. Use the JSONP callback's function name, or **0** if you are not using JSONP.

**SECRET_KEY** is your secret key, available from your portal page. If you wish disable message signing, use **0**.

###Request Example
    GET /publish/demo/demo/e0991b12871de57b333fd0c992f7d3112577cf62/my-channel/0/{"msg":"hi"} HTTP/1.1

###Response Codes
The first element of the response array is a status code of type Boolean. **1** represents successful transmission, and **0** represents failed transmission.

In the case of a failed transmission, an explanation of the failure is provided in the second element of the response array.

In the case of a successful transmission, the second element will contain **Sent**, and the third element will contain a timetoken reference for the message.

###Successful Response
[1, "Sent", "1338832423234"]
###Failed Response
[0,"Reason for Failure Shown Here"]
###Possible Failure Reasons
* "Disconnected" - The network has gone away.
* "Message Too Big" - Max message size exceeded.
* "Invalid Publish Key" - Wrong Publish Key was Used.
* "Invalid Message Signature" - The message was SHA256 Signed incorrectly.
* * *

#\#.subscribe(options)
Listen for messages on a specified channel. options contains channel information, and callbacks for receiving messages, connecting, disconnecting, and reconnecting after an unintended disconnect.
>available in version 1+

##Native Client Usage Example

    PubNub.subscribe({
        channel    : "my-channel",
        callback   : function(message) { log(message) },
        connect    : function() { log("Connected") },
        disconnect : function() { log("Disconnected") },
        reconnect  : function() { log("Reconnected") },
        error      : function() { log("Network Error") },
        restore    : true # JavaScript only
    })

##Connect, disconnect, reconnect callback lifecycles
Each time the PubNub client subscribes to a channel, a “subscription-based connection” is established to the PubNub cloud. During the lifecycle of this “subscription-based connection”:

1. the callback event will fire each time a message is received.
1. the disconnect event will fire only once, if and when the connection is lost.
1. the reconnect event will fire only once, if and when the connection is re-established after a disconnect event.

##RESTful Usage Example
###Subscribe Process Lifecycle
In the REST paradigm, **subscribe** serves two purposes.  First, it indicates the client's intention of subscribing to a channel.  Second, it brings back all new messages since the last **subscribe** request was made.

In order for the server to know which messages should be considered new (and therefore sent to the client), a timetoken must be passed in each subsequent **subscribe** request. This timetoken acts as a “last sent” pointer in the channel's message stream.


The following is an example of the RESTful **subscribe** lifecycle:

 1\. The initial subscribe request is made.

###URL Params
/subscribe/**SUBSCRIBE_KEY**/**CHANNEL**/**JSONP_CALLBACK**/**TIMETOKEN**

**JSONP_CALLBACK** is the name of the JSONP callback function. Use the JSONP callback's function name, or **0** if you are not using JSONP.

If you do not yet have a value for **TIMETOKEN** (i.e., this is your first request), use the value **0**.

###First Request
    GET /subscribe/subscribe_key/my-channel/0/0 HTTP/1.1

###First Response
[[], "7529152783414"]

 2\. Extract the second element in the array, and store it in a variable called timetoken.
    The subsequent request is made with the newly acquired **timetoken**.

###Subsequent Request
    GET /subscribe/subscribe_key/my-channel/0/7529152783414 HTTP/1.1
The connection to the server will remain established for up to 300 seconds while it waits for new messages.  If after 300 seconds no new messages have been received, the server will return an empty message element with a new **timetoken**.
##Subsequent Response when there are no new messages since last request
[[],"75291527861853"]

If new message(s) are received within this 300 second window, the server will respond with the new message(s) and a new timetoken.

##Subsequent Response when there are new messages since last request
[[MSG,MSG,MSG],"75291527861853"]

 3\. Handle new messages (if present) from the first element of the response array.
 4\. Update the value of **timetoken** with the new value in the second element of the array.
 5\. Repeat from Step 3 to retrieve subsequent message updates.
* * *

#\#.unsubscribe(options)
Listen for messages on a specified channel. options contains the channel name.
>available in version 1+

##Native ClientUsage Example

    PubNub.unsubscribe({
        channel : "my-channel"
    })

##RESTful Usage Example
> **NOTE**: This instance method is only available when using the platform-specific API libraries – it is not available via the REST API.
* * *

#\#.history(options)
Retrieve the last *n* messages published to this channel. **options** contains channel information, history limit, and callback.  Currently you can only fetch the last 100 messages. However, upcoming features will include forever-history fetching.
>available in version 1+

##Native Client Usage Example

    PubNub.history({
        channel  : "my-channel",
        limit    : 100,
        callback : (messages) { log(messages) }
    })

##RESTful Usage Example
###URL Format
/history/**SUBSCRIBE_KEY**/**CHANNEL**/**JSONP_CALLBACK**/**LIMIT**

**JSONP_CALLBACK** is the name of the JSONP callback function. Use the JSONP callback's function name, or **0** if you are not using JSONP.

**LIMIT** is the maximum number of messages to return.

###Request Example
    GET /history/demo/my-channel/0/3 HTTP/1.1

###Response
[MSG,MSG,MSG]e JSONP callback function. Use the JSONP callback's function name, or **0** if you are not using JSONP.
* * *