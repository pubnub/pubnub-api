#import <stdio.h>
#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>
#import "request.h"

@interface Pubnub: NSObject {
    NSString* publish_key;
    NSString* subscribe_key;
    NSString* secret_key;
    NSString* scheme;
    NSString* host;
    NSString* current_uuid;
    NSMutableDictionary* subscriptions;
    NSMutableDictionary*  _connections;
    NSMutableSet * _subscriptionset;
    
}
-(Pubnub*)
    publishKey:   (NSString*) pub_key
    subscribeKey: (NSString*) sub_key
    secretKey:    (NSString*) sec_key
    sslOn:        (BOOL)      ssl_on
    origin:       (NSString*) origin;

-(Pubnub*)
    publishKey:   (NSString*) pub_key
    subscribeKey: (NSString*) sub_key
    secretKey:    (NSString*) sec_key
    sslOn:        (BOOL)      ssl_on
    uuid:         (NSString*) uuid
    origin:       (NSString*) origin;

-(void)
    publish:  (NSString*) channel
    message:  (id)        message
    delegate: (id)        delegate;

-(void)
    subscribe: (NSString*) channel
    delegate:  (id)        delegate;


-(BOOL) subscribed: (NSString*) channel;

- (void)
    hereNow:(NSString *)channel
    delegate: (id)delegate;

- (void)detailedHistory:(NSDictionary * )arg1;

-(void)
    history:  (NSString*) channel
    limit:    (int)       limit
    delegate: (id)        delegate;

-(void) unsubscribe: (NSString*) channel;
-(void) removeConnection: (NSString*) channel;

-(void) time: (id) delegate;
+ (NSString*) uuid;

-(void)
presence: (NSString*) channel
delegate:  (id)        delegate;


+ (BOOL)isApplicationActive;
+ (void)setApplicationActive:(BOOL) state;
- (void)didCompleteWithRequest:(Request*)request WithResponse:(id)response isfail:(BOOL) isFail;

@end



