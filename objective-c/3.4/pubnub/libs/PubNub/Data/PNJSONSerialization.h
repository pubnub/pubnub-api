//
//  PNJSONSerialization.h
//  pubnub
//
//  This class encapsulate logic with JSON
//  serialization fallback (pre-iOS 5) and
//  handles JSONP by returning prefix falue.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>


@interface PNJSONSerialization : NSObject


#pragma mark Class methods

/**
 * Parse provided binary data object.
 * Method will automatically detect JSON and JSONP
 * format and provide callback method name in addition
 * to parsed data.
 */
+ (void)JSONObjectWithData:(NSData *)jsonData
           completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                errorBlock:(void(^)(NSError *error))errorBlock;

/**
 * Parse provided JSON(P) string
 * Method will automatically detect JSON and JSONP
 * format and provide callback method name in addition
 * to parsed data.
 */
+ (void)JSONObjectWithString:(NSString *)jsonString
             completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                  errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark -


@end
