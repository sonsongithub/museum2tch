//
//  BoardViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BoardViewToolbarController.h"

@implementation BoardViewToolbarController

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate_ action:@selector(pushBookmarkButton:)];
	[items_ addObject:bookmark];
	[bookmark release];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"find.2ch", nil ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushSearchButton:)];
	[items_ addObject:search];
	[search release];
	
	return self;
}

@end
