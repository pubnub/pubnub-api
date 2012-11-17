# PubNub 3.3.0.1 Web Data Push Cloud-Hosted API - C# Mono 2.10.9 
##PubNub C Sharp Usage

Open 3.3.0.1/PubNub-Messaging/PubNub-Console/PubNub-Messaging.csproj, the example Pubnub_Example.cs should demonstrate all functionality, asyncronously using delegates. The main functionality lies in the pubnub.cs file.

3.3.0.1/PubNub-Messaging/PubNubTest contains the Unit test cases.

Please ensure that in order to run on Mono the key "OverrideTcpKeepAlive" in the config of both the console application and unit tests should be set to "true"
  <!-- the value of OverrideTcpKeepAlive must be true for Mono -->
    <add key="OverrideTcpKeepAlive" value="true"/>  

Dev environment setup:
- MAC OS X 10.7.4 (Lion)
- Mono Develop 3.0.3.2
- Xcode 4.3.4
- Mono 2.10.9 

Report an issue, or email us at support if there are any additional questions or comments.


