
#import "ThreadView.h"
#import "ThreadController.h"
#import "ThreadCell.h"
//#import "HTMLEliminator.h"
#import "global.h"

@implementation ThreadView

// override

- (void) dealloc {
	DNSLog( @"ThreadView - dealloc" );
	[table_ release];
	[cellArray_ release];
	[self removeFromSuperview];
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame {
	DNSLog( @"ThreadView - initWithFrame" );
	self = [super initWithFrame:frame];

	[self setupNavigationBar];
	[self setupButton];

	// create table
	CGRect sizeTableView = CGRectMake(0, 44, 320, 372);
	UITableColumn*  tableColumn = [[[UITableColumn alloc] initWithTitle:@"title" identifier:@"title" width:320] autorelease];
	table_ = [[UITable alloc] initWithFrame:sizeTableView];
	[table_ addTableColumn:tableColumn];
	[table_ setDataSource:self];
	[table_ setDelegate:self];
	[table_ setSeparatorStyle:1];
	[self addSubview:table_];
	
	[UIApp setDelegate:self];
	
	//
	cellArray_ = [[NSMutableArray array] retain];

	return self;
}

- (void) doBookmark {
	DNSLog( @"ThreadView - doBookmark" );
	CGPoint offset = [table_ offset];
	NSString *url = [UIApp datFileURL];
	id controller = [[[ThreadController alloc] initWithURLString:url] autorelease];
	NSString *str = [NSString stringWithFormat:@"%lf\n%d", (float)offset.y, currentPage_];
	DNSLog( str );
	[str writeToFile:[controller bookmarkPath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

// UINavigationbar's delegate

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0:			// right
			break;
		case 1:			// left
			[self doBookmark];
			[[UIApp view] showThreadIndexViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// UITable's delegate

- (BOOL) table:(UITable *)aTable canSelectRow:(int)row {
	return NO;
}

- (int) numberOfRowsInTable:(UITable*)table {
	return [cellArray_ count];
}

- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col {
	return [cellArray_ objectAtIndex:row];
}

- (float) table:(UITable *)table heightForRow:(int)row {
	return [[cellArray_ objectAtIndex:row] height];
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
		@"b5_preveous_51.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushAdd", kUIButtonBarButtonAction, 
		@"b5_add_51.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushReload", kUIButtonBarButtonAction, 
		@"b5_reload_52.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushGotoLast", kUIButtonBarButtonAction, 
		@"b5_tail_51.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushForward", kUIButtonBarButtonAction, 
		@"b5_next_51.png", kUIButtonBarButtonInfo,
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
	
	[buttonBar registerButtonGroup:1 withButtons:buttons withCount:tag-1	];
	[buttonBar showButtonGroup:1 withDuration:0.2];
	//[buttonBar showButtons:buttons withCount:3 withDuration:(double)0.2];
	free( buttons );
	[self addSubview:buttonBar];
}

- (void) setupNavigationBar {
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	// navigation bar
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *titleBackButton = [UIApp boardTitle];
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = [UIApp threadTitle];
	naviTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: naviTitle_];
	[self addSubview:bar];
}

- (void) onPushGotoLast {
	DNSLog( @"ThreadView -  onPushGotoLast" );
	currentPage_ = response_num_ / THREAD_PAGE;
	[self reload];
	CGSize size = [table_ contentSize];
	[table_ scrollPointVisibleAtTopLeft:CGPointMake( 0, size.height - 372 ) animated:YES];
}

- (void) onPushAdd {
	DNSLog( @"ThreadView -  onPushAdd" );
	[UIApp addThreadIntoFavouriteStackURL:[UIApp datFileURL] andTitle:[UIApp threadTitle]];
}

- (void) onPushReload {
	//[UIApp showLoadingAfterReloadAndSendOpenMethodToDelegate:self];
	[[UIApp view] showLoadingAfterReloadAndSendOpenMethodToDelegate:self];
}

- (void) onPushForward {
	DNSLog( @"ThreadView -  onPushForward" );
	if( currentPage_ < response_num_ / THREAD_PAGE ) {
		currentPage_++;
		[self reload];
		[table_ scrollPointVisibleAtTopLeft:CGPointMake( 0, 0 ) animated:YES];
	}
}

- (void) onPushBack {
	DNSLog( @"ThreadView -  onPushBack" );
	if( currentPage_ > 0 ) {
		currentPage_--;
		[self reload];
		[table_ scrollPointVisibleAtTopLeft:CGPointMake( 0, 0 ) animated:YES];
	}
}

- (void) releaseCache {
	[cellArray_ removeAllObjects];
}

- (BOOL) reload {
	DNSLog( @"ThreadView - reload" );
	int i;

	NSString *url = [UIApp datFileURL];
	id controller = [[[ThreadController alloc] initWithURLString:url] autorelease];

	response_num_ = [controller res];
	
	int rendering_start = THREAD_PAGE * currentPage_;
	int rendering_end = 0;
	int index = THREAD_PAGE * ( currentPage_ + 1 );
	if( index > response_num_ )
		rendering_end = response_num_;
	else
		rendering_end = index;
		
	NSMutableArray *ary = [controller getDataFrom:rendering_start To:rendering_end];
	
	if( ary == nil || [ary count] == 0 )
		return NO;

	[cellArray_ removeAllObjects];
	
	for( i = 0; i < [ary count] ; i++ ) {
		ThreadCell *cell = [[[ThreadCell alloc] init] autorelease];
		NSDictionary *dict = [ary objectAtIndex:i];
		[cell setDataWithDictionary:dict];
		[cellArray_ addObject:cell];
	}
	[table_ reloadData];
		
	[UIApp hideProgressHUD];
	DNSLog( @"ThreadView - make cells from %d to %d", rendering_start, rendering_end );
	return YES;
}

- (BOOL) open {
	DNSLog( @"ThreadView - open" );
	
	currentPage_ = 0;
	float scroll = 0;
	NSString *url = [UIApp datFileURL];
	id controller = [[[ThreadController alloc] initWithURLString:url] autorelease];

	if( ![controller updateDatFile] )
		DNSLog( @"ThreadView - cant' download dat" );
		
//	CGPoint offset = [table_ offset];
	NSString *str = [NSString stringWithContentsOfFile:[controller bookmarkPath] encoding:NSUTF8StringEncoding error:nil];
	DNSLog( str );
	NSArray*lines = [str componentsSeparatedByString:@"\n"];
	
	if( [lines count] ==2 ) {
		scroll = [[lines objectAtIndex:0] floatValue];
		currentPage_ = [[lines objectAtIndex:1] intValue];
	}
	
	BOOL result = [self reload];
	if( !result ) {
		return NO;
	}
	else { 
		[table_ scrollPointVisibleAtTopLeft:CGPointMake( 0, scroll) animated:YES];
		return YES;
	}
}

@end
