//
//  PNConnection.h
//  pubnub
//
//  This is core class for communication over
//  the network with PubNub services.
//  It allow to establish socket connection and
//  organize write packet requests into FIFO queue.
//  
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionDelegate.h"


@interface PNConnection : NSObject


#pragma mark Properties

@property (nonatomic, weak) id<PNConnectionDelegate> delegate;


#pragma mark - Class methods

/**
 * Depending on platform will be able to 
 * return few connections when on Mac OS
 * and will reuse same connection on iOS
 */
+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier;

+ (void)closeAllConnections;

#pragma mark -


@end
