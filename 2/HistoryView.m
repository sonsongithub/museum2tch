//
//  HistoryView.m
//  2tch
//
//  Created by sonson on 08/03/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryView.h"


@implementation HistoryView


- (id) initWithFrame:(CGRect)frame withDelegate:(id)fp{
	self = [super initWithFrame:frame];
	delegate_ = fp;
	[self setUpTable];
	
	return self;
}

- (id) table {
	return table_;
}

- (void) setUpTable {
	CGRect sizeTableView = [self frame];
	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[[UITable alloc] initWithFrame:sizeTableView] autorelease];
	[table_ addTableColumn:tableColumn];
	[table_ setSeparatorStyle:1];

	[table_ setDataSource:delegate_];
	[table_ setDelegate:delegate_];
	
	[self addSubview:table_];
}

@end
