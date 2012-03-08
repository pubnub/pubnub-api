//
//  CEPubnubRequest.m
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

#import "CEPubnubRequest.h"




@implementation CEPubnubRequest

@synthesize response, connection;

-(void)
scheme:   (NSString*) scheme
host:     (NSString*) host
path:     (NSString*) path
callback: (CEPubnubResponse*) callback;
{
	response = nil;
	receivedData = [[NSMutableData alloc] initWithLength:0];
	
    delegate = callback;
	[delegate retain];
	
	
    NSURL *url = [NSURL
				  URLWithString: [NSString
								  stringWithFormat: @"%@://%@%@",
								  scheme,
								  host,
								  path
								  ]
				  ];
	
		
    NSMutableURLRequest *request = [NSMutableURLRequest
									requestWithURL:  url 
									cachePolicy:     NSURLRequestReloadIgnoringCacheData 
									timeoutInterval: 200
									];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
    connection = [[NSURLConnection alloc]
				  initWithRequest:  request
				  delegate:         self
				  ];
	
    
}

-(void)
connection:     (NSURLConnection*) aConnection
didReceiveData: (NSData*) data
{
	[receivedData appendData:data];
	
}

-(void)
connectionDidFinishLoading: (NSURLConnection *) aConnection
{
	response = [[NSString alloc]
				initWithData: receivedData
				encoding: NSUTF8StringEncoding
				];
	
    [delegate callback: response];
	[delegate release];
	delegate = nil;
	
}

-(void)
connection:       (NSURLConnection*) connection
didFailWithError: (NSError *) error
{
	
    [delegate fail: response];
	[delegate release];
	delegate = nil;
	
}

- (void) dealloc 
{
	if (delegate) {
		[delegate release];
	}
	if (response) {
		[response release];
	}
	[receivedData release];
	[connection release];
	[super dealloc];
}

@end

@implementation CEPubnubResponse

@synthesize parser, pubnub, channel;

-(CEPubnubResponse *)
finished: (id)      callback
pubnub:   (CEPubnub*) pubnub_o
{
    self     = [super init];
    delegate = callback;
    parser   = [SBJsonParser new];
    [self setPubnub:pubnub_o];
    self.channel  = nil;
    return self;
}


-(CEPubnubResponse *)
finished: (id)        callback
pubnub:   (CEPubnub*)   pubnub_o
channel:  (NSString*) channel_o
{
    self     = [super init];
    delegate = callback;
    parser   = [SBJsonParser new];
    //pubnub   = pubnub_o;
    [self setPubnub:pubnub_o];
    self.channel  = channel_o;
    return self;
}


-(CEPubnubResponse *)
pubnub:   (CEPubnub*)   pubnub_o
channel:  (NSString*) channel_o
{
    self     = [super init];
    delegate = nil;
    parser   = [SBJsonParser new];
    //pubnub   = pubnub_o;
    [self setPubnub:pubnub_o];
    self.channel  = channel_o;
    return self;
}


-(void) callback: (id) response {
    
	//override in subclass
	
}


-(void) fail: (id) response {
    
	// override in subclass
	
}


-(void) dealloc
{
	
	if (parser) {
		[parser release];
	}
	if (pubnub) {
		[pubnub release];
		pubnub = nil;
	}
	self.channel = nil;
	[super dealloc];
}

@end


