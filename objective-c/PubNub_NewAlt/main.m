//
//  main.m
//  PubNub_NewAlt
//
//  Created by itshastra on 11/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate_iPhone.h"

int main(int argc, char *argv[])
{
 //   @autoreleasepool {
 //       return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
 //   }
    
    
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal;
	
		retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate_iPhone");
    [pool release];
    return retVal;
}
