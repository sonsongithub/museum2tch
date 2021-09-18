//
//  InfoNaviController.m
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "InfoNaviController.h"
#import "InfoViewController.h"

@implementation InfoNaviController

#pragma mark -
#pragma mark Class method

+ (InfoNaviController*) defaultController {
	InfoViewController* viewcontroller = [[[InfoViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	InfoNaviController* obj = [[InfoNaviController alloc] initWithRootViewController:viewcontroller];
	return [obj autorelease];
}

#pragma mark -
#pragma mark Override

- (void)dealloc {
	DNSLogMethod
    [super dealloc];
}


@end
