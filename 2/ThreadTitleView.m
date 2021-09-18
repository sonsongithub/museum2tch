
#import "ThreadTitleView.h"
#import "MainController.h"
#import "subjectTxt.h"
#import "ThreadIndexCell.h"
#import "global.h"

@implementation ThreadTitleView
// original method

- (id) initWithFrame:(CGRect)frame withParentController:(id)fp{
	DNSLog( @"ThreadTitleView - initWithFrame:withParentController" );

	self = [super initWithFrame:frame];

	cells_ = [[NSMutableArray array] retain];
		
	parentController_ = fp;
	
	id center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
			selector:@selector(openThreadTitleView:)
			name:@"openThreadTitleView"
			object:nil];
	
	isRefined_ = NO;
	
	[self setUpTable];

	return self;
}

- (void) openThreadTitleView:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilForwardToView"
				object:self];
}

- (void) dealloc {
	[cells_ release];
	DNSLog( @"ThreadTitleView - dealloc" );
	[super dealloc];
}

- (id) cells {
	return cells_;
}

- (void) showKeyword:(NSString*)keyword {
	[self hideKeyword];
	keywordLabel_ = [[[UITextLabel alloc] initWithFrame:CGRectMake( 10, 10, 200, 200 )] autorelease];
	
	float transparentomponents[4] = { 32.0f/255.0f, 45.0f/255.0f, 72.0f/255.0f, 0.75 };
	[keywordLabel_ setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	float white[4] = {1.0, 1.0, 1.0, 1};
	[keywordLabel_ setColor:CGColorCreate( CGColorSpaceCreateDeviceRGB(), white)];
	
	GSFontRef infoFont = GSFontCreateWithName( "arial",2, 17.0f );
	[keywordLabel_ setFont:infoFont];
	CFRelease(infoFont);
	
	NSString *label_str = [NSString stringWithFormat:@"%@%@", keyword, NSLocalizedString( @"refineLabelMessage", nil )];
	[keywordLabel_ setText:label_str];
	[keywordLabel_ sizeToFit];
	[self addSubview:keywordLabel_];	
	isRefined_ = YES;
}

- (void) hideKeyword {
	if( isRefined_ ) {
		[keywordLabel_ removeFromSuperview];
		isRefined_ = NO;
	}
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
}
- (void) reload {
	[[parentController_ SubjectTxt] startDownload];
}

// UITable's delegate method

- (float) table:(UITable *)table heightForRow:(int)row {
	return [ThreadIndexCell defaultHeight];
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	id data = [[parentController_ SubjectTxt] subjectTxtData];
	if( row == [data count] + 1 ) {
		return [[parentController_ SubjectTxt] hasReadCompletely];
	}
	else {
		return YES;
	}
}

- (int)numberOfRowsInTable:(UITable*)table {
	id data = [[parentController_ SubjectTxt] subjectTxtData];
	return [data count] + 1;
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col {
	id cell = nil;
	id data = [[parentController_ SubjectTxt] subjectTxtData];
	if( row < [data count] ) {
		id dict = [data objectAtIndex:row];
		cell = [[[ThreadIndexCell alloc] initWithDelegate:self] autorelease];
		[cell setDataWithDictionary:dict];
		[cell setDisclosureStyle:0];
		[cell setShowDisclosure:YES];
	}
	else {
		cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		if( [[parentController_ SubjectTxt] hasReadCompletely] )
			[cell setTitle:@"end"];
		else
			[cell setTitle:@"get next"];
		[cell setShowDisclosure:NO];
		[cell setDisclosureStyle:0];
	}
	return cell;
}

- (void) didForwardAndGotFocus:(id) fp {
	DNSLog( @"ThreadTitleView - got focus" );
	[self refreshCells];
	[table_ reloadData];
}

- (void) didBackAndGotFocus:(id) fp {
	DNSLog( @"BoardView - backw and got focus" );
	[self refreshCells];
	[table_ reloadData];
}

- (void) lostFocus:(id) fp {
	DNSLog( @"ThreadTitleView - lost focus" );
//	[self hideKeyword];
//	[table_ clearAllData];
}

- (id) table {
	return table_;
}

- (id) navibar {
	return bar_;
}

@end
