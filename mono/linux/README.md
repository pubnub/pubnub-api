# PubNub 3.3.0.1 Web Data Push Cloud-Hosted API - C# Mono 2.10.9 
##PubNub C Sharp Usage

Open 3.3.0.1/PubNub-Messaging/PubNub-Console/PubNub-Messaging.csproj, the example Pubnub_Example.cs should demonstrate all functionality, asyncronously using delegates. The main functionality lies in the pubnub.cs file.

3.3.0.1/PubNub-Messaging/PubNubTest contains the Unit test cases.

Please ensure that in order to run on Mono the constant in the pubnub.cs file should be set to "true"
OVERRIDE_TCP_KEEP_ALIVE = true;

In the app.config both the projects the value of the key "initializeData" should be full path with rw access default value="/tmp/pubnub-messaging.log".

Dev environment setup:
- ubuntu 12.04
- Mono Develop 2.8.6.3+dfsg-2 or higher 
- Mono 2.10.8.1 or higher 

Report an issue, or email us at support if there are any additional questions or comments.


