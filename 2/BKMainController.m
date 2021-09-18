//
//  BKMainController.m
//  2tch
//
//  Created by sonson on 08/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BKMainController.h"
#import "BookmarkView.h"
#import "BookmarkController.h"
#import "HistoryView.h"
#import "HistoryController.h"
#import "ThreadIndexCell.h"
#import "global.h"

@implementation BKMainController

- (id) init {
	self = [super init];
	view_ = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 460 )];
	
	historyController_ = [[HistoryController alloc] initWithDelegate:self];
	bookmarkController_ = [[BookmarkController alloc] initWithDelegate:self];
	
	bkMainView_ = [[UITransitionView alloc] initWithFrame:CGRectMake( 0, 44, 320, 372 )];
	[bkMainView_ setDelegate:self];
	[view_ addSubview:bkMainView_];
	[self setUpNavigationBar];
	[self setUpUnderNavigationBar];

	bkView_ = [[BookmarkView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372) withDelegate:self];
	[bkMainView_ addSubview:bkView_];
	
	historyView_ = [[HistoryView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372) withDelegate:self];
	[[historyView_ table] reloadData];
	[[bkView_ table] _reloadRowHeights];
	[[bkView_ table] reloadData];
	
	return self;
}

- (void) reloadTables {
	[[historyView_ table] reloadData];
	[[bkView_ table] reloadData];
	[[bkView_ table] _reloadRowHeights];
}

- (id) view {
	return view_;
}

- (void) dealloc {
	[bkMainView_ release];
	[super dealloc];
}

- (void) setUpNavigationBar {
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	// navigation bar
	bar_ = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	[bar_ enableAnimation];
	
	[bar_ setDelegate:self/*parentController_*/];
	
	[bar_ showButtonsWithLeftTitle:nil rightTitle:NSLocalizedString( @"bookmarkViewCloseTitle", nil )];
	
	id item = [[[UINavigationItem alloc] initWithTitle:NSLocalizedString( @"bookmarkBarTitle", nil )] autorelease];
	[bar_ pushNavigationItem:item];
	[view_ addSubview:bar_];
}

- (void) setUpUnderNavigationBar {
	CGRect sizeNavigationBar = CGRectMake(0, 416, 320, 44);
	// navigation bar
	underBar_ = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	[underBar_ enableAnimation];
	
	[underBar_ setDelegate:self/*parentController_*/];
	[view_ addSubview:underBar_];
}

- (void)transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to {
	if( to == bkView_ )
		[underBar_ hideButtons];
	else if( to == historyView_ )
		[underBar_ showButtonsWithLeftTitle:NSLocalizedString( @"bookmarkViewEditTitle", nil ) rightTitle:nil];
}

- (void)navigationBar:(UINavigationBar*)navigationBar poppedItem:(UINavigationItem*)item {
	[bkMainView_ transition:2 toView:bkView_];
}

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	if( navbar == bar_ ) {
		if( button == 0 ) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"wiilCloseBKView" object:self];
		}
	}
	else if( navbar == underBar_ ) {
		// make alert sheet
		id sheet = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
		[sheet setTitle:NSLocalizedString( @"appName", nil )];
		[sheet setBodyText:nil];
		[sheet addButtonWithTitle:NSLocalizedString( @"historyDeleteConfirmationMsg", nil ) ];
		[sheet addButtonWithTitle:NSLocalizedString( @"cacheDeleteConfirmationMsg", nil ) ];
		[sheet addButtonWithTitle:NSLocalizedString( @"cancelMsg", nil ) ];
		[sheet setRunsModal:NO];
		[sheet setAlertSheetStyle:0];
		[sheet setDelegate: self ];
		[sheet presentSheetInView: bkMainView_ ];
	}
}

- (void) alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button {
	DNSLog( @"->%d", button );
	if( button == 1 ) {		// delete history
		[historyController_ clear];
		[[historyView_ table] reloadData];
	}
	if( button == 2 ) {		// delete history and cache
		[UIApp deleteCache];
		[historyController_ clear];
		[[historyView_ table] reloadData];
	}
	[sheet dismiss];
}

- (void) moveToHistory {
	id item = [[[UINavigationItem alloc] initWithTitle:NSLocalizedString( @"historyBarTitle", nil )] autorelease];
	[bar_ pushNavigationItem:item];
	[bkMainView_ transition:1 toView:historyView_];
}

- (void) tableRowSelected:(NSNotification*)notification {
	id table = [notification object];
	if( table == [bkView_ table] ) {
		if( [table selectedRow] == 0 ) {
			[self moveToHistory];
		}
		else {
			id bookmarkData = [bookmarkController_ bookmark];
			id dict = [bookmarkData objectAtIndex:[table selectedRow] - 1];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"wiilCloseBKView" object:self];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"cancel"
				object:self];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"addHistory"
				object:dict];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"didSelectThread"
				object:dict];
		}
	}
	else if( table == [historyView_ table] ) {
		int row = [table selectedRow];
		id historyData =[historyController_ history];
		
		id dict = [historyData objectAtIndex:row];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"wiilCloseBKView" object:self];
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"cancel"
				object:self];
		[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"addHistory"
		object:dict];
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"didSelectThread"
				object:dict];
	}
}

// UITable's delegate method

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	return YES;
}

- (int)numberOfRowsInTable:(UITable*)table {
	if( table == [bkView_ table] ) {
		id bookmarkData = [bookmarkController_ bookmark];
		return [bookmarkData count] + 1;
	}
	else if( table == [historyView_ table] ) {
		id historyData =[historyController_ history];
		return [historyData count];
	}
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col {
	if( table == [bkView_ table] ) {
		if( row == 0 ) {
			id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
			UIImage* img = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"HistoryFolder" ofType:@"png" inDirectory:@"/"]];
			[cell setTitle:NSLocalizedString( @"historyBarTitle", nil )];
			[cell setImage:img];
			[cell setShowDisclosure:YES];
			[cell setDisclosureStyle:0];
			return cell;
		}
		else {
			id bookmarkData = [bookmarkController_ bookmark];
			id cell = [[[ThreadIndexCell alloc] initWithDelegate:self] autorelease];
			[cell setDataWithDictionary:[bookmarkData objectAtIndex:row-1]];
			//id title = [[bookmarkData objectAtIndex:row-1] objectForKey:@"threadTitle"];
			//[cell setTitle:title];
			return cell;
		}
	}
	else if( table == [historyView_ table] ) {
		id historyData =[historyController_ history];
		id cell = [[[ThreadIndexCell alloc] initWithDelegate:self] autorelease];
		[cell setDataWithDictionary:[historyData objectAtIndex:row]];
		return cell;
	}
}

- (float) table:(UITable *)table heightForRow:(int)row {
	if( table == [bkView_ table] ) {
		//id cell = [[bkView_ table] cellAtRow:row column:0];
		return [ThreadIndexCell defaultHeight];
		/*
		if( row == 0 ) {
			return 40.0f;
		}
		else {
			//id cell = [[bkView_ table] cellAtRow:row column:0];
			//DNSLog( @"%d rows -> %f", row, [cell height] );
			//return 150.0f;
			//return [cell height];
		}
		*/
	}
	else if( table == [historyView_ table] ) {
		return [ThreadIndexCell defaultHeight];
	}
}

- (void) delete:(id)cell {
	int row = [[bkView_ table] _rowForTableCell:cell];
	[[bookmarkController_ bookmark] removeObjectAtIndex:row - 1];
}

@end
