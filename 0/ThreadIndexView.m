
#import "ThreadIndexView.h"
#import "ThreadIndexController.h"

@implementation ThreadIndexView

// override

- (id)initWithFrame:(CGRect)frame withMainControllerId:(id)mainController {
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 372);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	CGRect sizeButtonBar = CGRectMake(0, 416, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[UINavigationBar alloc] initWithFrame:sizeNavigationBar];
	NSString *titleBackButton = [NSString stringWithUTF8String:"板一覧"];
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	
	NSString *title = [NSString stringWithUTF8String:"スレ一覧"];
	naviTitle_ = [[UINavigationItem alloc] initWithTitle:title];
	[bar pushNavigationItem: naviTitle_];
	[self addSubview:bar];
	
	int i;
	int tag = 1;
	int style = 0;
	int type = 0;
	
	NSMutableArray *ary = [NSMutableArray array];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"back", kUIButtonBarButtonAction, 
		@"NavBack.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"reload", kUIButtonBarButtonAction, 
		@"reload.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"forward", kUIButtonBarButtonAction, 
		@"NavForward.png", kUIButtonBarButtonInfo,
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	
	id buttonBar = [[[UIButtonBar alloc] initInView:self withFrame:sizeButtonBar withItemList:ary] autorelease];
	
	int* buttons = (int*)malloc(sizeof( int ) * tag );

	
	for( i = 1; i < tag; i++ ) {
		buttons[i-1] = i;
		DNSLog( @"ThreadIndexView - making button id - %d,%d", buttons[i-1], i );
	}
	
	[buttonBar registerButtonGroup:1 withButtons:buttons withCount:tag-1	];
	[buttonBar showButtonGroup:1 withDuration:0.2];
	[self addSubview:buttonBar];
	free( buttons );
	
	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setRowHeight:65.0f];
	[table_ setSeparatorStyle:1];
	[self addSubview:table_];

	return self;
}

// UINavigationbar's delegate

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[UIApp showBoardViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// UITable's delegate

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	return YES;
}

- (int)numberOfRowsInTable:(UITable*)table {
	int index = THREAD_INDEX_PAGE * ( currentPage_ + 1 );
	if( index > [threads_ count] )
		return [threads_ count] - THREAD_INDEX_PAGE * currentPage_;
	else
		return THREAD_INDEX_PAGE;
}
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col {
	int index = THREAD_INDEX_PAGE * currentPage_ + row;
	index = index % THREAD_INDEX_PAGE;
	return [cellArray_ objectAtIndex:index];
}

- (void)tableRowSelected:(NSNotification*)notification {
	int index = [table_ selectedRow];
	id str = [NSString stringWithFormat:@"%@dat/%@", baseUrl_, [urlArray_ objectAtIndex:index]];
	DNSLog( str );
	[UIApp showThreadViewWithTransition:TRANSITION_VIEW_FORWARD andURL:str];
}

// original method

- (void) reload {
	DNSLog( @"ThreadIndexView - Not implemented." );
}

- (void) forward {
	if( currentPage_ < [threads_ count] / THREAD_INDEX_PAGE ) {
		currentPage_++;
		[urlArray_ release];
		[cellArray_ release];
		[self rebuildCellsWithThreadsData];
	}
	DNSLog( @"ThreadIndexView - %d/%d Page.", currentPage_, [threads_ count] / THREAD_INDEX_PAGE );
}

- (void) back {
	if( currentPage_ > 0 ) {
		currentPage_--;
		[urlArray_ release];
		[cellArray_ release];
		[self rebuildCellsWithThreadsData];
	}
	DNSLog( @"ThreadIndexView - %d/%d Page.", currentPage_, [threads_ count] / THREAD_INDEX_PAGE );
}

- (void) rebuildCellsWithThreadsData {
	int i;
	GSFontRef titleFont = GSFontCreateWithName("Helvetica", 2, 12.0f);
	//GSFontRef titleFont = GSFontCreateWithName("Helvetica", kGSFontTraitBold, 14.0f);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float transparentomponents[4] = {1, 1, 1, 0};
	
	cellArray_ = [[NSMutableArray array] retain];
	urlArray_ = [[NSMutableArray array] retain];
	
	[naviTitle_ setTitle:[[UIApp menuController] currentBoardName]];
	
	int redering_end = 0;
	int index = THREAD_INDEX_PAGE * ( currentPage_ + 1 );
	if( index > [threads_ count] )
		redering_end = [threads_ count] - THREAD_INDEX_PAGE * currentPage_ + THREAD_INDEX_PAGE * currentPage_;
	else
		redering_end = index;
		
	for( i = THREAD_INDEX_PAGE * currentPage_; i < redering_end; i++ ) {
		UITableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		UITextLabel *label = [[[UITextLabel alloc] initWithFrame:CGRectMake(10, 0, 290, 59)] autorelease];
		
		id thread_data = [threads_ objectAtIndex:i];
		id flagString = [thread_data valueForKey:@"dataAvaiable"];
		if( [flagString isEqualToString:@"false"] ) {
			id title_resnum = [thread_data valueForKey:@"string"];
			[label setText:[NSString stringWithFormat:@"%03d. %@", i+1, title_resnum]];
			DNSLog( @"ThreadIndexView - %@", title_resnum );
		}
		else {
			id title = [thread_data valueForKey:@"string"];
			id resnum = [thread_data valueForKey:@"resnum"];
			[label setText:[NSString stringWithFormat:@"%03d. %@(%@)", i+1, title, resnum]];
			DNSLog( @"ThreadIndexView - %@", title );
		}
		[urlArray_ addObject:[thread_data valueForKey:@"path"]];

		[label setFont:titleFont];
		[label setWrapsText:YES];
		[label setBackgroundColor: CGColorCreate( colorSpace, transparentomponents)];
		[cell addSubview:label];
		[cell setDisclosureStyle:2];
		[cell setShowDisclosure:YES];
		[cellArray_ addObject:cell];
	}
	
	DNSLog( @"ThreadIndexView - From %d to %d.", THREAD_INDEX_PAGE * currentPage_, redering_end );
	[table_ reloadData];
	DNSLog( @"ThreadIndexView - reload heights and cells" );
	CFRelease(titleFont);
}

- (void) releaseCache {
	[threads_ release];
	[urlArray_ release];
	[cellArray_ release];
	[baseUrl_ release];
	DNSLog( @"ThreadIndexView - releaseed cache." );
}

- (BOOL) reload:(NSString*)url {
	DNSLog( @"ThreadIndexView - reload subject.txt." );
	id controller = [[[ThreadIndexController alloc] init] autorelease];
	BOOL result = [controller doProcess:url];
	baseUrl_ = [[NSString stringWithString:url] retain];
	if( result ) {
		threads_ = [[NSArray arrayWithArray:[controller threads]] retain];
		currentPage_ = 0;
		[self rebuildCellsWithThreadsData];
		DNSLog( @"ThreadIndexView - success, reload subject.txt." );
	}
	return result;
}
@end
