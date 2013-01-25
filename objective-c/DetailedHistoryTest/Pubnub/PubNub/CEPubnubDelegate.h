#import <Foundation/Foundation.h>

@class CEPubnub;

@protocol CEPubnubDelegate <NSObject>

@optional
- (void)pubnub:(CEPubnub *)pubnub
    didSucceedPublishingMessageToChannel:(NSString *)channel
    withResponse:(id)response
    message:(id)message;

- (void)pubnub:(CEPubnub *)pubnub
    didFailPublishingMessageToChannel:(NSString *)channel
    error:(NSString *)error
    message:(id)message;  // "error" may be nil

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)message onChannel:(NSString *)channel;

- (void)pubnub:(CEPubnub *)pubnub didFetchHistory:(NSArray *)messages forChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub didFailFetchHistoryOnChannel:(NSString *)channel withError:(id)error;

- (void)pubnub:(CEPubnub *)pubnub didFetchDetailedHistory:(NSArray *)messages forChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub didFailFetchDetailedHistoryOnChannel:(NSString *)channel withError:(id)error;

- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSTimeInterval)time;  // "time" will be NAN on failure

- (void)pubnub:(CEPubnub *)pubnub connectToChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub disconnectFromChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub reconnectToChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub maxRetryAttemptCompleted:(NSString *)channel;

- (void)pubnub:(CEPubnub *)pubnub presence:(NSDictionary *)message onChannel:(NSString *)channel;
- (void)pubnub:(CEPubnub *)pubnub hereNow:(NSDictionary *)message onChannel:(NSString *)channel;

// **** deprecated methods ****

- (void)pubnub:(CEPubnub *)pubnub didSucceedPublishingMessageToChannel:(NSString *)channel withResponce: (id)responce message:(id)message __deprecated;
- (void)pubnub:(CEPubnub *)pubnub ConnectToChannel:(NSString *)channel __deprecated;
- (void)pubnub:(CEPubnub *)pubnub DisconnectToChannel:(NSString *)channel __deprecated;
- (void)pubnub:(CEPubnub *)pubnub Re_ConnectToChannel:(NSString *)channel __deprecated;
- (void)pubnub:(CEPubnub *)pubnub here_now:(NSDictionary *)message onChannel:(NSString *)channel __deprecated;

@end
