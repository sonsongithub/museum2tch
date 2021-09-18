//
//  ToolbarController.m
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ToolbarController.h"
#import "_tchAppDelegate.h"
#import "global.h"

#import "CategoryViewController.h"
#import "BoardViewController.h"
#import "TitleViewController.h"
#import "ThreadViewController.h"

@implementation ToolbarController

@synthesize centerMessage = centerLabel_;
@synthesize threadViewLabel = threadViewLabel_;

#pragma mark Original Method

- (void) updateMessageSpace:(NSString*)string {
	centerLabel_.text = string;
	[messageSpace_ release];
	messageSpace_ = [[UIBarButtonItem alloc] initWithCustomView:centerLabel_];
}

- (void) setCategoryViewMode:(id)delegate {
	
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];

	centerLabel_.text = [UIAppDelegate.bbsmenu updateDateString];
	[messageSpace_ release];
	messageSpace_ = [[UIBarButtonItem alloc] initWithCustomView:centerLabel_];
	[items addObject:messageSpace_];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

- (void) setBoardViewMode:(id)delegate {
	
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];

	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	centerLabel_.text = [UIAppDelegate.bbsmenu updateDateString];
	[messageSpace_ release];
	messageSpace_ = [[UIBarButtonItem alloc] initWithCustomView:centerLabel_];
	[items addObject:messageSpace_];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

- (void) setTitleViewMode:(id)delegate {
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];

	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];

	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(pushAddButton:)];
	[items addObject:add];
	[add release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	threadTitleLabel_.text = NSLocalizedString( @"Loading", nil );
	[messageThreadTitleSpace_ release];
	messageThreadTitleSpace_ = [[UIBarButtonItem alloc] initWithCustomView:threadTitleLabel_];
	[items addObject:messageThreadTitleSpace_];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate action:@selector(pushSearchButton:)];
	[items addObject:search];
	[search release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

- (void) clear:(id)delegate {
	backupItems_ = [[toolbar items] retain];
	NSMutableArray* new_items = [[NSMutableArray alloc] init];
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[new_items addObject:bookmark];
	[bookmark release];
	[toolbar setItems:new_items animated:YES];
	[new_items release];
}

- (void) back {
	[toolbar setItems:backupItems_ animated:YES];
	[backupItems_ release];
}

- (void) updateTitleViewMessageWithString:(NSString*)message {
	NSArray *items = [toolbar items];
	
	if( [items count] != 7 )
		return;
	if( [items objectAtIndex:4] != messageThreadTitleSpace_ )
		return;
	
	NSMutableArray* new_items = [[NSMutableArray alloc] init];
	[new_items addObject:[items objectAtIndex:0]];
	[new_items addObject:[items objectAtIndex:1]];
	
	[new_items addObject:[items objectAtIndex:2]];
	[new_items addObject:[items objectAtIndex:3]];
	
	threadTitleLabel_.text = message;
	[messageThreadTitleSpace_ release];
	messageThreadTitleSpace_ = [[UIBarButtonItem alloc] initWithCustomView:threadTitleLabel_];
	[new_items addObject:messageThreadTitleSpace_];
	
	[new_items addObject:[items objectAtIndex:5]];
	[new_items addObject:[items objectAtIndex:6]];
	
	[toolbar setItems:new_items animated:YES];
	[new_items release];
}

- (void) setTitleViewWithSearchButtonMode:(id)delegate {
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(pushAddButton:)];
	[items addObject:add];
	[add release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	[items addObject:messageThreadTitleSpace_];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate action:@selector(pushSearchButton:)];
	[items addObject:search];
	[search release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

- (void) setTitleViewWithCancelButtonMode:(id)delegate {
	
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];

	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(pushAddButton:)];
	[items addObject:add];
	[add release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	[items addObject:messageThreadTitleSpace_];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:delegate action:@selector(pushReplyButton:)];
	[items addObject:reply];
	[reply release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

- (void) setThreadViewMode:(id)delegate numberOfRes:(int)numberOfRes isLimitedNewTo200:(BOOL)isLimitedNewTo200 mode:(int)mode {
	
	NSMutableArray *items = [[NSMutableArray alloc] init];	// [NSMutableArray array];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate action:@selector(pushBookmarkButton:)];
	[items addObject:bookmark];
	[bookmark release];
	 
	[items addObject:flexibleSpace];
	 
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(pushAddButton:)];
	[items addObject:add];
	[add release];
	 
	[items addObject:flexibleSpace];

	[popupController_ release];
	popupController_ = [PopupMenuController defaultControllerOfRes:numberOfRes new200:isLimitedNewTo200];
	popupController_.delegate = delegate;
	[popupController_ setMainTitleWithCellNumber:mode];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:popupController_.view];
	[items addObject:item];
	[item release];
	
	[items addObject:flexibleSpace];
	
	UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:delegate action:@selector(pushTrashButton:)];
	[items addObject:trash];
	[trash release];
	
	[items addObject:flexibleSpace];
	
	UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:delegate action:@selector(pushReplyButton:)];
	[items addObject:reply];
	[reply release];
	
	[flexibleSpace release];
	
	[toolbar setItems:items animated:YES];
	[items release];
}

#pragma mark Override

- (void)viewDidLoad {
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 0, 320, 44)];
	centerLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 40, 0, 240, 44)];
	threadTitleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 40, 0, 145, 44)];
	CGRect rect = self.view.frame;
	rect.origin.y = 416;
	self.view.frame = rect;
	[self.view addSubview:toolbar];
	[self.view addSubview:centerLabel_];
	centerLabel_.text = @"";
	centerLabel_.backgroundColor = [UIColor clearColor];
	centerLabel_.textColor = [UIColor whiteColor];
	centerLabel_.textAlignment = UITextAlignmentCenter;
	centerLabel_.shadowColor = [UIColor blackColor];
	centerLabel_.font = [UIFont boldSystemFontOfSize:13.0f];
	
	threadTitleLabel_.text = @"";
	threadTitleLabel_.backgroundColor = [UIColor clearColor];
	threadTitleLabel_.textColor = [UIColor whiteColor];
	threadTitleLabel_.textAlignment = UITextAlignmentCenter;
	threadTitleLabel_.shadowColor = [UIColor blackColor];
	threadTitleLabel_.font = [UIFont boldSystemFontOfSize:13.0f];
	
	threadViewLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 36, 40)];
	threadViewLabel_.text = @"";
	threadViewLabel_.backgroundColor = [UIColor clearColor];
	threadViewLabel_.textColor = [UIColor whiteColor];
	threadViewLabel_.textAlignment = UITextAlignmentCenter;
	threadViewLabel_.shadowColor = [UIColor blackColor];
	threadViewLabel_.numberOfLines = 2;
	threadViewLabel_.font = [UIFont boldSystemFontOfSize:12.0f];
	
	messageSpace_ = [[UIBarButtonItem alloc] initWithCustomView:centerLabel_];
	messageThreadViewSpace_ = [[UIBarButtonItem alloc] initWithCustomView:threadViewLabel_];
	
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DNSLog( @"[ToolbarController] didReceiveMemoryWarning" );
}

- (void)dealloc {
	[backupItems_ release];
	[messageSpace_ release];
	[centerLabel_ release];
	[toolbar release];
    [super dealloc];
}

@end
