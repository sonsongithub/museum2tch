#import "BoardView.h"

@implementation BoardView

// override

- (id)initWithFrame:(CGRect)frame withMainControllerId:(id)mainController {
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[UINavigationBar alloc] initWithFrame:sizeNavigationBar];
	NSString *titleBackButton = [NSString stringWithUTF8String:"カテゴリ"];
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = [NSString stringWithUTF8String:"板一覧"];
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
	[table_ reloadData];
	[self addSubview:table_];
	
	[self reload];

	return self;
}

- (void) rebuildCells {
	int i;
	[cells_ release];
	cells_ = [[NSMutableArray array] retain];
	
	UIImageAndTextTableCell*	cell;
	NSString* title;
	id ary = [[UIApp menuController] getTitlesInCurrentCategory];
	
	[naviTitle_ setTitle:[[UIApp menuController] getCurrentCategoryName]];
	
	for( i = 0; i < [ary count]; i++ ) {
		title = [ary objectAtIndex:i];
		cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		[cell setTitle:title];
		[cell setDisclosureStyle:2];
		[cell setShowDisclosure:YES];
		[cells_ addObject:cell];
	}
}

- (void) reload {
	[self rebuildCells];
	[table_ reloadData];
	[table_ scrollRowToVisible:0];
}

// UINavigationbar's delegate method

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[UIApp showCategoryViewWithTransition:TRANSITION_VIEW_BACK];
			break;
	}
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

- (void)tableRowSelected:(NSNotification*)notification {
	id ary = [[UIApp menuController] getURLsInCurrentCategory];
	
	[[UIApp menuController] setCurrentBoardId:[table_ selectedRow]];
	
	NSString* url = [ary objectAtIndex:[table_ selectedRow]];
	[UIApp showThreadIndexViewWithTransition:1 andURL:url];
}

@end