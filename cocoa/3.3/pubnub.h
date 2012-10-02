#import <stdio.h>
#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>
#import "JSON/JSON.h"
#import "request.h"

@interface Pubnub: NSObject {
    NSString* publish_key;
    NSString* subscribe_key;
    NSString* secret_key;
    NSString* scheme;
    NSString* host;
    NSMutableDictionary* subscriptions;
    NSAutoreleasePool* pool;
    SBJsonParser* parser;
    SBJsonWriter* writer;
}

-(Pubnub*)
    publishKey:   (NSString*) pub_key
    subscribeKey: (NSString*) sub_key
    secretKey:    (NSString*) sec_key
    sslOn:        (BOOL)      ssl_on
    origin:       (NSString*) origin;

-(void)
    publish:  (NSString*) channel
    message:  (id)        message
    deligate: (id)        deligate;

-(void)
    subscribe: (NSString*) channel
    deligate:  (id)        deligate;

-(void) subscribe: (NSDictionary*) args;
-(BOOL) subscribed: (NSString*) channel;

-(void)
    history:  (NSString*) channel
    limit:    (int)       limit
    deligate: (id)        deligate;

-(void) unsubscribe: (NSString*) channel;
-(void) time: (id) deligate;
@end

@interface SubscribeDelegate: Response @end
@interface TimeDelegate:      Response @end

