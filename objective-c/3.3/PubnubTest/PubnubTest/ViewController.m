  
    //
    //  ViewController.m
    //  
    //
    //  Created by itshastra on 20/07/12.
    //  
    //

#import "ViewController.h"

typedef enum {
    test_begin_to_end_count=0,
    test_end_to_begin_count,
    test_start_reverse_true,
    test_start_reverse_false,
    test_end_reverse_true,
    test_end_reverse_false,
    test_count,
    test_count_zero
} Unittest;
@interface ViewController ()


@end

@implementation ViewController

int total_msg = 10;
NSString* channel ;
NSString* starttime = nil;
NSMutableArray* inputs = nil;
NSString* endtime = nil;
NSString* midtime = nil;
NSString* crazy = @" ~`!@#$%^&*(顶顅Ȓ)+=[]\\{}|;\':,./<>?abcd";
Unittest currentTest;
int historyCount;
NSString* _uuid=nil;

CEPubnub *pubnub;
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _uuid=[CEPubnub getUUID];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



- (IBAction)unit_test_CL148:(id)sender {
    
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" useSSL:NO];
 	[pubnub setDelegate:self];
    
    inputs = [[NSMutableArray alloc] init];
    
    channel= [NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()] ;
    NSLog(@"Channel:%@",channel);
    
    [self publish_msgOnStart:0 AndEnd:total_msg/2 AndOffset:0];
    [self publish_msgOnStart:0 AndEnd:total_msg/2 AndOffset:total_msg/2];
}

- (IBAction)presenceLeaveClick:(id)sender {
   
  
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"   cipherKey:@"demo" uuid:_uuid useSSL:NO];
 	[pubnub setDelegate:self];
    NSString * _channel=[NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()] ;
    [pubnub presence:_channel];
    
     [pubnub performSelector:@selector(subscribe:) withObject:_channel afterDelay:3];
    
    [pubnub performSelector:@selector(unsubscribeFromChannel:) withObject:_channel afterDelay:6];
}

-(void)publish_msgOnStart:(int)start AndEnd:(int)end AndOffset:(int)offset
{
    NSLog(@"Publishing messages");
    for (int i=start+offset; i<end+offset; i++) {
        NSString *text=[NSString stringWithFormat:@"%i %@",i,crazy];
        [pubnub publish:[NSDictionary dictionaryWithObjectsAndKeys:channel,@"channel",text,@"message", nil]];
        
    }
}

-(void)LogPass:(BOOL)pass WithMessage:(id)message
{
    if (pass) {
        NSLog(@"PASS:%@",message);
    }else
    {
        NSLog(@"-FAIL:%@",message);
    }
}

-(void) detailed_history_tests
{
    NSLog(@"Context setup for Detailed History tests. Now running tests");
    NSLog(@"Setting up context for Detailed History tests. Please wait ...");
    [self test_begin_to_end_count];
}

-(void) test_begin_to_end_count
{
    NSInteger count = 5;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             starttime,@"start",
                             endtime,@"end",
                             aCountInt,@"count",
                             nil]];
    currentTest=test_begin_to_end_count; //Set Current active unit test. Use in Detailed history callback
    historyCount=[aCountInt intValue];//Hold History count pass to request
}

-(void) test_end_to_begin_count
{
    NSInteger count = 5;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             endtime,@"start",
                             starttime,@"end",
                             aCountInt,@"count",
                             nil]];
    currentTest=test_end_to_begin_count;//Set Current active unit test. Use in Detailed history callback
    historyCount=[aCountInt intValue];//Hold History count pass to request

}

-(void) test_start_reverse_true
{
    
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             midtime,@"start",
                             [NSNumber numberWithBool:YES],@"reverse",
                             nil]];
    currentTest=test_start_reverse_true; //Set Current active unit test. Use in Detailed history callback
}



