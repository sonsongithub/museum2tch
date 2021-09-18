
#import "FavouriteView.h"
#import "FavouriteTable.h"
#import "FavouriteCell.h"
#import "global.h"

@implementation FavouriteView

// overide

- (void) dealloc {
	[cellArray_ release];
	[urlArray_ release];
	[table_ release];
	DNSLog( @"FavouriteView -dealloc" );
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *leftCaption = NSLocalizedString( @"fabouriteNaviBarLeft", nil );
	[bar showButtonsWithLeftTitle:leftCaption rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = NSLocalizedString( @"fabouriteNaviBarTitle", nil );
	UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: titleItem];
	[self addSubview:bar];

	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[FavouriteTable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setSeparatorStyle:1];
	[self addSubview:table_];
	
	// init
	cellArray_ = [[NSMutableArray array] retain];
	urlArray_ = [[NSMutableArray array] retain];
	
	DNSLog( @"FavouriteView -initWithFrame" );
	return self;
}

// UINavigationbar's delegate method

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[self backupFavourite];
			[[UIApp view] showCategoryViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// UITable's delegate method

- (BOOL) table:(UITable *)aTable canSelectRow:(int)row {
	return YES;
}

- (int) numberOfRowsInTable:(UITable*)table {
	return [cellArray_ count];
}

- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col {
	return [cellArray_ objectAtIndex:row];
}

- (void) tableRowSelected:(NSNotification*)notification {
	DNSLog( @"FavouriteView - %@", [urlArray_ objectAtIndex:[table_ selectedRow]] );
	[UIApp setBoardTitle:[[cellArray_ objectAtIndex:[table_ selectedRow]] escapedTitle]];
	[UIApp setDatFileURL:[urlArray_ objectAtIndex:[table_ selectedRow]]];
	[[UIApp view] showFavouriteThreadViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
}

- (float) table:(UITable *)table heightForRow:(int)row {
	return [[cellArray_ objectAtIndex:row] height];
}

// original method

- (void) delete:(id)cell {
	int row = [ table_ _rowForTableCell:cell];
	[cellArray_ removeObjectAtIndex:row];
	[urlArray_ removeObjectAtIndex:row];
}

- (BOOL) open {
	int i;
	
	[cellArray_ removeAllObjects];
	[urlArray_ removeAllObjects];
	
	NSMutableArray *new_favourite = [UIApp favouriteStack];
	NSMutableArray *favourite_from_file = [UIApp readFavouriteSubjectTxt];
	
	if( [favourite_from_file count] == 0 ) {
		DNSLog( @"Can't read file" );
	}
	
	[UIApp mergeFavourite:new_favourite into:favourite_from_file];
		
	for( i = 0; i < [favourite_from_file count]; i++ ) {
		FavouriteCell* cell = [[[FavouriteCell alloc] initWithDelegate:self] autorelease];
		NSString *title = [[favourite_from_file objectAtIndex:i] objectForKey:@"title"];
		[cell setTitle:eliminate(title) withEscapedTitle:title];
		[cell setDisclosureStyle:2];
		[cell setShowDisclosure:YES];
		[cellArray_ addObject:cell];
		[urlArray_ addObject:[[favourite_from_file objectAtIndex:i] objectForKey:@"url"]];
	}
	[table_ reloadData];
	
	[new_favourite removeAllObjects];
	return YES;
}

- (BOOL) backupFavourite {
	int i;
	NSMutableString* output = [NSMutableString string];
	for( i = 0; i < [cellArray_ count]; i++ ) {
		[output appendFormat:@"%@<>%@\n", [urlArray_ objectAtIndex:i], [[cellArray_ objectAtIndex:i] escapedTitle] ];
	}
	NSString* path = [NSString stringWithFormat:@"%@/favouriteSubject.txt", [UIApp preferencePath]];
	if( [output writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil] ) {
		DNSLog( @"Save favourite" );
	}
}

@end
