//
//  ReplyNavigationController.m
//  composeView
//
//  Created by sonson on 08/12/04.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyNavigationController.h"
#import "ReplyViewController.h"

@implementation ReplyNavigationController

+ (ReplyNavigationController*) defaultController {
	DNSLogMethod
	ReplyViewController* viewcontroller = [[ReplyViewController alloc] initWithNibName:nil bundle:nil];
	ReplyNavigationController* obj = [[ReplyNavigationController alloc] initWithRootViewController:viewcontroller];
	[viewcontroller release];
	return obj;
}

- (void)dealloc {
	DNSLogMethod
    [super dealloc];
}

@end
