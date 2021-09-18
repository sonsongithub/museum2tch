
#import "MainController.h"
#import "BBSMenu.h"
#import "CategoryView.h"
#import "global.h"

@implementation CategoryView

// original method

- (id) initWithFrame:(CGRect)frame withParentController:(id)fp{
	DNSLog( @"CategoryView - initWithFrame:withParentController" );

	self = [super initWithFrame:frame];

	cells_ = [[NSMutableArray array] retain];
		
	parentController_ = fp;
	
//	[self setUpNavigationBar];
	[self setUpTable];

	return self;
}

- (void) dealloc {
	[cells_ release];
	DNSLog( @"CategoryView - dealloc" );
	[super dealloc];
}

- (id) cells {
	return cells_;
}

- (void) setUpNavigationBar {
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	// navigation bar
	bar_ = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
/*
	NSString *preferenceCaption = NSLocalizedString( @"categoryNaviBarLeft", nil );
	NSString *favouriteCaption = NSLocalizedString( @"categoryNaviBarRight", nil );
	[bar_ showButtonsWithLeftTitle:preferenceCaption rightTitle:favouriteCaption leftBack:NO];
	[bar_ setBarStyle:5];
*/
	[bar_ setDelegate:parentController_];
	
	NSString *title = NSLocalizedString( @"categoryNaviBarTitle", nil );
	UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar_ pushNavigationItem: titleItem];
	[self addSubview:bar_];
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

- (void) refreshCells {
	int i;
	id cell;
	id categories = [[parentController_ BBSMenu] category];
	
	[cells_ removeAllObjects];
	
	for( i = 0; i < [categories count]; i++ ) {
		cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		[cell setTitle:[categories objectAtIndex:i]];
		[cell setShowDisclosure:YES];
		[cell setDisclosureStyle:0];
		[cells_ addObject:cell];
	}
}

- (void) reload {
	[NSThread detachNewThreadSelector:(SEL)NSSelectorFromString(@"showProgressHUD") toTarget:UIApp withObject:nil];
	if( [[parentController_ BBSMenu] downloadBBSMenu] ) {		
		[self refreshCells];
	}
	[UIApp hideProgressHUD];
	[UIApp setStatusBarShowsProgress:NO];
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
	DNSLog( @"CategoryView - got focus" );
	[self refreshCells];
	[table_ reloadData];
}

- (void) didBackAndGotFocus:(id) fp {
	DNSLog( @"CategoryView - backw and got focus" );
	[table_ reloadData];
}

- (void) lostFocus:(id) fp {
	DNSLog( @"CategoryView - lost focus" );
}

- (id) table {
	return table_;
}

- (id) navibar {
	return bar_;
}

@end
