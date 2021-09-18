#import "BoardView.h"
#import "BoardCell.h"
#import "global.h"

@implementation BoardView

// override

- (id) initWithFrame:(CGRect)frame {
	DNSLog( @"BoardView - initWithFrame" );
	self = [super initWithFrame:frame];
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	
	// all cell array
	cells_ = [[NSMutableArray array] retain];
	
	// navigation bar
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *titleBackButton = NSLocalizedString( @"boardNaviBarLeft", nil );
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = NSLocalizedString( @"boardNaviBarTitle", nil );
	naviTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: naviTitle_];
	[self addSubview:bar];
	
	// create table
	UITableColumn*  tableColumn;
	tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setSeparatorStyle:1];
	[self addSubview:table_];
	
	[self reload];
	return self;
}

- (void) dealloc {
	DNSLog( @"BoardView - dealloc" );
	[cells_ release];
	[super dealloc];
}

- (void) rebuildCells {
	int i;
	
	id ary = [[UIApp menuController] getTitlesInCurrentCategory];
	[naviTitle_ setTitle:[[UIApp menuController] getCurrentCategoryName]];
	
	id urlAry = [[UIApp menuController] getURLsInCurrentCategory];
	[cells_ removeAllObjects];

	for( i = 0; i < [ary count]; i++ ) {
		NSString* title = [ary objectAtIndex:i];
		NSString* url = [urlAry objectAtIndex:i];
		BoardCell* cell = [[[BoardCell alloc] init] autorelease];
		[cell setTitle:title withURL:url];
		[cells_ addObject:cell];
	}
}

- (void) reload {
	DNSLog( @"BoardView - reload" );
	[self rebuildCells];
	[table_ reloadData];
	[table_ _reloadRowHeights];
	[table_ scrollRowToVisible:0];
}

// UINavigationbar's delegate method

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[[UIApp view] showCategoryViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// UITable's delegate method
/*
- (float) table:(UITable *)table heightForRow:(int)row {
	return [[cells_ objectAtIndex:row] height];
}
*/
- (BOOL) table:(UITable *)aTable canSelectRow:(int)row {
	return YES;
}
- (int) numberOfRowsInTable:(UITable*)table {
	return [cells_ count];
}

- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col {
	return [cells_ objectAtIndex:row];
}

- (void) tableRowSelected:(NSNotification*)notification {
	id ary = [[UIApp menuController] getURLsInCurrentCategory];

	[[UIApp menuController] setCurrentBoardId:[table_ selectedRow]];
	
	[UIApp setBoardTitle:[[cells_ objectAtIndex:[table_ selectedRow]] title]];

	NSString* url = [ary objectAtIndex:[table_ selectedRow]];
	[UIApp setSubjectTxtURL:url];
	[[UIApp view] showThreadIndexViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
}

@end