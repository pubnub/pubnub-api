//
//  CEPubnubRequest.h
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

#import "CEPubnubDelegate.h"

@class CEPubnub;

@interface CEPubnubResponse: NSObject {
    id <CEPubnubDelegate> delegate;
    SBJsonParser* parser;
    CEPubnub* pubnub;
    NSString* channel;
	
}

@property (nonatomic, retain) SBJsonParser *parser;
@property (nonatomic, retain) CEPubnub *pubnub;
@property (nonatomic, copy) NSString *channel;


-(CEPubnubResponse *)
finished: (id)        callback
pubnub:   (CEPubnub*)   pubnub_o;

-(CEPubnubResponse *)
finished: (id)        callback
pubnub:   (CEPubnub*)   pubnub_o
channel:  (NSString*) channel_o;

-(CEPubnubResponse *)
pubnub:  (CEPubnub*)   pubnub_o
channel: (NSString*) channel_o;

-(void)      callback: (id) response;
-(void)      fail:     (id) response;
@end





//CEPubnubRequest

@interface CEPubnubRequest: NSObject {
    id delegate;
	
    NSString *response;
	NSURLConnection *connection;
	
@private
	NSMutableData *receivedData;
}

@property (nonatomic, copy) NSString *response;
@property (nonatomic, retain) NSURLConnection *connection;

-(void)
scheme:   (NSString*) scheme
host:     (NSString*) host
path:     (NSString*) path
callback: (CEPubnubResponse *) callback;
@end

