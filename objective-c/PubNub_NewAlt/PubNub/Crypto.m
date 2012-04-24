// Copyright 2011 Cooliris, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <CommonCrypto/CommonDigest.h>

#import "Crypto.h"

const MD5 kNullMD5 = {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};
const SHA2 kNullSHA2 = {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};

BOOL HashFromString(NSString* string, unsigned char* hash, NSUInteger size) {
    if (string.length != 2 * size) {
        return NO;
    }
    for (NSUInteger i = 0; i < size; ++i) {
        unichar num = [string characterAtIndex:(2 * i)];
        if((num >= 'A') && (num <= 'F')) {
            num = num - 'A' + 10;
        } else if((num >= 'a') && (num <= 'f')) {
            num = num - 'a' + 10;
        } else if((num >= '0') && (num <= '9')) {
            num = num - '0';
        } else {
            return NO;
        }
        hash[i] = num << 4;
        
        num = [string characterAtIndex:(2 * i + 1)];
        if((num >= 'A') && (num <= 'F')) {
            num = num - 'A' + 10;
        } else if((num >= 'a') && (num <= 'f')) {
            num = num - 'a' + 10;
        } else if((num >= '0') && (num <= '9')) {
            num = num - '0';
        } else {
            return NO;
        }
        hash[i] |= num;
    }
    return YES;
}

NSString* HashToString(const unsigned char* hash, NSUInteger size) {
    char buffer[2 * size + 1];
    for (NSUInteger i = 0; i < size; ++i) {
        char byte = hash[i];
        unsigned char byteHi = (byte & 0xF0) >> 4;
        buffer[2 * i + 0] = byteHi >= 10 ? 'a' + byteHi - 10 : '0' + byteHi;
        unsigned char byteLo = byte & 0x0F;
        buffer[2 * i + 1] = byteLo >= 10 ? 'a' + byteLo - 10 : '0' + byteLo;
    }
    buffer[2 * size] = 0;
    return [NSString stringWithUTF8String:buffer];
}

MD5 MD5WithString(NSString* string) {
    NSUInteger length = string.length;
    if (length) {
        const UniChar* internalBuffer = CFStringGetCharactersPtr((CFStringRef)string);
        if (internalBuffer) {
            MD5 md5 = MD5WithBytes(internalBuffer, length * sizeof(UniChar));
            return md5;
        }
        void* buffer = malloc(length * sizeof(unichar));
        [string getCharacters:buffer range:NSMakeRange(0, length)];
        MD5 md5 = MD5WithBytes(buffer, length * sizeof(unichar));
        free(buffer);
        return md5;
    }
    return kNullMD5;
}

MD5 MD5WithData(NSData* data) {
    return MD5WithBytes([data bytes], [data length]);
}

MD5 MD5WithBytes(const void* bytes, NSUInteger length) {
    if (bytes == NULL) {
        return kNullMD5;
    }
    MD5 md5;
    CC_MD5(bytes, length, md5.bytes);
    return md5;
}

NSString* MD5ToString(MD5* md5) {
    return md5 ? HashToString(md5->bytes, kMD5Size) : nil;
}

MD5 MD5FromString(NSString* string) {
    MD5 md5;
    if (!HashFromString(string, md5.bytes, kMD5Size)) {
        return kNullMD5;
    }
    return md5;
}

NSString* MD5HashedString(NSString* string) {
    MD5 md5 = MD5WithString(string);
    return MD5ToString(&md5);
}

NSString* MD5HashedFormat(NSString* format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* string = [[NSString alloc] initWithFormat:format arguments:arguments];
    MD5 md5 = MD5WithString(string);
    [string release];
    va_end(arguments);
    return MD5ToString(&md5);
}

SHA2 SHA2WithString(NSString* string) {
    NSUInteger length = string.length;
    if (length) {
        const UniChar* internalBuffer = CFStringGetCharactersPtr((CFStringRef)string);
        if (internalBuffer) {
            SHA2 sha2 = SHA2WithBytes(internalBuffer, length * sizeof(UniChar));
            return sha2;
        }
        void* buffer = malloc(length * sizeof(unichar));
        [string getCharacters:buffer range:NSMakeRange(0, length)];
        SHA2 sha2 = SHA2WithBytes(buffer, length * sizeof(unichar));
        free(buffer);
        return sha2;
    }
    return kNullSHA2;
}

SHA2 SHA2WithData(NSData* data) {
    return SHA2WithBytes([data bytes], [data length]);
}

SHA2 SHA2WithBytes(const void* bytes, NSUInteger length) {
    if (bytes == NULL) {
        return kNullSHA2;
    }
    SHA2 sha2;
    	(bytes, length, sha2.bytes);
    return sha2;
}

NSString* SHA2ToString(SHA2* sha2) {
    return sha2 ? HashToString(sha2->bytes, kSHA2Size) : nil;
}

SHA2 SHA2FromString(NSString* string) {
    SHA2 sha2;
    if (!HashFromString(string, sha2.bytes, kSHA2Size)) {
        return kNullSHA2;
    }
    return sha2;
}

NSString* SHA2HashedString(NSString* string) {
    SHA2 sha2 = SHA2WithString(string);
    return SHA2ToString(&sha2);
}

NSString* SHA2HashedFormat(NSString* format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* string = [[NSString alloc] initWithFormat:format arguments:arguments];
    SHA2 sha2 = SHA2WithString(string);
    [string release];
    va_end(arguments);
    return SHA2ToString(&sha2);
}

