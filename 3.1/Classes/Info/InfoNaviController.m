//
//  InfoNaviController.m
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InfoNaviController.h"
#import "InfoViewController.h"
#import "global.h"

@implementation InfoNaviController

#pragma mark Class method

+ (InfoNaviController*) defaultController {
	InfoViewController* viewcontroller = [InfoViewController defaultController];
	InfoNaviController* obj = [[InfoNaviController alloc] initWithRootViewController:viewcontroller];
	[viewcontroller release];
	return obj;
}

#pragma mark Override

- (void)dealloc {
	DNSLog( @"[InfoNaviController] dealloc" );
    [super dealloc];
}


@end
