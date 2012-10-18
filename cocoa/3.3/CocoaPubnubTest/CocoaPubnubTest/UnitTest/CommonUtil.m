//
//  CommonUtil.m
//  PubnubTest
//
//  Created by itshastra on 16/10/12.
//
//

#import "CommonUtil.h"

@implementation CommonUtil

+(void)LogPass:(BOOL)pass WithMessage:(id)message
{
    if (pass) {
        NSLog(@"PASS:%@",message);
    }else
    {
        NSLog(@"-FAIL:%@",message);
    }
}

@end
