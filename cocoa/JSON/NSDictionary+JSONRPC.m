#include "JSONPort.h"
#include <Foundation/NSString.h>
#include <Foundation/NSNull.h>

@implementation NSDictionary (JSONRPC)

- (NSString *) method
{
    return (NSString *)[self objectForKey: @"method"];
}

- (NSArray *) params
{
    id par = [self objectForKey: @"params"];
    return (!par || [par isKindOfClass: [NSNull class]]) ? 0 : (NSArray *)par;
}
    
- (id) rid
{
    id rid = [self objectForKey: @"id"];
    return (!rid || [rid isKindOfClass: [NSNull class]]) ? nil : rid;
}

- (id) result
{
    id res = [self objectForKey: @"result"];
    return (!res || [res isKindOfClass: [NSNull class]]) ? nil : res;
}

- (id) error
{
    id err = [self objectForKey: @"error"];
    return (!err || [err isKindOfClass: [NSNull class]]) ? nil : err;
}

@end //  NSDictionary (JSONRPC)

