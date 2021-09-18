//
//  TitleViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleViewToolbarController.h"

@implementation TitleViewToolbarController

@synthesize segmentControll = segmentControll_;

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	UIBarButtonItem *flexibleSpace = nil;
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items_ addObject:bookmark];
	[bookmark release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(pushAddButton:)];
	[items_ addObject:add];
	[add release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	NSArray* array = [[NSArray alloc] initWithObjects:NSLocalizedString( @"all", nil ), NSLocalizedString( @"new", nil ), NSLocalizedString( @"cache", nil ), nil ];
	segmentControll_ = [[UISegmentedControl alloc] initWithItems:array];
	segmentControll_.segmentedControlStyle = UISegmentedControlStyleBar;
	UIBarButtonItem* segment = [[UIBarButtonItem alloc] initWithCustomView:segmentControll_];
	[items_ addObject:segment];
	[array release];
	[segment release];
	[segmentControll_ release];
	segmentControll_.selectedSegmentIndex = 0;
	[segmentControll_ addTarget:delegate action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate action:@selector(pushSearchButton:)];
	[items_ addObject:search];
	[search release];
	
	return self;
}

#define SEARCH_BUTTON_INDEX 6

- (void)setSearchButton {
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate_ action:@selector(pushSearchButton:)];
	[items_ replaceObjectAtIndex:SEARCH_BUTTON_INDEX withObject:search];
	[search release];
	[self update];
}

- (void)setCloseSearchButton {
	UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:delegate_ action:@selector(pushCloseSearchButton:)];
	[items_ replaceObjectAtIndex:SEARCH_BUTTON_INDEX withObject:stop];
	[stop release];
	[self update];
}

@end
