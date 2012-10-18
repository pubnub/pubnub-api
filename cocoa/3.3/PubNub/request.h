#import <stdio.h>
#import <Cocoa/Cocoa.h>

@class Pubnub;
typedef enum {
    kCommand_Undefined = 0,
    kCommand_SendMessage,
    kCommand_ReceiveMessage,
    kCommand_Presence,
    kCommand_FetchHistory,
    kCommand_FetchDetailHistory,
    kCommand_GetTime,
    kCommand_Here_Now
} Command;

@interface Response: NSObject {
    id delegate;
    Pubnub* pubnub;
    NSString* channel;
    id message;
}

-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o;

-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o;

-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o
    message:  (id)message_o;

-(Response*)
    pubnub:  (Pubnub*)   pubnub_o
    channel: (NSString*) channel_o;
-(Response*)
    pubnub:  (Pubnub*)   pubnub_o
    channel: (NSString*) channel_o
    message:  (id)message_o;

-(void)      callback:(id) request withResponce: (id) response;
-(void)      fail    :(id) request withResponce: (id) response;
@end

@interface Request: NSObject {
    id delegate;
    NSMutableData *response;
    NSURLConnection *connection;
    NSString* channel;
    Command command;
    Pubnub *pubnub;
}
@property(nonatomic, retain) NSString *channel;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, readonly) Command command;
@property(nonatomic, retain) id delegate;
-(id)
    scheme	:(NSString*) scheme
    host	:(NSString*) host
    path	:(NSString*) path
    callback:(Response*) callback
    channel :(NSString*) channel
    pubnub	:(Pubnub*)pubnub
    command :(Command)command;

@end
