//
//  BookmarkViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/12/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewToolbarController.h"


@implementation BookmarkViewToolbarController

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
	
	NSArray* array = [[NSArray alloc] initWithObjects:NSLocalizedString( @"all", nil ), NSLocalizedString( @"new", nil ), nil ];
	segmentController_ = [[UISegmentedControl alloc] initWithItems:array];
	segmentController_.segmentedControlStyle = UISegmentedControlStyleBar;
	[array release];
	segmentController_.selectedSegmentIndex = 0;
	[segmentController_ addTarget:delegate_ action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	
	return self;
}

- (void)setEditEnabled:(BOOL)enabled {
	UIBarButtonItem *edit = [items_ objectAtIndex:0];
	edit.enabled = enabled;
}

- (void)setNormalMode {
	[items_ removeAllObjects];
	UIBarButtonItem *flexibleSpace;
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Edit", nil ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditButton:)];
	[items_ addObject:edit];
	[edit release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem* segment = [[UIBarButtonItem alloc] initWithCustomView:segmentController_];
	[items_ addObject:segment];
	[segment release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *checkButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Check", nil ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushCheckButton:)];
	[items_ addObject:checkButton];
	[checkButton release];
	
	[self update];
}

- (void)setBookmarkEditinglMode {
	[items_ removeAllObjects];
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Done", nil ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditDoneButton:)];
	[items_ addObject:edit];
	[edit release];
	[self update];
}

- (void)dealloc {
	[segmentController_ release];
	[super dealloc];
}

@end
