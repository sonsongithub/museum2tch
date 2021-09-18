//
//  BookmarkViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BookmarkViewToolbarController.h"

@implementation BookmarkViewToolbarController

@synthesize segmentControlBarButtonItem = segmentControlBarButtonItem_;
@synthesize segmentControl = segmentControl_;

#pragma mark -
#pragma mark Original method

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
	delegate_ = delegate;
	[self initializeToolbar];
	return self;
}

#pragma mark -
#pragma mark Initialize toolbar

- (void)initializeToolbar {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Edit" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditButton:)];
	[items_ addObject:editButton];
	[editButton release];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	NSArray* segmentControlObjects = [[[NSArray alloc] initWithObjects:LocalStr( @"All" ), LocalStr( @"Unread" ), nil ] autorelease];
	segmentControl_ = [[[UISegmentedControl alloc] initWithItems:segmentControlObjects] autorelease];
	self.segmentControlBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentControl_] autorelease];
	[items_ addObject:segmentControlBarButtonItem_];
	
	segmentControl_.selectedSegmentIndex = 0;
	segmentControl_.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentControl_ addTarget:delegate_ action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	[segmentControl_ setToggleWhenTwoSegments:NO];
	
	[self update];
}

#pragma mark -
#pragma mark Toggle toolbar

- (void)setupToolbarWhileNotEditing {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Edit" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditButton:)];
	[items_ replaceObjectAtIndex:0 withObject:editButton];
	[editButton release];

//	for making a new folder
//	[items_ replaceObjectAtIndex:2 withObject:segmentControlBarButtonItem_];
	
	[items_ addObject:segmentControlBarButtonItem_];
	
	[self update];
}

- (void)setupToolbarWhileEditing {
	UIBarButtonItem *editDoneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushEditDoneButton:)];
	[items_ replaceObjectAtIndex:0 withObject:editDoneButton];
	[editDoneButton release];

//	for making a new folder
//	UIBarButtonItem *newFolderButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"NewFolder" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushNewFolderButton:)];
//	[items_ replaceObjectAtIndex:2 withObject:newFolderButton];
//	[newFolderButton release];
	
	[items_ removeObjectAtIndex:2];
	
	[self update];
}

#pragma mark -
#pragma mark Control hidden/shown  buttons on under UIToolbar

- (void)updateUnreadRemained:(int)remained {
	NSString *newTitle = nil;
	if( remained > 0 )
		newTitle = [NSString stringWithFormat:@"%@(%d)", LocalStr( @"Unread" ), remained ];
	else
		newTitle = LocalStr( @"Unread" );
	
	[segmentControl_ setTitle:newTitle forSegmentAtIndex:1];
}

- (void)toggleToEditButton {
	[self setupToolbarWhileNotEditing];
}

- (void)toggleToEditDoneButton {
	[self setupToolbarWhileEditing];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[segmentControlBarButtonItem_ release];
	[super dealloc];
}

@end
