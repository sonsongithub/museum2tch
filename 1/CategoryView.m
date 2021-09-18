
#import "CategoryView.h"
#import "global.h"

@implementation CategoryView

// original method

- (id) initWithFrame:(CGRect)frame {
	DNSLog( @"CategoryView - initWithFrame" );
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *preferenceCaption = NSLocalizedString( @"categoryNaviBarLeft", nil );
	NSString *favouriteCaption = NSLocalizedString( @"categoryNaviBarRight", nil );
	[bar showButtonsWithLeftTitle:preferenceCaption rightTitle:favouriteCaption leftBack:NO];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = NSLocalizedString( @"categoryNaviBarTitle", nil );
	UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: titleItem];
	[self addSubview:bar];
	
	//
	cells_ = [[NSMutableArray array] retain];
	[self rebuildCells];
	
	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setSeparatorStyle:1];
	[table_ reloadData];
	[self addSubview:table_];

	return self;
}

- (void) dealloc {
	DNSLog( @"CategoryView - dealloc" );
	[cells_ release];
	[super dealloc];
}

- (void) rebuildCells {
	int i;
	
	UIImageAndTextTableCell*	cell;
	NSString* title;
	
	id ary = [[UIApp menuController] getCategories];
	[cells_ removeAllObjects];
	
	for( i = 0; i < [ary count]; i++ ) {
		title = [ary objectAtIndex:i];
		cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		[cell setTitle:title];
		[cell setDisclosureStyle:2];
		[cell setShowDisclosure:YES];
		[cells_ addObject:cell];
	}
}

// UINavigationbar's delegate method

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			[[UIApp view] showFavouriteViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
			break;
		case 1:	// left
			[[UIApp view] showPreferenceViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
			break;
	}
}

// UITable's delegate method

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
	[[(MyApp*)UIApp menuController] setCurrentCategoryId:[table_ selectedRow]];
//	DNSLog( [[cells_ objectAtIndex:[table_ selectedRow]] title] );

	[UIApp setCategoryTitle:[[cells_ objectAtIndex:[table_ selectedRow]] title]];

	[[UIApp view] showBoardViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
}

@end
