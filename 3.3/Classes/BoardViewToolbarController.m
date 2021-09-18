//
//  BoardViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardViewToolbarController.h"

@implementation BoardViewToolbarController

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate_ action:@selector(pushBookmarkButton:)];
	[items_ addObject:bookmark];
	[bookmark release];
	
	return self;
}

@end
