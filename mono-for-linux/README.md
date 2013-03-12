# PubNub 3.3.0.1 Web Data Push Cloud-Hosted API - C# Mono 2.10.9 
##PubNub C Sharp (Mono for Linux) Usage

For a video walkthrough, check out https://vimeo.com/54805917 !

Open 3.3.0.1/PubNub-Messaging/PubNub-Console/PubNub-Messaging.csproj, the example Pubnub_Example.cs should demonstrate all functionality, asyncronously using delegates. The main functionality lies in the pubnub.cs file.

3.3.0.1/PubNub-Messaging/PubNubTest contains the Unit test cases.

Please ensure that in order to run on Mono the constant in the pubnub.cs file should be set to "true"
OVERRIDE_TCP_KEEP_ALIVE = true;

In the app.config both the projects the value of the key "initializeData" should be full path with rw access default value="/tmp/pubnub-messaging.log".

If you encounter an issue where SSL connections throw an exception, you need to import the root certificates using the command
mozroots --import --ask-remove

For more details please see:
http://www.mono-project.com/FAQ%3a_Security#Secure_Socket_Layer_.28SSL.29_.2F_Transport_Layer_Security_.28TLS.29

Dev environment setup:
- ubuntu 12.04
- Mono Develop 2.8.6.3+dfsg-2 or higher 
- Mono 2.10.8.1 or higher 

Report an issue, or email us at support if there are any additional questions or comments.


