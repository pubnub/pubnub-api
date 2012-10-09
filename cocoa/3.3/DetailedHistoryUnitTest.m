#import "DetailedHistoryUnitTest.h"
#import "pubnub.h"

@interface      PublishMessageResponse: Response
-(PublishMessageResponse*)
    pubnub:  (Pubnub*)   pubnub_o
    channel: (NSString*) channel_o
    message:  (id)message_o;
@end
@implementation PublishMessageResponse
-(PublishMessageResponse*)
    pubnub:  (Pubnub*)   pubnub_o
    channel: (NSString*) channel_o
    message:  (id)message_o
{
    [super pubnub:pubnub_o channel:channel_o message:message_o];
    return self;
}

DetailedHistoryUnitTest *detailedHistory;
-(void)setDetailedHistory:(id)obj
{
    detailedHistory=obj;
}
-(void) callback:(id) request withResponce:(id)response {
    if ([message isKindOfClass:[NSString class]]) {
        
        long index = [[message substringWithRange:NSMakeRange(0, 1)] integerValue];
        
        NSString *timestamp=[response objectAtIndex:2];
        NSLog(@"Message #  %ld  published with timestamp # %@",index,timestamp);

            //Inittiolize all local variable
        [detailedHistory.inputs addObject:[NSDictionary dictionaryWithObjectsAndKeys:timestamp,@"timestamp",message,@"message", nil]];
        NSUInteger ind= [detailedHistory.inputs count];
        NSNumber * aCountInt = [NSNumber numberWithInteger:ind];
        
        NSDecimalNumber* decimalTime = nil;
        decimalTime = [response objectAtIndex:2];
        
        if([aCountInt intValue]-1  == 0)
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]-10 )]];
            detailedHistory.starttime=[decimalTime description];
        }
        if([aCountInt intValue]-1 == detailedHistory.total_msg/2-1)
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]+10 )]];
            detailedHistory.midtime=[decimalTime description];
        }
        if([aCountInt intValue]-1 == (detailedHistory.total_msg-1))
        {
            decimalTime =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",([decimalTime doubleValue]+10 )]];
            detailedHistory.endtime=[decimalTime description];
            
                //Call First detailed_history_tests
        [detailedHistory detailed_history_tests];
            NSLog(@"Start:%@   mid:%@   end:%@",detailedHistory.starttime,detailedHistory.midtime,detailedHistory.endtime);
        }
    }
}

-(void) fail: (id) response {
    NSLog( @"Fail Publish:%@", response );
}
@end

@interface      DetailedHistoryUnitTestResponse: Response
-(DetailedHistoryUnitTestResponse*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o;
@end
@implementation DetailedHistoryUnitTestResponse

-(DetailedHistoryUnitTestResponse*)
pubnub:  (Pubnub*)   pubnub_o
channel: (NSString*) channel_o
{
    [super pubnub:pubnub_o channel:channel_o message:nil];
    return self;
}

DetailedHistoryUnitTest *detailedHistoryobj;
-(void)setDetailedHistoryObject:(id)obj
{
    detailedHistoryobj=obj;
}

-(void) callback:(id) request withResponce:(id)messages {
    if([[messages objectAtIndex:0] isKindOfClass:[NSArray class]])
    {
        NSUInteger index;
        NSNumber * hCount;
        NSArray *history=[messages objectAtIndex:0];
        index= [history count];
        hCount = [NSNumber numberWithInteger:index];
        NSString * expected_msg;
        switch (detailedHistoryobj.currentTest) {
            case test_begin_to_end_count:
                if([hCount intValue] == detailedHistoryobj.historyCount && [[[history lastObject] description] isEqualToString:[[[detailedHistoryobj.inputs objectAtIndex:(detailedHistoryobj.historyCount-1)] objectForKey:@"message" ] description]])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_begin_to_end_count"];
                }
                else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_begin_to_end_count"];
                }
                      [detailedHistoryobj test_end_to_begin_count];//Call next test;
                break;
            case test_end_to_begin_count:
                if([hCount intValue] == detailedHistoryobj.historyCount && [[[history lastObject] description] isEqualToString:[[[detailedHistoryobj.inputs objectAtIndex:(detailedHistoryobj.total_msg-1)] objectForKey:@"message" ] description]])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_end_to_begin_count"];
                }
                else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_end_to_begin_count"];
                }
                
                [detailedHistoryobj test_start_reverse_true];//Call next test;
                break;
            case test_start_reverse_true:
                expected_msg= [[[detailedHistoryobj.inputs objectAtIndex:(detailedHistoryobj.total_msg-1)] objectForKey:@"message"]description];
                if([hCount intValue]== detailedHistoryobj.total_msg/2 && [expected_msg isEqualToString:(NSString *)[history lastObject] ])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_start_reverse_true"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_start_reverse_true"];
                }
                [detailedHistoryobj test_start_reverse_false];//Call next test;
                break;
            case test_start_reverse_false:
                if([[history objectAtIndex:0] isEqualToString:[[[detailedHistoryobj.inputs objectAtIndex:(0)] objectForKey:@"message"]description]])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_start_reverse_false"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_start_reverse_false"];
                }
                [detailedHistoryobj test_end_reverse_true];//Call next test;
                break;
            case test_end_reverse_true:
                if([[history objectAtIndex:0] isEqualToString:[[[detailedHistoryobj.inputs objectAtIndex:(0)] objectForKey:@"message"]description]])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_end_reverse_true"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_end_reverse_true"];
                }
                [detailedHistoryobj test_end_reverse_false];//Call next test;
                break;
            case test_end_reverse_false:
                if([hCount intValue]== detailedHistoryobj.total_msg/2 && [[[history lastObject] description] isEqualToString:[[[detailedHistoryobj.inputs objectAtIndex:(detailedHistoryobj.total_msg-1)] objectForKey:@"message" ] description]])
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_end_reverse_false"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_end_reverse_false"];
                }
                [detailedHistoryobj test_count];//Call next test;
                break;
            case test_count:
                if([hCount intValue]== 5)
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_count"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_count"];
                }
                [detailedHistoryobj test_count_zero];//Call next test;
                break;
            case test_count_zero:
                if([hCount intValue]== 0)
                {
                    [DetailedHistoryUnitTest LogPass:YES WithMessage:@"test_count_zero"];
                }else
                {
                    [DetailedHistoryUnitTest LogPass:NO WithMessage:@"test_count_zero"];
                }
                break;
            default:
                break;
        }
    }
}

