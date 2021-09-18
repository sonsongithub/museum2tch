
#import "MenuPreferenceTable.h"
#import "global.h"

@implementation MenuPreferenceTable

// over ride

- (void) dealloc {
	DNSLog( @"MenuPreferenceTable - dealloc" );
	[ary_ release];
	[titleCell_ release];
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame withTitles:(NSArray*)titles withDelegate:(id)fp {
	DNSLog( @"MenuPreferenceTable - initWithFrame withTitles and delegate" );
	int i;
	CGRect tableRect = CGRectMake(0, 0, 320, 416);
	self = [super initWithFrame:tableRect];
	ary_ = [[NSMutableArray array] retain];
	items_ = [titles count];
	
	for( i = 0; i < [titles count]; i++ ) {
		id title = [titles objectAtIndex:i];
		id cell = [[UIPreferencesTableCell alloc] init];
		[cell setTitle:title];
		[ary_ addObject:cell];
	}
	titleCell_ = [[UIPreferencesTableCell alloc] init];
	
	[self setDataDelegate:fp];
	
	[self setDataSource: self];
	[self setDelegate: self];
	[self reloadData];
	
	return self;
}

// original

- (void) setDataDelegate:(id)fp {
	id delegateTitle = [fp text];
	int i;
	
	[[ary_ objectAtIndex:0] setChecked:YES];
	delegate_ = fp;

	for( i = 0; i < [ary_ count]; i++ )
		[[ary_ objectAtIndex:i] setChecked:NO];

	for( i = 0; i < [ary_ count]; i++ ) {
		id cellTitle = [[ary_ objectAtIndex:i] title];
		[[ary_ objectAtIndex:i] setChecked:NO];
		if( [cellTitle isEqualToString:delegateTitle] ) {
			[[ary_ objectAtIndex:i] setChecked:YES];
			return;
		}
	}
	[[ary_ objectAtIndex:0] setChecked:YES];
	[delegate_ setText:[[ary_ objectAtIndex:0] title]];
}

// delegate method

- (int) numberOfGroupsInPreferencesTable:(UIPreferencesTable*)aTable {
	return 1;
}

- (int) preferencesTable:(UIPreferencesTable*)aTable numberOfRowsInGroup:(int)group {
	switch( group ) {
		case 0:
			return items_;
	}
}

- (UIPreferencesTableCell*) preferencesTable:(UIPreferencesTable*)aTable cellForGroup:(int)group {
	switch(group) {
		case 0:
			return nil;
	}
}

- (float) preferencesTable:(UIPreferencesTable*)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed {
	switch( group ) {
		case 0:
			return 40.0f;
		default:
			return proposed;
	}
}

- (BOOL) preferencesTable:(UIPreferencesTable*)aTable isLabelGroup:(int)group {
	switch(group) {
		case 0:
			return NO;
	}
	return 0;
}

- (void) tableRowSelected:(NSNotification*)notification {
	int i;
	id cell = [self cellAtRow:[self selectedRow] column:0];
	[cell setSelected:NO];
	for( i = 0; i < [ary_ count]; i++ )
		[[ary_ objectAtIndex:i] setChecked:NO];
	[cell setChecked:YES];
	[delegate_ setText:[cell title]];
}

- (UIPreferencesTableCell*) preferencesTable:(UIPreferencesTable*)aTable cellForRow:(int)row inGroup:(int)group {
	switch( group ) {
		case 0:
			return [ary_ objectAtIndex:row];
	}
}

- (void) alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button {
	[sheet dismiss];
}

@end
