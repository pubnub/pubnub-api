#Connecting everyone on Earth in < 0.25s !
PubNub is a cross-platform client-to-client (1:1 and 1:many) push service in the cloud, capable of broadcasting real-time messages to millions of web and mobile clients simultaneously, in less than a quarter second!

Optimized for both web and mobile, our scalable, global network of redundant data centers provides lightning-fast, reliable message delivery.  We're up to 100 messages/second faster than possible with WebSockets alone, and **cross-platform compatibility across all phones, tablets, browsers, programming languages, and APIs is always guaranteed!**

#Support and Issues
Please email us at support@pubnub.com if you have any questions or issues with the client SDKs. Alternatively, you can open an issue in the Github repo of the client you have the concern about.

#Supported Languages and Frameworks
The current list of supported languages and frameworks can be found on our [github page](http://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fpubnub%2Fpubnub-api&sa=D&sntz=1&usg=AFQjCNE-eofH-mEn6I8uFXa7P2y72ds02Q).

#Contact Us
Contact information for support, sales, and general purpose inquiries can found at http://www.pubnub.com/contact-us.

#Demo and Webcast Links

Vimeo: [https://vimeo.com/pubnub](https://vimeo.com/pubnub)<br>
YouTube: [http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF](http://www.youtube.com/playlist?p=PLF0BA2B6DAAF4FBBF)<br>
Showcase: [http://www.pubnub.com/blog](http://www.pubnub.com/blog)<br>
Interview: [http://techzinglive.com/?p=227](http://techzinglive.com/?p=227)<br>


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
Use one of the following User-Agents, based on your client platform, when making a REST-based request: *PHP, JavaScript, Node.JS, Ruby, Ruby-Rhomobile, Python, Python-Twisted, Python-Tornado, C-LibEV, C-LibEvent, C-Qt, VB, C#, Java, Java-Android, Erlang, Titanium, Corona, C-Arduino, C-Unity, C#-Mono, Lua, Obj-C-iOS, C#-WP7, Cocoa, Perl5
