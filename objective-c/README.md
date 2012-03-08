# CEPubnub
---

CEPubnub is an iOS Objective-C library wrapper for the Pubnub realtime messaging service [Pubnub.com](http://www.pubnub.com/).

## Using CEPubnub in your project

0. Add the JSON-Framework to  your project: [http://stig.github.com/json-framework](http://stig.github.com/json-framework)

1. Add CEPubnub.h/.m, CEPubnubRequest.h/.m, and CEPubnubDelegate.h to your project

2. Import CEPubnub.h to your class header

        #import "CEPubnub.h"

3. Make your class follow the CEPubnubDelegate protocol

        @interface MainViewController : UIViewController <CEPubnubDelegate>

4. Implement the CEPubnubDelegate methods (they are all optional):

        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveHistoryArray:(NSArray *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub publishDidSucceedWithResponse:(NSString *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub publishDidFailWithResponse:(NSString *)response onChannel:(NSString *)channel;
        - (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSString *)timestamp;

5. Instantiate CEPubnub in your class so you can publish and subscribe to messages:

        CEPubnub *pubnub = [[CEPubnub alloc]
                        publishKey:   @"demo" 
                        subscribeKey: @"demo" 
                        secretKey:    @"demo" 
                        sslOn:        NO
                        origin:       @"pubsub.pubnub.com"
                        ];

6. Publish NSDictionaries, NSArrays, and NSStrings:

        [pubnub publish:@"hello_world_objective_c" message: [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil] delegate: self];
        [pubnub publish:@"hello_world_objective_e" message: [NSArray arrayWithObjects:@"seven", @"eight", @"nine", nil] delegate: self];
        [pubnub publish:@"hello_world_objective_d" message: @"This is a string" delegate: self];

7. Subscribe to multiple message channels:

        [pubnub subscribe: @"hello_world_objective_c" delegate:self];
        [pubnub subscribe: @"hello_world_objective_d" delegate:self];
        [pubnub subscribe: @"hello_world_objective_e" delegate:self];

8. Get a history of messages on a channel:

        [pubnub history:@"hello_world_objective_c" limit:10 delegate:self];

9. Get the timestamp:

        [pubnub time:self];

10. That's it! An example iPad app has been included in the project.

## Author

[https://twitter.com/#!/jazzychad](@JazzyChad)

MIT License

Copyright (c) 2011 Chad Etzel
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

