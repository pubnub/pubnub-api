
#import <Cocoa/Cocoa.h>
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

@interface DetailedHistoryUnitTest : NSObject
{
    NSString* starttime;
    NSMutableArray* inputs;
    NSString* endtime ;
    NSString* midtime ;
    int total_msg;
    int historyCount;
    Unittest currentTest;
}
@property(nonatomic, retain) NSString *starttime;
@property(nonatomic, retain) NSString *midtime;
@property(nonatomic, retain) NSString *endtime;
@property(nonatomic, retain) NSMutableArray *inputs;
@property(nonatomic) int total_msg;
@property(nonatomic) int historyCount;
@property(nonatomic) Unittest currentTest;

-(void)runUnitTest;
-(void) test_count_zero;
-(void) test_count;
-(void) test_end_reverse_false;
-(void) test_end_reverse_true;
-(void) test_start_reverse_false;
-(void) test_start_reverse_true;
-(void) test_end_to_begin_count;
-(void) test_begin_to_end_count;
-(void) detailed_history_tests;

+(void)LogPass:(BOOL)pass WithMessage:(id)message;

@end
