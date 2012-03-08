//
//  CEPubnub.h
//  PubNubLib
//
//  Created by Chad Etzel on 3/21/11.
//  MIT License
/*
Copyright (c) 2011 Chad Etzel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
//

#import <Foundation/Foundation.h>

#import "JSON.h"
#import "CEPubnubRequest.h"
#import "CEPubnubDelegate.h"

@interface CEPubnub : NSObject {
    NSString* publish_key;
    NSString* subscribe_key;
    NSString* secret_key;
    NSString* scheme;
    NSString* host;
    NSMutableDictionary* subscriptions;
    SBJsonParser* parser;
    SBJsonWriter* writer;
}

@property (nonatomic, copy) NSString *publish_key;
@property (nonatomic, copy) NSString *subscribe_key;
@property (nonatomic, copy) NSString *secret_key;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, retain) NSMutableDictionary *subscriptions;
@property (nonatomic, retain) SBJsonParser *parser;
@property (nonatomic, retain) SBJsonWriter *writer;

-(CEPubnub*)
	publishKey:   (NSString*) pub_key
	subscribeKey: (NSString*) sub_key
	secretKey:    (NSString*) sec_key
	sslOn:        (BOOL)      ssl_on
	origin:       (NSString*) origin;

-(void)
	publish:  (NSString*) channel
	message:  (id)        message
	delegate: (id)        delegate;

-(void)
	subscribe: (NSString*) channel
	delegate:  (id)        delegate;

-(void) subscribe: (NSDictionary*) args;
-(BOOL) subscribed: (NSString*) channel;

-(void)
	history:  (NSString*) channel
	limit:    (int)       limit
	delegate: (id)        delegate;

-(void) unsubscribe: (NSString*) channel;
-(void) time: (id) delegate;
-(void) shutdown;
@end

@interface CEPubnubSubscribeDelegate: CEPubnubResponse @end
@interface CEPubnubHistoryDelegate: CEPubnubResponse @end
@interface CEPubnubPublishDelegate: CEPubnubResponse @end
@interface CEPubnubTimeDelegate:      CEPubnubResponse @end

