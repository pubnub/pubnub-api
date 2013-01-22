//
//  PNJSONSerialization.m
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

#import "JSONKit.h"


#pragma mark Private interface methods

@interface PNJSONSerialization ()


#pragma mark - Class methods

/**
 * Try to retrieve callback method name from provided
 * JSON string. If method will be fetched, than this is 
 * JSONP string.
 */
+ (void)getCallbackMethodName:(NSString **)callbackMethodName fromJSONString:(NSString *)jsonString;

+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString callbackMethodName:(NSString *)callbackMethodName;

@end


#pragma mark - Public interface methods

@implementation PNJSONSerialization


#pragma mark - Class methods

+ (void)JSONObjectWithData:(NSData *)jsonData
           completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self JSONObjectWithString:jsonString completionBlock:completionBlock errorBlock:errorBlock];
}

+ (void)JSONObjectWithString:(NSString *)jsonString
             completionBlock:(void(^)(id result, BOOL isJSONPStyle, NSString *callbackMethodName))completionBlock
                  errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *jsonCallbackMethodName = nil;
    [self getCallbackMethodName:&jsonCallbackMethodName fromJSONString:jsonString];
    
    // Check whether callback name was found in JSON string or not
    if(jsonCallbackMethodName != nil) {
        
        jsonString = [self JSONStringFromJSONPString:jsonString callbackMethodName:jsonCallbackMethodName];
    }
    
    // Checking whether native JSONSerializer is available or not
    NSError *parsingError = nil;
    id result = nil;
    if (NSClassFromString(@"NSJSONSerialization")) {
        
        result = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:(NSJSONReadingOptions)kNilOptions
                                                   error:&parsingError];
    }
    // Fallback to JSONKit usage
    else {
        
        result = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONDataWithParseOptions:JKParseOptionNone
                                                                                                   error:&parsingError];
    }
    
    
    // Checking whether parsing was successful or not
    if (result && parsingError == nil) {
        
        if(completionBlock) {
            
            completionBlock(result, jsonCallbackMethodName!=nil, jsonCallbackMethodName);
        }
    }
    else if(parsingError != nil){
        
        if (errorBlock) {
            
            errorBlock(parsingError);
        }
    }
}

+ (void)getCallbackMethodName:(NSString **)callbackMethodName fromJSONString:(NSString *)jsonString {
    
    // Checking whether there are parenthesis in JSON 
    NSRange parenthesisRange = [jsonString rangeOfString:@"("];
    if (parenthesisRange.location != NSNotFound &&
          ([jsonString characterAtIndex:(parenthesisRange.location+parenthesisRange.length)] == '[' ||
           [jsonString characterAtIndex:(parenthesisRange.location+parenthesisRange.length)] == '{')) {
        
        NSScanner *scanner = [NSScanner scannerWithString:jsonString];
        [scanner scanUpToString:@"(" intoString:callbackMethodName];
    }
}

+ (NSString *)JSONStringFromJSONPString:(NSString *)jsonpString callbackMethodName:(NSString *)callbackMethodName {
    
    NSScanner *scanner = [NSScanner scannerWithString:jsonpString];
    [scanner scanUpToString:@"(" intoString:NULL];
    
    NSString *JSONWrappedInParens = [[scanner string] substringFromIndex:[scanner scanLocation]];
    NSCharacterSet *parens = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%@();",
                                                                                 callbackMethodName?callbackMethodName:@""]];
    
    
    return [JSONWrappedInParens stringByTrimmingCharactersInSet:parens];
}

#pragma mark -


@end
