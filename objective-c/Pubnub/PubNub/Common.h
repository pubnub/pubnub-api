//
//  Common.h
//  PubNub_NewAlt
//
//  Created by itshastra on 11/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
@interface NSString (Extensions)

- (NSString*) urlEscapedString;  // Uses UTF-8 encoding and also escapes characters that can confuse the parameter string part of the URL
- (NSString*) unescapeURLString;  // Uses UTF-8 encoding
- (BOOL) containsString:(NSString*)string;
@end



@interface CommonFunction :NSObject
+(NSString*) HMAC_SHA256withKey:(NSString*)key Input:(NSString*) input;
+ (NSString *)generateUuidString;

+ (NSString *)AES128Operation:(CCOperation)operation key:(NSString *)key Data:(NSString *)data ;
+ (NSString *)AES128EncryptWithKey:(NSString *)key Data:(NSString *)data ;
+ (NSString *)AES128DecryptWithKey:(NSString *)key Data:(NSString *)data ;
+ (NSString *)AES128EncryptWithKeyAndData:(NSString *)key Data:(NSData *)val;
@end