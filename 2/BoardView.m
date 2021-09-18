//
//  BoardView.m
//  2tch
//
//  Created by sonson on 08/02/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
#import "MainController.h"
#import "BBSMenu.h"
#import "global.h"

@implementation BoardView

// original method

- (id) initWithFrame:(CGRect)frame withParentController:(id)fp{
	DNSLog( @"CategoryView - initWithFrame:withParentController" );

	self = [super initWithFrame:frame];
	
	parentController_ = fp;
	
	cells_ = [[NSMutableArray array] retain];
	
//	[self setUpNavigationBar];
	[self setUpTable];

	return self;
}

- (id) cells {
	return cells_;
}

- (void) dealloc {
	DNSLog( @"CategoryView - dealloc" );
	[super dealloc];
}

- (void) setUpTable {
	CGRect sizeTableView = CGRectMake(0, 0, 320, 372);
	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[[UITable alloc] initWithFrame:sizeTableView] autorelease];
	[table_ addTableColumn:tableColumn];
	[table_ setSeparatorStyle:1];

	[table_ setDataSource:self];
	[table_ setDelegate:parentController_];
	
	[self addSubview:table_];
}

- (void) reload {
	[NSThread detachNewThreadSelector:(SEL)NSSelectorFromString(@"showProgressHUD") toTarget:UIApp withObject:nil];
	if( [[parentController_ BBSMenu] downloadBBSMenu] ) {		
		[self refreshCells];
	}
	[UIApp hideProgressHUD];
	[UIApp setStatusBarShowsProgress:NO];
}

- (void) refreshCells {
	int i;
	id cell;
	id boards = [[parentController_ BBSMenu] board];
	id currentCategoryName = [parentController_ currentCategoryName];
	[cells_ removeAllObjects];
	
	for( i = 0; i < [boards count]; i++ ) {
		id dict = [boards objectAtIndex:i];
		if( [[dict objectForKey:@"category"] isEqualToString:currentCategoryName] ) {
			cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
			[cell setTitle:[dict objectForKey:@"title"]];
			[cell setShowDisclosure:YES];
			[cell setDisclosureStyle:0];
			[cells_ addObject:cell];
		}
	}

/*	
	NSEnumerator *enumerator = [boards objectEnumerator];
	id value;

	while ((value = [enumerator nextObject])) {
		if( [[value objectForKey:@"category"] isEqualToString:currentCategoryName] ) {
			cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
			[cell setTitle:[value objectForKey:@"title"]];
			[cells_ addObject:cell];
		}
	}	
	return;
*/
/*
	id boardIDs = [boards allKeys];
	for( i = 0; i < [boardIDs count]; i++ ) {
		id dict = [boards objectForKey:[boardIDs objectAtIndex:i]];
		if( [[dict objectForKey:@"category"] isEqualToString:currentCategoryName] ) {
		cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		[cell setTitle:[dict objectForKey:@"title"]];
		[cells_ addObject:cell];
		}
	}
*/
}

// UITable's delegate method

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	return YES;
}

- (int)numberOfRowsInTable:(UITable*)table {
	return [cells_ count];
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col {
	return [cells_ objectAtIndex:row];
}

- (void) didForwardAndGotFocus:(id) fp {
	DNSLog( @"BoardView - forward and got focus" );
	[self refreshCells];
	[table_ reloadData];
}

- (void) didBackAndGotFocus:(id) fp {
	DNSLog( @"BoardView - backw and got focus" );
	[self refreshCells];
	[table_ reloadData];
}

- (void) lostFocus:(id) fp {
	DNSLog( @"BoardView - lost focus" );
//	[table_ clearAllData];
}

- (id) table {
	return table_;
}

@end