-(void) fail: (id) response {
    NSLog( @"Fail Publish:%@", response );
}
@end

@implementation DetailedHistoryUnitTest
@synthesize starttime,midtime,endtime,inputs,total_msg,currentTest,historyCount;

NSString* channel ;
NSString* crazy = @" text sample message";
Pubnub *pubnub;
DetailedHistoryUnitTestResponse *detailHisReponceCallback;
-(void)runUnitTest
{
    pubnub = [[Pubnub alloc]
              publishKey:   @"demo"
              subscribeKey: @"demo"
              secretKey:    @"demo"
              sslOn:        NO
              origin:       @"pubsub.pubnub.com"
              ];
 	
    total_msg = 10;
    inputs = [[NSMutableArray alloc] init];
    
    channel= [NSString stringWithFormat:@"%d", (int)CFAbsoluteTimeGetCurrent()] ;
    NSLog(@"Channel:%@",channel);
    
    [self publish_msgOnStart:0 AndEnd:total_msg/2 AndOffset:0];
    [self publish_msgOnStart:0 AndEnd:total_msg/2 AndOffset:total_msg/2];
    
    detailHisReponceCallback= [[DetailedHistoryUnitTestResponse alloc]
                                              pubnub:pubnub
                                              channel:  channel
                                              ];
    [detailHisReponceCallback setDetailedHistoryObject:self];
}

-(void) detailed_history_tests
{
    NSLog(@"Context setup for Detailed History tests. Now running tests");
    NSLog(@"Setting up context for Detailed History tests. Please wait ...");
    [self test_begin_to_end_count];
}

-(void)publish_msgOnStart:(int)start AndEnd:(int)end AndOffset:(int)offset
{
    NSLog(@"Publishing messages");
    for (int i=start+offset; i<end+offset; i++) {
        NSString *text=[NSString stringWithFormat:@"%i %@",i,crazy];
        
        PublishMessageResponse *reponceCallback= [[PublishMessageResponse alloc]
                                                pubnub:pubnub
                                                channel:  channel
                                                message:text];
        [reponceCallback setDetailedHistory:self];
        [pubnub
              publish: channel
              message: text
              delegate: reponceCallback
              ];
    }
}

+(void)LogPass:(BOOL)pass WithMessage:(id)message
{
    if (pass) {
        NSLog(@"PASS:%@",message);
    }else
    {
        NSLog(@"-FAIL:%@",message);
    }
}

-(void) test_begin_to_end_count
{
    NSInteger count = 5;
    NSNumber * aCountInt = [NSNumber numberWithInteger:count];
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             detailHisReponceCallback ,@"delegate",
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
                             detailHisReponceCallback ,@"delegate",
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
                             detailHisReponceCallback ,@"delegate",
                             midtime,@"start",
                             [NSNumber numberWithBool:YES],@"reverse",
                             nil]];
    currentTest=test_start_reverse_true; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_start_reverse_false
{
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             detailHisReponceCallback ,@"delegate",
                             midtime,@"start",
                             nil]];
    currentTest=test_start_reverse_false; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_end_reverse_true
{
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             detailHisReponceCallback ,@"delegate",
                             midtime,@"end",
                             [NSNumber numberWithBool:YES],@"reverse",
                             nil]];
    currentTest=test_end_reverse_true; //Set Current active unit test. Use in Detailed history callback
}

-(void) test_end_reverse_false
{
    [pubnub detailedHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                             channel,@"channel",
                             detailHisReponceCallback ,@"delegate",
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
                             detailHisReponceCallback ,@"delegate",
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
                             detailHisReponceCallback ,@"delegate",
                             aCountInt,@"count",
                             nil]];
    currentTest=test_count_zero; //Set Current active unit test. Use in Detailed history callback
    historyCount=[aCountInt intValue];
}

@end
