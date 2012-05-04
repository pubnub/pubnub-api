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

#import "JSON.h"
#import "JSONKit.h"

#if 1
//#import "Logging.h"
#else
#define LOG_ERROR(...) NSLog(__VA_ARGS__)
#define DCHECK(...)
#endif

id JSONParseData(NSData* data) {
    NSError* error = nil;
    id object = [data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
    if (object == nil) {
      NSLog(@"JSON deserializing failed: %@", error);
    }
    return object;
}

NSData* JSONWriteData(id object) {
    NSData* data = nil;
    NSError* error = nil;
    if ([object isKindOfClass:[NSString class]]) {
        data = [(NSString*)object JSONDataWithOptions:JKSerializeOptionNone includeQuotes:YES error:&error];
    } else if ([object isKindOfClass:[NSArray class]]) {
        data = [(NSArray*)object JSONDataWithOptions:JKSerializeOptionNone error:&error];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        data = [(NSDictionary*)object JSONDataWithOptions:JKSerializeOptionNone error:&error];
    } else {
      //  NOT_REACHED();
    }
    if (data == nil) {
      NSLog(@"JSON serializing failed: %@", error);
    }
    return data;
}

id JSONParseString(NSString* string) {
    NSError* error = nil;
    id object = [string objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    if (object == nil) {
     NSLog(@"JSON deserializing failed: %@", error);
    }
    return object;
}

NSString* JSONWriteString(id object) {
    NSString* string = nil;
    NSError* error = nil;
    if ([object isKindOfClass:[NSString class]]) {
        string = [(NSString*)object JSONStringWithOptions:JKSerializeOptionNone includeQuotes:YES error:&error];
    } else if ([object isKindOfClass:[NSArray class]]) {
        string = [(NSArray*)object JSONStringWithOptions:JKSerializeOptionNone error:&error];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        string = [(NSDictionary*)object JSONStringWithOptions:JKSerializeOptionNone error:&error];
    } else {
     //   NOT_REACHED();
    }
    if (string == nil) {
      NSLog(@"JSON serializing failed: %@", error);
    }
    return string;
}

id JSONGetDictionaryValueForKey(NSDictionary* dictionary, NSString* key) {
  //  DCHECK(!dictionary || [dictionary isKindOfClass:[NSDictionary class]]);
    id value;
    if(!dictionary || [dictionary isKindOfClass:[NSDictionary class]])
    {
     value = [dictionary objectForKey:key];
  
    }
      return (value == [NSNull null] ? nil : value);
}

id JSONGetArrayValueAtIndex(NSArray* array, NSUInteger index) {
   // DCHECK(!array || [array isKindOfClass:[NSArray class]]);
    id value = index < array.count ? [array objectAtIndex:index] : nil;
    return (value == [NSNull null] ? nil : value);
}