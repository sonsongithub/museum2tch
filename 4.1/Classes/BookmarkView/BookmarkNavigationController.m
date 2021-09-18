//
//  BookmarkNavigationController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BookmarkNavigationController.h"
#import "BookmarkViewController.h"
#import "SNToolbarController.h"
#import "SearchViewController.h"
#import "HistoryViewController.h"

BookmarkNavigationController* sharedBookmark = nil;

@implementation BookmarkNavigationController

@synthesize toolbar = toolbar_;

#pragma mark -
#pragma mark Class method

+ (BookmarkNavigationController*) defaultController {
	DNSLogMethod
	if( sharedBookmark == nil ) {
		BookmarkViewController* viewcontroller = [[[BookmarkViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
		sharedBookmark = [[BookmarkNavigationController alloc] initWithRootViewController:viewcontroller];
	}
	return sharedBookmark;
}

#pragma mark -
#pragma mark Class method

- (void)pushSearchViewController {
	DNSLogMethod
	if( [self.topViewController isKindOfClass:[SearchViewController class]] ) {
	}
	else {
		// if top viewcontroller is HistoryViewController, push SearchViewController after poppoing HistoryViewController.
		if( [self.topViewController isKindOfClass:[HistoryViewController class]] ) {
			[self popViewControllerAnimated:NO];
		}
		SearchViewController* con = [[SearchViewController alloc] initWithStyle:UITableViewStylePlain];
		self.topViewController.title = NSLocalizedString( @"Bookmark", nil );
		[self pushViewController:con animated:NO];
		[con release];
	}
}

#pragma mark -
#pragma mark Control ToolbarController

- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated {
	controller.parentToolbar = toolbar_;
	[toolbar_ setItems:controller.items animated:animated];
}

#pragma mark -
#pragma mark Override

- (id)initWithRootViewController:(UIViewController*)viewController {
	self = [super initWithRootViewController:viewController];
	self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 416, 320, 44 )];
	[self.toolbar release];
	[self.view addSubview:self.toolbar];
	
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	DNSLogMethod
	[toolbar_ release];
	[super dealloc];
}

@end