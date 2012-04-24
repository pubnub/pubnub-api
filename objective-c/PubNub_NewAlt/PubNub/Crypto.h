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

#import <Foundation/Foundation.h>

#define kMD5Size 16
#define kSHA2Size 32

typedef struct {
    unsigned char bytes[kMD5Size];
} MD5;

typedef struct {
    unsigned char bytes[kSHA2Size];
} SHA2;

extern const MD5 kNullMD5;
extern const SHA2 kNullSHA2;

static inline BOOL MD5EqualToMD5(const MD5* a, const MD5* b) {
    int* ptrA = (int*)a;
    int* ptrB = (int*)b;
    return ((ptrA[0] == ptrB[0]) && (ptrA[1] == ptrB[1]) && (ptrA[2] == ptrB[2]) && (ptrA[3] == ptrB[3]));
}

static inline BOOL MD5IsNull(MD5* md5) {
    return MD5EqualToMD5(md5, &kNullMD5);
}

static inline BOOL SHA2EqualToSHA2(const SHA2* a, const SHA2* b) {
    int* ptrA = (int*)a;
    int* ptrB = (int*)b;
    return ((ptrA[0] == ptrB[0]) && (ptrA[1] == ptrB[1]) && (ptrA[2] == ptrB[2]) && (ptrA[3] == ptrB[3]) &&
            ((ptrA[4] == ptrB[4]) && (ptrA[5] == ptrB[5]) && (ptrA[6] == ptrB[6]) && (ptrA[7] == ptrB[7])));
}

static inline BOOL SHA2IsNull(SHA2* sha2) {
    return SHA2EqualToSHA2(sha2, &kNullSHA2);
}

#ifdef __cplusplus
extern "C" {
#endif
    NSString* HashToString(const unsigned char* hash, NSUInteger size);  // Converts raw bytes to a lowercase hexadecimal string
    BOOL HashFromString(NSString* string, unsigned char* hash, NSUInteger size);  // Converts a lower or uppercase hexadecimal string to raw bytes
    
    MD5 MD5WithString(NSString* string);
    MD5 MD5WithData(NSData* data);
    MD5 MD5WithBytes(const void* bytes, NSUInteger length);
    NSString* MD5ToString(MD5* md5);
    MD5 MD5FromString(NSString* string);
    NSString* MD5HashedString(NSString* string);
    NSString* MD5HashedFormat(NSString* format, ...);
    
    SHA2 SHA2WithString(NSString* string);
    SHA2 SHA2WithData(NSData* data);
    SHA2 SHA2WithBytes(const void* bytes, NSUInteger length);
    NSString* SHA2ToString(SHA2* sha2);
    SHA2 SHA2FromString(NSString* string);
    NSString* SHA2HashedString(NSString* string);
    NSString* SHA2HashedFormat(NSString* format, ...);
#ifdef __cplusplus
}
#endif
