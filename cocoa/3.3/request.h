#import <stdio.h>
#import <Cocoa/Cocoa.h>
#import "JSON/JSON.h"

@class Pubnub;

@interface Response: NSObject {
    id delegate;
    SBJsonParser* parser;
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

-(void)      callback:(NSURLConnection*) connection withResponce: (id) response;
-(void)      fail    :(NSURLConnection*) connection withResponce: (id) response;
@end

@interface Request: NSObject {
    id delegate;
    NSString *response;
    NSAutoreleasePool *pool;
    NSURLConnection *connection;
    NSString* channel;
}
@property(nonatomic, retain) NSString *channel;
@property(nonatomic, retain) NSURLConnection *connection;
-(id)
    scheme:   (NSString*) scheme
    host:     (NSString*) host
    path:     (NSString*) path
    callback: (Response*) callback
    channel : (NSString*) channel;

@end
