//
//  main.m
//  GramFrame
//
//  Created by Chad Etzel on 3/15/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal;
	if ( IS_IPAD )
		retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate_iPad");
	else
		retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate_iPhone");
    [pool release];
    return retVal;
}
