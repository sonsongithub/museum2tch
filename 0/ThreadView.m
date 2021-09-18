
#import "ThreadView.h"
#import "ThreadController.h"
#import "ThreadCell.h"

@implementation ThreadView

// override

- (void) dealloc {
	[thread_data_ release];
	[cellArray_ release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	CGRect sizeTableView = CGRectMake(0, 44, 320, 372);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	CGRect sizeButtonBar = CGRectMake(0, 416, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[UINavigationBar alloc] initWithFrame:sizeNavigationBar];
	NSString *titleBackButton = [NSString stringWithUTF8String:"スレ一覧"];
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = [NSString stringWithUTF8String:"スレッド"];
	naviTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
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
		DNSLog( @"ThreadView - making button id - %d,%d", buttons[i-1], i );
	}
	
	[buttonBar registerButtonGroup:1 withButtons:buttons withCount:tag-1	];
	[buttonBar showButtonGroup:1 withDuration:0.2];
	//[buttonBar showButtons:buttons withCount:3 withDuration:(double)0.2];
	free( buttons );
	[self addSubview:buttonBar];

	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
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
			[UIApp showThreadIndexViewWithTransition:2 andURL:nil fromView:self];
			break;
	}
}

// UITable's delegate

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	return NO;
}

- (int)numberOfRowsInTable:(UITable*)table {
	int index = THREAD_PAGE * ( currentPage_ + 1 );
	if( index > [thread_data_ count] ) {
		return [thread_data_ count] - THREAD_PAGE * currentPage_;
	}
	else {
		DNSLog( @"ThreadView - It has %d cells, now, all.", THREAD_PAGE );
		return THREAD_PAGE;
	}
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col {
	int index = THREAD_PAGE * currentPage_ + row;
	index = index % THREAD_PAGE;
	return [cellArray_ objectAtIndex:index];
}

- (float) table:(UITable *)table heightForRow:(int)row {
	int index = THREAD_PAGE * currentPage_ + row;
	index = index % THREAD_PAGE;
	return [[cellArray_ objectAtIndex:index] height];
}

- (void)tableRowSelected:(NSNotification*)notification {
}

// original method

- (void) reload {
	DNSLog( @"ThreadView - Not implemented." );
}

- (void) forward {
	if( currentPage_ < [thread_data_ count] / THREAD_PAGE ) {
		currentPage_++;
		[cellArray_ release];
		[self redrawText];
	}
	DNSLog( @"ThreadView - %d/%d Page.", currentPage_, [cellArray_ count] / THREAD_PAGE );
}

- (void) back {
	if( currentPage_ > 0 ) {
		currentPage_--;
		[cellArray_ release];
		[self redrawText];
	}
	DNSLog( @"ThreadView - %d/%d Page.", currentPage_, [cellArray_ count] / THREAD_PAGE );
}

- (void) releaseCache {
	[cellArray_ release];
	[thread_data_ release];
	DNSLog( @"ThreadView - releaseed cache." );
}

- (void) redrawText {
	int i;
	if( !thread_data_ )
		return;
		
	DNSLog( @"ThreadView - refresh text view." );
	
	cellArray_ = [[NSMutableArray array] retain];
	
	int redering_end = 0;
	int index = THREAD_PAGE * ( currentPage_ + 1 );
	if( index > [thread_data_ count] )
		redering_end = [thread_data_ count] - THREAD_PAGE * currentPage_ + THREAD_PAGE * currentPage_;
	else
		redering_end = index;
		
	for( i = THREAD_PAGE * currentPage_; i < redering_end; i++ ) {
		ThreadCell* cell = [[[ThreadCell alloc] init] autorelease];
		[cell setDataWithDictionary:[thread_data_ objectAtIndex:i]];
		[cellArray_ addObject:cell];
	}
	
	DNSLog( @"ThreadView - From %d to %d.", THREAD_PAGE * currentPage_, redering_end );
	[table_ reloadData];
	[table_ _reloadRowHeights];
	[table_ scrollRowToVisible:0];
	DNSLog( @"ThreadView - reload heights and cells" );
}

- (BOOL) reload:(NSString*)url {
	DNSLog( @"ThreadView - load dat file." );
	ThreadController* controller = [[[ThreadController alloc] init] autorelease];
	if( [controller loadURL:url] ) {
		thread_data_ = [[NSArray arrayWithArray:[controller getEntries]] retain];
		currentPage_ = 0;
		[self redrawText];
		return YES;
	}
	else {
		return NO;
	}
}

@end
