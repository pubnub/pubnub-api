//
//  Common.m
//  PubNub_NewAlt
//
//  Created by itshastra on 11/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Common.h"
#import "Base64.h"
#import "Cipher.h"



@implementation NSString (Extensions)

- (NSString*) urlEscapedString {
    return (__bridge_transfer id)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, CFSTR(":@/?&=+"),kCFStringEncodingUTF8) ;
}

- (NSString*) unescapeURLString {
    return (__bridge_transfer id)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)self, CFSTR(""),
                                                                        kCFStringEncodingUTF8) ;
}
- (BOOL) containsString:(NSString*)string {
    NSRange range = [self rangeOfString:string];
    return range.location != NSNotFound;
}

@end

@implementation CommonFunction 

+(NSString*) HMAC_SHA256withKey:(NSString*)key Input:(NSString*) input {
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [input cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [NSData dataWithBytesNoCopy: cHMAC length: sizeof(cHMAC) freeWhenDone: false];
    
    NSString *hash = [HMAC description]; //This line doesn´t make sense
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

// return a new autoreleased UUID string
+ (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
        
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSString *)AES128EncryptWithKey:(NSString *)key Data:(NSString *)val 
{
    Cipher *ci = [[Cipher alloc] initWithKey: key];
    NSData *data =[val dataUsingEncoding: NSUTF8StringEncoding];
    NSData* enc = [ci encrypt: data];
  
    
    [Base64 initialize];
    return [Base64 encode:enc];
}

+ (NSString *)AES128EncryptWithKeyAndData:(NSString *)key Data:(NSData *)val 
{
    //return [self AES128Operation:kCCEncrypt key:key Data:data iv:iv];
    Cipher *ci = [[Cipher alloc] initWithKey:key];
    NSData *data = val ;
    NSData* enc = [ci encrypt: data];
 
    
    [Base64 initialize];
    return [Base64 encode: enc];
}

+ (NSString *)AES128DecryptWithKey:(NSString *)key Data:(NSString *)data 
{
    Cipher *ci= [[Cipher alloc]initWithKey:key] ;
    [Base64 initialize];
    
    NSData * dat= [Base64 decode:data];
    NSData *decData = [ci decrypt:dat] ;
    if(decData == nil)
    {
        NSLog(@"Error: Failed to decrypt. Please validate symmetric (cipher) key.");
    }
    NSString *dec=   [[NSString alloc]initWithData:decData encoding:NSUTF8StringEncoding] ;
    return dec ;
}

@end



