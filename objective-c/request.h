#import <stdio.h>
#import <Cocoa/Cocoa.h>
#import "JSON/JSON.h"

@class Pubnub;

@interface Response: NSObject {
    id deligate;
    SBJsonParser* parser;
    Pubnub* pubnub;
    NSString* channel;
}

-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o;

-(Response*)
    finished: (id)        callback
    pubnub:   (Pubnub*)   pubnub_o
    channel:  (NSString*) channel_o;

-(Response*)
    pubnub:  (Pubnub*)   pubnub_o
    channel: (NSString*) channel_o;

-(void)      callback: (id) response;
-(void)      fail:     (id) response;
@end

@interface Request: NSObject {
    id deligate;
    NSString *response;
    NSAutoreleasePool *pool;
}
-(void)
    scheme:   (NSString*) scheme
    host:     (NSString*) host
    path:     (NSString*) path
    callback: (Response*) callback;
@end
