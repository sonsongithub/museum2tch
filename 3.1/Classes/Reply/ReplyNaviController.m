//
//  ReplyNaviController.m
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyNaviController.h"
#import "ReplyViewController.h"
#import "InfoViewController.h"
#import "global.h"

@implementation ReplyNaviController

#pragma mark Class method

+ (ReplyNaviController*) defaultController {
	ReplyViewController* viewcontroller = [ReplyViewController defaultController];
	ReplyNaviController* obj = [[ReplyNaviController alloc] initWithRootViewController:viewcontroller];
	[viewcontroller release];
	return obj;
}

- (void) dealloc {
	DNSLog( @"[ReplyNaviController] dealloc" );
	[super dealloc];
}

@end