-(void) test_start_reverse_false
{
    
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             midtime,@"start",
                             nil]];
    currentTest=test_start_reverse_false; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_end_reverse_true
{
    
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             midtime,@"end",
                             [NSNumber numberWithBool:YES],@"reverse",
                             nil]];
    currentTest=test_end_reverse_true; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_end_reverse_false
{
    
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             midtime,@"end",
                             nil]];
    currentTest=test_end_reverse_false; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_count
{
    NSInteger count = 5;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             aCountInt,@"count",
                             nil]];
    currentTest=test_count; //Set Current active unit test. Use in Detailed history callback
    historyCount=[aCountInt intValue];
}

-(void) test_count_zero
{
    NSInteger count = 0;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             aCountInt,@"count",
                             nil]];
    currentTest=test_count_zero; //Set Current active unit test. Use in Detailed history callback
    historyCount=[aCountInt intValue];
}


#pragma mark -
#pragma mark CEPubnubDelegate stuff

- (void) pubnub:(CEPubnub*)pubnub didSucceedPublishingMessageToChannel:(NSString*)channel withResponce:(id)responce message:(id)message{
    if ([message isKindOfClass:[NSString class]]) {
        
        int index = [[message substringWithRange:NSMakeRange(0, 1)] integerValue];
        NSString *timestamp=[responce objectAtIndex:2];
        NSLog(@"Message #  %d  published with timestamp # %@",index,timestamp);
        
        
            //Inittiolize all local variable
        [inputs addObject:[NSDictionary dictionaryWithObjectsAndKeys:timestamp,@"timestamp",message,@"message", nil]];
        NSUInteger ind= [inputs count];
        NSNumber * aCountInt = [NSNumber numberWithInteger:ind];
        
        NSDecimalNumber* decimalTime = nil;
        decimalTime = [responce objectAtIndex:2];
        
        if([aCountInt intValue]-1  == 0)
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]-10 )]];
            starttime=[decimalTime description];
        }
        if([aCountInt intValue]-1 == total_msg/2-1)
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]+10 )]];
            midtime=[decimalTime description];
        }
        if([aCountInt intValue]-1 == (total_msg-1))
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]+10 )]];
            endtime=[decimalTime description];
            
                //Call First detailed_history_tests
            [self detailed_history_tests];
        }
    }
    
}
- (void) pubnub:(CEPubnub*)pubnub didFailPublishingMessageToChannel:(NSString*)channel error:(NSString*)error message:(id)message// "error" may be nil
{
    NSLog(@"Publishing Error   %@ \nFor Sent Message   %@",error,message);
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel
{
    NSLog(@"Subscription Error:  %@",message);
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel{
}

- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel{
}
- (void) pubnub:(CEPubnub*)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
}

- (void) pubnub:(CEPubnub*)pubnub didFetchHistory:(NSArray*)messages forChannel:(NSString*)channel{
}

-(void) pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error{
}


-(void) pubnub:(CEPubnub *)pubnub didFetchDetailedHistory:(NSArray *)messages forChannel:(NSString *)channel{
    if([[messages objectAtIndex:0] isKindOfClass:[NSArray class]])
    {
        NSUInteger index;
        NSNumber * hCount;
        NSArray *history=[messages objectAtIndex:0];
        index= [history count];
        hCount = [NSNumber numberWithInteger:index];
        NSString * expected_msg;
        switch (currentTest) {
            case test_begin_to_end_count:
                if([hCount intValue] == historyCount && [[[history lastObject] description] isEqualToString:[[[inputs objectAtIndex:(historyCount-1)] objectForKey:@"message" ] description]])
                {
                    [self LogPass:YES WithMessage:@"test_begin_to_end_count"];
                }
                else
                {
                    [self LogPass:NO WithMessage:@"test_begin_to_end_count"];
                }
                [self test_end_to_begin_count];//Call next test;
                break;
            case test_end_to_begin_count:
                
                if([hCount intValue] == historyCount && [[[history lastObject] description] isEqualToString:[[[inputs objectAtIndex:(total_msg-1)] objectForKey:@"message" ] description]])
                {
                    [self LogPass:YES WithMessage:@"test_end_to_begin_count"];
                }
                else
                {
                    [self LogPass:NO WithMessage:@"test_end_to_begin_count"];
                }
                
                [self test_start_reverse_true];//Call next test;
                break;
            case test_start_reverse_true:
                expected_msg= [[[inputs objectAtIndex:(total_msg-1)] objectForKey:@"message"]description];
                if([hCount intValue]== total_msg/2 && [expected_msg isEqualToString:[history lastObject] ])
                {
                    [self LogPass:YES WithMessage:@"test_start_reverse_true"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_start_reverse_true"];
                }
                [self test_start_reverse_false];//Call next test;
                break;
            case test_start_reverse_false:
                if([[history objectAtIndex:0] isEqualToString:[[[inputs objectAtIndex:(0)] objectForKey:@"message"]description]])
                {
                    [self LogPass:YES WithMessage:@"test_start_reverse_false"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_start_reverse_false"];
                }
                [self test_end_reverse_true];//Call next test;
                break;
            case test_end_reverse_true:
                if([[history objectAtIndex:0] isEqualToString:[[[inputs objectAtIndex:(0)] objectForKey:@"message"]description]])
                {
                    [self LogPass:YES WithMessage:@"test_end_reverse_true"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_end_reverse_true"];
                }
                [self test_end_reverse_false];//Call next test;
                break;
            case test_end_reverse_false:
                if([hCount intValue]== total_msg/2 && [[[history lastObject] description] isEqualToString:[[[inputs objectAtIndex:(total_msg-1)] objectForKey:@"message" ] description]])
                {
                    [self LogPass:YES WithMessage:@"test_end_reverse_false"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_end_reverse_false"];
                }
                [self test_count];//Call next test;
                break;
            case test_count:
                if([hCount intValue]== 5)
                {
                    [self LogPass:YES WithMessage:@"test_count"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_count"];
                }
                [self test_count_zero];//Call next test;
                break;
            case test_count_zero:
                if([hCount intValue]== 0)
                {
                    [self LogPass:YES WithMessage:@"test_count_zero"];
                }else
                {
                    [self LogPass:NO WithMessage:@"test_count_zero"];
                }
                break;
                
            default:
                break;
        }
    }
}

-(void) pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error{
}

- (void) pubnub:(CEPubnub*)pubnub didReceiveTime:(NSTimeInterval)time{
    NSLog(@"Subscription Error:  %f",time);
}

- (void) pubnub:(CEPubnub*)pubnub ConnectToChannel:(NSString *)channel{
    NSLog(@"Connect to Channel:   %@",channel);
}

- (void) pubnub:(CEPubnub*)pubnub DisconnectToChannel:(NSString *)channel{
    NSLog(@"Disconnect to Channel:   %@",channel);
}
- (void) pubnub:(CEPubnub*)pubnub Re_ConnectToChannel:(NSString *)channel{
    NSLog(@"Re-Connect to Channel:   %@",channel);
}

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel{
    NSDictionary* disc=(NSDictionary*)message;
    NSString *uuid=(NSString *)[disc objectForKey:@"uuid"];
    NSString *action=(NSString *)[disc objectForKey:@"action"];
    if([action isEqualToString:@"leave"])
    {
        if([uuid isEqualToString:_uuid])
        {
            [self LogPass:YES WithMessage:[NSString stringWithFormat:@"channel %@ leave sucussfully.", channel]];
        }
    }else if([action isEqualToString:@"join"])
    {
        if([uuid isEqualToString:_uuid])
        {
            [self LogPass:YES WithMessage:[NSString stringWithFormat:@"channel %@ join sucussfully.", channel]];
        }
    }
    
}

- (void) pubnub:(CEPubnub*)pubnub here_now:(NSDictionary *)message onChannel:(NSString *)channel{
}

@end

