//
//  PNMessagePostRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/07/13.
//
//


#import "PNMessagePostRequest.h"


#pragma mark Protected interface implementation

@interface PNMessagePostRequest (Protected)


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, readonly, strong) PNMessage *message;

#pragma mark -


@end