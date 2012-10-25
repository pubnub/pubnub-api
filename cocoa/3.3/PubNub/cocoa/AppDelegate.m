//
//  AppDelegate.m
//  cocoa
//
//  Created by itshastra on 23/10/12.
//  Copyright (c) 2012 itshastra. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub/pubnub.h"

    // ----------------------
    // Time Response Callback
    // ----------------------
@interface      TimeResponse: Response
@property (weak) AppDelegate *parent;//only foe print log
@end
@implementation TimeResponse
@synthesize parent;
-(void) callback:(id) request withResponce:(id)response{
    NSLog( @"Time:%@", response );
    [parent printLog:[NSString stringWithFormat:@"Time : %@ ", response]];
}
@end

    // -------------------------
    // Publish Response Callback
    // -------------------------
@interface      PublishResponse: Response
@property (weak) AppDelegate *parent;//only foe print log
@end
@implementation PublishResponse
@synthesize parent;
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"PublishResponse %@", response );
    [parent printLog:[NSString stringWithFormat:@"Publish Response : %@ ", response]];
    
}
-(void) fail: (id) response {
    NSLog( @"PublishResponse Fail :%@", response );
    [parent printLog:[NSString stringWithFormat:@"Publish Fail : %@ ", response]];
}
@end

    // -------------------------
    // History Response Callback
    // -------------------------
@interface      HistoryResponse: Response
@property (weak) AppDelegate *parent;//only foe print log
@end
@implementation HistoryResponse
@synthesize parent;
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"HistoryResponse :%@", response );
    [parent printLog:[NSString stringWithFormat:@"History Response : %@ ", response]];
}
@end

    // -------------------------
    // Here Now Response Callback
    // -------------------------
@interface      HereNowResponse: Response
@property (weak) AppDelegate *parent;//only for print log
@end
@implementation HereNowResponse
@synthesize parent;
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"Here Now:  %@", response );
    [parent printLog:[NSString stringWithFormat:@"Here Now : %@ ", response]];
}
@end

    // -------------------------
    // Detailed History Response Callback
    // -------------------------
@interface      DetailedHistoryResponse: Response
@property (weak) AppDelegate *parent;//only for print log
@end
@implementation DetailedHistoryResponse
@synthesize parent;
-(void) callback:(id) request withResponce:(id)response {
    NSLog( @"DetailedHistory :: %@", response );
    [parent printLog:[NSString stringWithFormat:@"Detailed History : %@ ", response]];
}
@end

    // ---------------------------
    // Subscribe Response Callback
    // ---------------------------
@interface      SubscribeResponse: Response
@property  (weak) AppDelegate *parent;//only for print log
@end
@implementation SubscribeResponse
@synthesize parent;
-(void) callback:(id) request withResponce: (id) response {
    NSLog( @"Received Message (channel: '%@') -> %@", channel, response );
     [parent printLog:[NSString stringWithFormat:@"Received Message : %@ ", response]];
}

-(void) connectToChannel:(NSString *)_channel
{
     [parent printLog:[NSString stringWithFormat:@"Connect To Channel : %@ ", _channel]];
}

-(void) disconnectFromChannel:(NSString *)_channel
{
     [parent printLog:[NSString stringWithFormat:@"Disconnect From Channel : %@ ", _channel]];
}

-(void) reconnectToChannel:(NSString *)_channel
{
     [parent printLog:[NSString stringWithFormat:@"Reconnect To Channel : %@ ", _channel]];
}
@end

    // ---------------------------
    // Presence Response Callback
    // ---------------------------
@interface      PresenceResponse: Response
@property (weak) AppDelegate *parent;//only foe print log
@end
@implementation PresenceResponse
@synthesize parent;

-(void) callback:(id) request withResponce: (id) response {
    NSLog( @"Received Presence Message (channel: '%@') -> %@", channel, response );
    [parent printLog:[NSString stringWithFormat:@"Presence Message : %@ ", response]];
}
@end




@implementation AppDelegate
@synthesize txt;


Pubnub *pubnub;
NSString* channelName = @"hello_world";



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        // ------------------
        // Init Pubnub Object
        // ------------------
    pubnub = [[Pubnub alloc]
              publishKey:   @"demo"
              subscribeKey: @"demo"
              secretKey:    @"demo"
              sslOn:        NO
              origin:       @"pubsub.pubnub.com"
              ];
    
    
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [Pubnub setApplicationActive:NO];
}

-(void) printLog:(NSString*) log
{
    [txt setTitle:log];
}

/*Listen for a message on a channel */
- (IBAction)subscribeClick:(id)sender {
    
  SubscribeResponse*sCallback= (SubscribeResponse*) [[SubscribeResponse alloc]
     pubnub:  pubnub
     channel: channelName
     ];
    sCallback.parent=self;
    NSLog( @"Listening to: %@", channelName );
    [pubnub
     subscribe: channelName
     delegate:sCallback
     ];
}

/*Stop listen for a message on a channel.*/
- (IBAction)unsubscribeClick:(id)sender {
    [pubnub unsubscribe:channelName];
}

/*Listen for a presence message on a channel */
- (IBAction)presenceClick:(id)sender {
  
    PresenceResponse *pCallback=(PresenceResponse*)[[PresenceResponse alloc]
     pubnub:  pubnub
     channel: channelName
     ];
    pCallback.parent=self;
    
    NSLog( @"Presence to: %@", channelName );
    [pubnub
     presence: channelName
     delegate: pCallback
     ];
}
/*Load current occupancy from a channel.*/
- (IBAction)hereNowClick:(id)sender {
    HereNowResponse * hereCallback=(HereNowResponse*)[[HereNowResponse alloc]pubnub:pubnub channel:channelName];
    hereCallback.parent=self;
    [pubnub hereNow:channelName delegate:hereCallback];
}

/*PubNub Publish Message (Send Message)*/
- (IBAction)publishClick:(id)sender {
    PublishResponse *pCallbck=   [PublishResponse alloc];
    pCallbck.parent=self;
    [pubnub
     publish: channelName
     message: [NSArray arrayWithObjects:
               @"one",
               @"~`!@#$%^&*( )+=[]\\\\{}|;\':,./<>?.",
               @"three",
               nil
               ]
     delegate: pCallbck
     ];
}

/*PubNub History (Recent Message History)*/
- (IBAction)historyClick:(id)sender {
    HistoryResponse *pCallbck=   [HistoryResponse alloc];
    pCallbck.parent=self;
    [pubnub
     history:  channelName
     limit:    1
     delegate: pCallbck
     ];
}

/*Detaield PubNub History (Recent Message History)*/
- (IBAction)detailedHistoryClick:(id)sender {
    DetailedHistoryResponse *pCallbck=   [DetailedHistoryResponse alloc];
    pCallbck.parent=self;
    
    NSInteger count = 3;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             aCountInt,@"count",
                             channelName,@"channel",
                             pCallbck,@"delegate",
                             nil]];
}

/*PubNub Server Time (Get TimeToken)*/
- (IBAction)timeClick:(id)sender {
  TimeResponse *tCallback=  [TimeResponse alloc];
    tCallback.parent=self;
     [pubnub time: tCallback];
}

- (IBAction)uuidClick:(id)sender {
    [self printLog:[Pubnub uuid]];
} 
@end


