# PubNub 3.3.0.1 Web Data Push Cloud-Hosted API - C# Mono 2.10.9 
##PubNub C Sharp (MonoTouch Usage)

For a quick video walkthrough, checkout https://vimeo.com/55630516 !

Open 3.3.0.1/PubNub-Messaging/Pubnub-Messaging/PubNub-Messaging.csproj. Run the project in the simulator to see a working example. The main functionality lies in the pubnub.cs file.

3.3.0.1/PubNub-Messaging/Pubnub-Messaging.Tests contains the Unit test cases. Run the project to see the unit test results,

Please ensure that in order to run on Mono the constant in the pubnub.cs file should be set to "true"
OVERRIDE_TCP_KEEP_ALIVE = true;

When creating a new project or a new configuration please add a compiler flag by going into the "Options -> Compiler -> Define Symbols" and adding "MONOTOUCH;" to it.

Dev environment setup:
- MAC OS X 10.7.4 (Lion)
- MonoTouch 6.0.6 Evaluation
- Mono Develop 3.0.5
- Xcode 4.5.2
- Mono 2.10.9 

Report an issue, or email us at support if there are any additional questions or comments.


