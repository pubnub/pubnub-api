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
    return [(id)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":@/?&=+"),
                                                        kCFStringEncodingUTF8) autorelease];
}

- (NSString*) unescapeURLString {
    return [(id)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""),
                                                                        kCFStringEncodingUTF8) autorelease];
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
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
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
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    [uuidString autorelease];
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}



+ (NSString *)AES128Operation:(CCOperation)operation key:(NSString *)key Data:(NSString *)data iv:(NSString *)iv
{
    [Base64 initialize]; 
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [[data dataUsingEncoding:NSUTF8StringEncoding] bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* data =[NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        NSString * strData=  [Base64 encode:data];
        NSLog(@"EncodedText::%@",[NSString stringWithFormat:@"%@,%@",strData,iv]);
        return [NSString stringWithFormat:@"%@,%@",strData,iv];
    }
    free(buffer);
    return nil;
}

+ (NSString *)AES128EncryptWithKey:(NSString *)key Data:(NSString *)val 
{
    //return [self AES128Operation:kCCEncrypt key:key Data:data iv:iv];
    Cipher *ci= [[Cipher alloc]initWithKey:key];
    NSData *data=[val dataUsingEncoding:NSUTF8StringEncoding];
    NSData* enc= [ci encrypt:data];
    [Base64 initialize];
    
    return [Base64 encode:enc]; 

    
}

+ (NSString *)AES128EncryptWithKeyAndData:(NSString *)key Data:(NSData *)val 
{
    //return [self AES128Operation:kCCEncrypt key:key Data:data iv:iv];
    Cipher *ci= [[Cipher alloc]initWithKey:key];
    NSData *data=val ;
    NSData* enc= [ci encrypt:data];
    [Base64 initialize];
    
    return [Base64 encode:enc]; 
    
    
}

+ (NSString *)AES128DecryptWithKey:(NSString *)key Data:(NSString *)data 
{
 //   return [self AES128Operation:kCCDecrypt key:key Data:data iv:iv];
     Cipher *ci= [[Cipher alloc]initWithKey:key];
    [Base64 initialize];
    
    NSData * dat= [Base64 decode:data];
    
      NSString *dec=   [[NSString alloc]initWithData:[ci decrypt:dat] encoding:NSUTF8StringEncoding];
   return dec;
}



@end



