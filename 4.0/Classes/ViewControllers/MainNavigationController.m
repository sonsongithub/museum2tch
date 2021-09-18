//
//  MainNavigationController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainNavigationController.h"
#import "SNToolbarController.h"

@implementation MainNavigationController

@synthesize toolbar = toolbar_;

- (id)initWithRootViewController:(UIViewController*)viewController {
	self = [super initWithRootViewController:viewController];
	self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 416, 320, 44 )];
	[self.toolbar release];
	return self;
}

- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated {
	controller.parentToolbar = toolbar_;
	[toolbar_ setItems:controller.items animated:animated];
}

- (void)dealloc {
	[toolbar_ release];
	[super dealloc];
}

@end
