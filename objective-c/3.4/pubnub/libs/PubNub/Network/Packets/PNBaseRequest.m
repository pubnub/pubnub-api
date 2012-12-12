//
//  PNBaseRequest.m
//  pubnub
//
//  Base request class which will allow to
//  serialize specified data into format
//  which will be sent over socket connection.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNBaseRequest.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNMacro.h"
#import "PubNub.h"


#pragma mark Public interface methods

@implementation PNBaseRequest


#pragma mark - Instance methods

- (NSString *)resourcePath {
    
    PNLog(@"{WARN} THIS METHOD SHOULD BE RELOADED IN SUBCLASS");
    
    return @"/";
}

- (id)serializedMessage {
    
    return [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\nHost: %@\r\nV: %@\r\nUser-Agent: Obj-C-iOS\r\nAccept: */*\r\n\r\n",
            [self resourcePath],
            [[PubNub sharedInstance] configuration].origin,
            kPNClientVersion];
}

#pragma mark -


@end
