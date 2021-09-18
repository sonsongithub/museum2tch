//
//  BookmarkViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewToolbarController.h"

@implementation BookmarkViewToolbarController

@synthesize segmentControll = segmentControll_;

#pragma mark Original Method

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	UIBarButtonItem *flexibleSpace = nil;
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Edit" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditButton:)];
	[items_ addObject:editButton];
	[editButton release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	NSArray* array = [[NSArray alloc] initWithObjects:LocalStr( @"All" ), LocalStr( @"Unread" ), nil ];
	segmentControll_ = [[UISegmentedControl alloc] initWithItems:array];
	segmentControll_.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentControllButton_ = [[UIBarButtonItem alloc] initWithCustomView:segmentControll_];
	[items_ addObject:segmentControllButton_];
	[array release];
	[segmentControll_ release];
	segmentControll_.selectedSegmentIndex = 0;
	[segmentControll_ addTarget:delegate action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	[segmentControll_ setToggleWhenTwoSegments:NO];
	
//	[segmentControll_ setWidth:80 forSegmentAtIndex:1];
	
	return self;
}

- (void)updateUnreadRemained:(int)remained {
	NSString *newTitle = nil;
	if( remained > 0 )
		newTitle = [NSString stringWithFormat:@"%@(%d)", LocalStr( @"Unread" ), remained ];
	else
		newTitle = LocalStr( @"Unread" );
	
	[segmentControll_ setTitle:newTitle forSegmentAtIndex:1];
}

- (void)toggleToEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Edit" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditButton:)];
	[items_ replaceObjectAtIndex:0 withObject:editButton];
	[items_ addObject:segmentControllButton_];
	[editButton release];
	[self update];
}

- (void)toggleToEditDoneButton {
	UIBarButtonItem *editDoneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditDoneButton:)];
	[items_ replaceObjectAtIndex:0 withObject:editDoneButton];
	[items_ removeLastObject];
	[editDoneButton release];
	[self update];
}

#pragma mark dealloc

- (void)dealloc {
	[segmentControllButton_ release];
	[super dealloc];
}

@end
