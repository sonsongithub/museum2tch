
#import "ThreadIndexView.h"
#import "ThreadIndexController.h"
#import "ThreadIndexCell.h"
#import "global.h"

@implementation ThreadIndexView

// override

- (void) dealloc {
	[cellArray_ release];
	[urlArray_ release];
	[table_ release];
	[self removeFromSuperview];
	DNSLog( @"ThreadIndexView - dealloc" );
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame {
	DNSLog( @"ThreadIndexView - initWithFrame" );
	self = [super initWithFrame:frame];
	
	CGRect sizeTableView = CGRectMake(0, 44, 320, 372);
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);

	// navigation bar
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *titleBackButton = [UIApp categoryTitle];
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	
	NSString *title = [UIApp boardTitle];
	naviTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: naviTitle_];
	[self addSubview:bar];
	
	// create navigationbar button
	[self setupButton];
	
	// create table
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setRowHeight:65.0f];
	[table_ setSeparatorStyle:1];
	[self addSubview:table_];
	
	// init
	cellArray_ = [[NSMutableArray array] retain];
	urlArray_ = [[NSMutableArray array] retain];

	return self;
}

// UINavigationbar's delegate

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[[UIApp view] showBoardViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// UITable's delegate

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
	[UIApp setThreadTitle:[[cellArray_ objectAtIndex:[table_ selectedRow]] title]];
	[UIApp setDatFileURL:[urlArray_ objectAtIndex:[table_ selectedRow]]];
	[[UIApp view] showThreadViewWithTransition:TRANSITION_VIEW_FORWARD fromView:self];
}

- (float) table:(UITable *)table heightForRow:(int)row {
	return [[cellArray_ objectAtIndex:row] height];
}

- (BOOL) reloadCellArrays {
	DNSLog( @"ThreadIndexView - reloadData" );
	int i;
	NSString* subjectTxtURL = [UIApp subjectTxtURL];
	id controller = [[[ThreadIndexController alloc] initWithURLString:subjectTxtURL] autorelease];

	thread_num_ = [controller res];
	
	int rendering_start = THREAD_INDEX_PAGE * currentPage_;
	int rendering_end = 0;
	int index = THREAD_INDEX_PAGE * ( currentPage_ + 1 );
	if( index > thread_num_ )
		rendering_end = thread_num_;
	else
		rendering_end = index;
		
	NSMutableArray *ary = [controller getDataFrom:rendering_start To:rendering_end];
	
	if( ary == nil || [ary count] == 0 )
		return NO;

	[cellArray_ removeAllObjects];
	[urlArray_ removeAllObjects];
	
	for( i = 0; i < [ary count] ; i++ ) {
		ThreadIndexCell *cell = [[[ThreadIndexCell alloc] init] autorelease];
		NSDictionary *dict = [ary objectAtIndex:i];
		[urlArray_ addObject:[dict valueForKey:@"url"]];
		[cell setDataWithDictionary:dict];
		[cell setDisclosureStyle:2];
		[cell setShowDisclosure:YES];
		[cellArray_ addObject:cell];
	}
	[table_ reloadData];
	[table_ scrollRowToVisible:0];
	
	return YES;
}

// original method

- (void) setupButton {
	
	int i;
	int tag = 1;
	int style = 0;
	int type = 0;
	
	CGRect sizeButtonBar = CGRectMake(0, 416, 320, 44);
	NSMutableArray *ary = [NSMutableArray array];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushBack", kUIButtonBarButtonAction, 
		@"b3_preveous_92.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushReload", kUIButtonBarButtonAction, 
		@"b3_reload_92.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushForward", kUIButtonBarButtonAction, 
		@"b3_next_92.png", kUIButtonBarButtonInfo,
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	
	id buttonBar = [[[UIButtonBar alloc] initInView:self withFrame:sizeButtonBar withItemList:ary] autorelease];
	int* buttons = (int*)malloc(sizeof( int ) * tag );
	
	for( i = 1; i < tag; i++ )
		buttons[i-1] = i;
	
	[buttonBar registerButtonGroup:1 withButtons:buttons withCount:tag-1];
	[buttonBar showButtonGroup:1 withDuration:0.2];
	[self addSubview:buttonBar];
	free( buttons );
}

- (void) onPushReload {
	[[UIApp view] showLoadingAfterReloadAndSendReloadMethodToDelegate:self];
}

- (void) onPushForward {
	if( currentPage_ < thread_num_ / THREAD_INDEX_PAGE ) {
		currentPage_++;
		[self reloadCellArrays];
	}
}

- (void) onPushBack {
	if( currentPage_ > 0 ) {
		currentPage_--;
		[self reloadCellArrays];
	}
}

- (void) releaseCache {
}

- (BOOL) open {
	DNSLog( @"ThreadIndexView - open" );
	currentPage_ = 0;
	NSString* subjectTxtURL = [UIApp subjectTxtURL];
	id controller = [[[ThreadIndexController alloc] initWithURLString:subjectTxtURL] autorelease];
	if( [controller getSubjectTxt] ) {
		[UIApp hideProgressHUD];
		return [self reloadCellArrays];
	}
	[UIApp hideProgressHUD];
	return NO;
}

- (BOOL) reload {
	DNSLog( @"ThreadIndexView - reload" );
	currentPage_ = 0;
	NSString* subjectTxtURL = [UIApp subjectTxtURL];
	id controller = [[[ThreadIndexController alloc] initWithURLString:subjectTxtURL] autorelease];
	if( [controller reloadSubjectTxt] ) {
		[UIApp hideProgressHUD];
		return [self reloadCellArrays];
	}
	[UIApp hideProgressHUD];
	return NO;
}

@end
