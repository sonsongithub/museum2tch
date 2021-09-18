
#import "CategoryView.h"

@implementation CategoryView

// original method

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[UINavigationBar alloc] initWithFrame:sizeNavigationBar];
	NSString *versionCaption = [NSString stringWithUTF8String:"about"];
	[bar showButtonsWithLeftTitle:nil rightTitle:versionCaption leftBack:NO];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = [NSString stringWithUTF8String:"カテゴリ"];
	UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: titleItem];
	[self addSubview:bar];
	
	//
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

- (void) rebuildCells {
	int i;
	[cells_ release];
	cells_ = [[NSMutableArray array] retain];
	
	UIImageAndTextTableCell*	cell;
	NSString* title;
	
	id ary = [[UIApp menuController] getCategories];
	
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

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	NSString *closeCaption = [NSString stringWithUTF8String:"閉じる"];
	NSString *errorCaption = [NSString stringWithUTF8String:BUILD_DATE];
	switch (button) {
		case 0: // right
			[UIApp showStandardAlertWithString:VERSION_STRING_2CH_VIEWER closeBtnTitle:closeCaption withError:errorCaption];
			break;
		case 1:	// left
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
	[[(MyApp*)UIApp menuController] setCurrentCategoryId:[table_ selectedRow]];
	[UIApp showBoardViewWithTransition:1];
}

@end
