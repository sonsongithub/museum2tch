//
//  BookmarkView.m
//  2tch
//
//  Created by sonson on 08/03/02.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkView.h"
#import "global.h"

@interface BookmarkTable : UITable {
}
- (int) swipe:(int)direction withEvent:(struct __GSEvent *)event;
@end
@implementation BookmarkTable
- (int) swipe:(int)direction withEvent:(struct __GSEvent *)event {
	if((direction == kSwipeDirectionRight) || (direction == kSwipeDirectionLeft) ){
		CGRect rect = GSEventGetLocationInWindow(event);
		CGPoint point = CGPointMake(rect.origin.x, rect.origin.y - 44 ); 
		// if you have a titleNavBar then you need to subtract the titleNavBar height from rect.origin.y
		CGPoint offset = _startOffset; 
		point.x += offset.x;
		point.y += offset.y;
		int row = [self rowAtPoint:point];
		if ( row == 0 )
			return [super swipe:direction withEvent:event];
		[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:YES withDisclosure:NO animated:YES isDelete:YES andRemoveConfirmation:YES];
	}
	return [super swipe:direction withEvent:event];
}
@end


@implementation BookmarkView

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
	table_ = [[[BookmarkTable alloc] initWithFrame:sizeTableView] autorelease];
	[table_ addTableColumn:tableColumn];
	[table_ setSeparatorStyle:1];

	[table_ setDataSource:delegate_];
	[table_ setDelegate:delegate_];
	
	[self addSubview:table_];
}

@end
