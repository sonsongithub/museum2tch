//
//  BookmarkNavigationController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkNavigationController.h"
#import "BookmarkViewController.h"
#import "SNToolbarController.h"

@implementation BookmarkNavigationController

@synthesize toolbar = toolbar_;

+ (BookmarkNavigationController*) defaultController {
	DNSLogMethod
	BookmarkViewController* viewcontroller = [[BookmarkViewController alloc] initWithStyle:UITableViewStylePlain];
	BookmarkNavigationController* obj = [[BookmarkNavigationController alloc] initWithRootViewController:viewcontroller];
	[viewcontroller release];
	return obj;
}

- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated {
	controller.parentToolbar = toolbar_;
	[toolbar_ setItems:controller.items animated:animated];
}

- (id)initWithRootViewController:(UIViewController*)viewController {
	self = [super initWithRootViewController:viewController];
	self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 416, 320, 44 )];
	[self.toolbar release];
	[self.view addSubview:self.toolbar];
	
	return self;
}

- (void)dealloc {
	DNSLogMethod
	[toolbar_ release];
	[super dealloc];
}

@end