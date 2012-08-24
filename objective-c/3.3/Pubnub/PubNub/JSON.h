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

#ifdef __cplusplus
extern "C" {
#endif
    
    id JSONParseData(NSData* data);  // Objects must be NSArray or NSDictionary - Assumes UTF8 encoding
    NSData* JSONWriteData(id object);  // Objects must be NSArray or NSDictionary - Assumes UTF8 encoding
    
    id JSONParseString(NSString* string);  // Objects must be NSArray or NSDictionary
    NSString* JSONWriteString(id object);  // Objects must be NSArray or NSDictionary
    
    id JSONGetDictionaryValueForKey(NSDictionary* dictionary, NSString* key);  // Converts NSNull to nil
    id JSONGetArrayValueAtIndex(NSArray* array, NSUInteger index);  // Allows out of bounds and converts NSNull to nil
    
#ifdef __cplusplus
}
#endif