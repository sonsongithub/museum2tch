
#import "PreferenceView.h"
#import "MenuPreferenceTable.h"
#import "global.h"

@implementation PreferenceView

- (BOOL) savePlist {
	DNSLog( @"PreferenceView - save plist" );
	NSString *offlineMode;
	long x = [ offlineSwitch_ value ];
	if( x )
		offlineMode = @"true";
	else
		offlineMode = @"false";
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[threadIndex_label_ text],		@"threadIndexSize",
			[thread_label_ text],			@"threadSize",
			[daysToDelete_label_ text],		@"daysToMaintain",
			offlineMode,					@"offlineMode",
			nil];
	NSString *str = [dict description];
	return [str writeToFile:@"/private/var/root/Library/Preferences/com.sonson.2tch/preference.plist" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL) setDataToControl:(NSDictionary*)dict {
	//
	[thread_label_ setText:[dict objectForKey:@"threadSize"]];
	[threadIndex_label_ setText:[dict objectForKey:@"threadIndexSize"]];
	[daysToDelete_label_ setText:[dict objectForKey:@"daysToMaintain"]];
	
	//
	[self adjustTextLabel:threadIndex_label_];
	[self adjustTextLabel:thread_label_];
	[self adjustTextLabel:daysToDelete_label_];
	
	//
	NSString* offlineMode =[dict objectForKey:@"offlineMode"];
	if( [offlineMode isEqualToString:@"true"] )
		[offlineSwitch_ setValue:1];
	else
		[offlineSwitch_ setValue:0];
}

- (BOOL) setupGroup {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float blue[4] = {0.15, 0.24, 0.41, 1.0};
	
	CGRect switchRect = CGRectMake( 320 - 114.0f, 9.0f, 296.0f - 200.0f, 32.0f);

	GSFontRef bodyFont = GSFontCreateWithName( NORMAL_FONT_NAME, kGSFontTraitNormal, 19.0f );
	
	// title
	titleCell_ = [[UIPreferencesTableCell alloc] init];
	
	// thread index size
	threadIndexCell_ = [[UIPreferencesTableCell alloc] init];
	[threadIndexCell_ setTitle:NSLocalizedString( @"threadTitleFont", nil )];
	[threadIndexCell_ setDisclosureStyle:2];
	[threadIndexCell_ setShowDisclosure:YES];
	threadIndex_label_ = [[[UITextLabel alloc] initWithFrame:CGRectMake( 320 - 50, 11, 20, 13)] autorelease];
	[threadIndexCell_ addSubview:threadIndex_label_];
	[threadIndexCell_ sizeToFit];
	[threadIndex_label_ setColor:CGColorCreate( colorSpace, blue)];
	[threadIndex_label_ setFont:bodyFont];
	
	// thread size
	threadCell_ = [[UIPreferencesTableCell alloc] init];
	[threadCell_ setTitle:NSLocalizedString( @"threadFont", nil )];
	[threadCell_ setDisclosureStyle:2];
	[threadCell_ setShowDisclosure:YES];
	thread_label_ = [[[UITextLabel alloc] initWithFrame:CGRectMake( 320 - 50, 11, 20, 13)] autorelease];
	[threadCell_ addSubview:thread_label_];
	[threadCell_ sizeToFit];
	[thread_label_ setColor:CGColorCreate( colorSpace, blue)];
	[thread_label_ setFont:bodyFont];

	// title
	cacheDaysToDeleteCell_ = [[UIPreferencesTableCell alloc] init];
	[cacheDaysToDeleteCell_ setTitle:NSLocalizedString( @"daysToMaintain", nil )];
	[cacheDaysToDeleteCell_ setDisclosureStyle:2];
	[cacheDaysToDeleteCell_ setShowDisclosure:YES];
	daysToDelete_label_ = [[[UITextLabel alloc] initWithFrame:CGRectMake( 320 - 50, 11, 20, 13)] autorelease];
	[cacheDaysToDeleteCell_ addSubview:daysToDelete_label_];
	[cacheDaysToDeleteCell_ sizeToFit];
	[daysToDelete_label_ setColor:CGColorCreate( colorSpace, blue)];
	[daysToDelete_label_ setFont:bodyFont];
	
	// thread size
	offlineCell_ = [[UIPreferencesTableCell alloc] init];
	[offlineCell_ setTitle:NSLocalizedString( @"offlinemode", nil )];
	offlineSwitch_ = [[[UISwitchControl alloc] initWithFrame: switchRect] autorelease];
	[offlineCell_ addSubview:offlineSwitch_];
	
	updataBBSMenuCell_ = [[UIPreferencesTableCell alloc] init];
	[updataBBSMenuCell_ setTitle:NSLocalizedString( @"updateBBSMenuHTML", nil )];
	
	cacheDeleteCell_ = [[UIPreferencesTableCell alloc] init];
	[cacheDeleteCell_ setTitle:NSLocalizedString( @"deleteAllCache", nil )];
	
	initializeCell_ = [[UIPreferencesTableCell alloc] init];
	[initializeCell_ setTitle:NSLocalizedString( @"initialize", nil )];
	
	versionInfoCell_ = [[UIPreferencesTableCell alloc] init];
#ifdef		_DEBUG
	NSString *versionStr = [NSString stringWithFormat:@"%@ %s\nDebug build", VERSION_STRING_2CH_VIEWER, BUILD_DATE ];
#else
	NSString *versionStr = [NSString stringWithFormat:@"%@ %s", VERSION_STRING_2CH_VIEWER, BUILD_DATE ];
#endif
	[versionInfoCell_ setTitle:versionStr];
}

- (void) adjustTextLabel:(UITextLabel*)fp {
	[fp sizeToFit];
	CGRect rect = [fp frame];
	// 285 right edge
	float margin = rect.origin.x + rect.size.width - 285 - 5;
	rect.origin.x -= margin;
	[fp setFrame:rect];
}

- (BOOL) changeNaviBar:(int)mode {
	[self adjustTextLabel:threadIndex_label_];
	[self adjustTextLabel:thread_label_];
	[self adjustTextLabel:daysToDelete_label_];
	
	switch( mode ) {
		case 0:
			[barTitle_ setTitle:NSLocalizedString( @"threadTitleFont", nil )];
			[bar_ showButtonsWithLeftTitle:NSLocalizedString( @"preferenceTitle", nil ) rightTitle:nil leftBack: YES];
			break;
		case 1:
			[barTitle_ setTitle:NSLocalizedString( @"threadFont", nil )];
			[bar_ showButtonsWithLeftTitle:NSLocalizedString( @"preferenceTitle", nil ) rightTitle:nil leftBack: YES];
			break;
		case 2:
			[barTitle_ setTitle:NSLocalizedString( @"daysToMaintain", nil )];
			[bar_ showButtonsWithLeftTitle:NSLocalizedString( @"preferenceTitle", nil ) rightTitle:nil leftBack: YES];
			break;
		case 3:
			[barTitle_ setTitle:NSLocalizedString( @"preferenceTitle", nil )];
			[bar_ showButtonsWithLeftTitle:NSLocalizedString( @"preferenceNaviBarLeft", nil) rightTitle:nil leftBack: YES];
			break;
	}
}

- (void) removeCacheAndReset {
	int i;
	NSString *preferencePath = [UIApp preferencePath];
	NSArray *subContents = [[NSFileManager defaultManager] directoryContentsAtPath:preferencePath];
	for( i = 0; i < [subContents count]; i++ ) {
		BOOL isDirectory = NO;
		NSString *path = [NSString stringWithFormat:@"%@/%@", preferencePath, [subContents objectAtIndex:i]];
		if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] ) {
			if( isDirectory ) {
				DNSLog( @"%@", path );
				[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
			}
		}
	}
}

- (void) initializeAll {
	int i;
	NSString *preferencePath = [UIApp preferencePath];
	NSArray *subContents = [[NSFileManager defaultManager] directoryContentsAtPath:preferencePath];
	for( i = 0; i < [subContents count]; i++ ) {
		NSString *path = [NSString stringWithFormat:@"%@/%@", preferencePath, [subContents objectAtIndex:i]];
		DNSLog( @"%@", path );
		[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
	}
	[UIApp terminate];
}

- (void) dealloc {
	DNSLog( @"PreferenceView - dealloc" );
	[titleCell_ release];
	[threadIndexCell_ release];
	[threadCell_ release];
	[cacheDaysToDeleteCell_ release];
	[offlineCell_ release];
	[updataBBSMenuCell_ release];
	[cacheDeleteCell_ release];
	[versionInfoCell_ release];
	[table_ release];
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame {
	DNSLog( @"PreferenceView - initWithFrame" );
	self = [super initWithFrame:frame];
	
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	CGRect sizeTableView = CGRectMake(0, 44, 320, 416);
	CGRect tableRect = CGRectMake(0, 0, 320, 416);
	
	// table
	table_ = [[UIPreferencesTable alloc] initWithFrame:tableRect];
	[table_ setDataSource: self];
	[table_ setDelegate: self];
	
	//
	currentTable_ = table_;
	transitionView_ = [[[UITransitionView alloc] initWithFrame:sizeTableView] autorelease];
	[self addSubview:transitionView_];
	[transitionView_ setDelegate:self];
	[transitionView_ transition:1 fromView:currentTable_ toView:table_ ];
	
	//
	[self setupGroup];
	NSDictionary *dict = [UIApp readPlist];
	[self setDataToControl:dict];
	
	// Make navigation var
	bar_ = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	[bar_ showButtonsWithLeftTitle:nil rightTitle:nil leftBack:NO];
	[bar_ setBarStyle:5];
	[bar_ setDelegate:self];
	[bar_ enableAnimation];
	barTitle_ = [[[UINavigationItem alloc] initWithTitle:NSLocalizedString( @"preferenceTitle", nil )] autorelease];
	[bar_ pushNavigationItem: barTitle_];
	[self addSubview:bar_];
	[table_ reloadData];
	[self changeNaviBar:3];
	return self;
}

- (void) transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to {
	currentTable_ = to;
}

// UINavigationbar's delegate method

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			if( currentTable_ == table_ ) {
				[self savePlist];
				[UIApp readPreferenceData];
				[[UIApp view] showCategoryViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			}
			else {
				[transitionView_ transition:2 toView:table_];
				[self changeNaviBar:3];
			}
			break;
	}
}

// delegate

- (int) numberOfGroupsInPreferencesTable:(UIPreferencesTable*)aTable {
	return 6;
}

- (int) preferencesTable:(UIPreferencesTable*)aTable numberOfRowsInGroup:(int)group {
	switch( group ) {
		case 0:
			return 0;
		case 1:
			return 4;
		case 2:
			return 1;
		case 3:
			return 1;
		case 4:
			return 1;
		case 5:
			return 1;
	}
}

- (UIPreferencesTableCell*) preferencesTable:(UIPreferencesTable*)aTable cellForGroup:(int)group {
	switch(group) {
		case 0:
			return titleCell_;
		case 1:
			return titleCell_;
		case 2:
			return titleCell_;
		case 3:
			return titleCell_;
		case 4:
			return titleCell_;
		case 5:
			return versionInfoCell_;
	}
}

- (float) preferencesTable:(UIPreferencesTable*)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed {
	switch( group ) {
		case 0:
			return 5.0f;
		case 5:
			return 15.0f;
		default:
			return proposed;
	}
}

- (BOOL) preferencesTable:(UIPreferencesTable*)aTable isLabelGroup:(int)group {
	switch(group) {
		case 0:
			return YES;
		case 1:
			return NO;
		case 2:
			return NO;
		case 3:
			return NO;
		case 4:
			return NO;
		case 5:
			return YES;
	}
	return 0;
}

- (void) tableRowSelected:(NSNotification*)notification {
	CGRect tableRect = CGRectMake(0, 0, 320, 432);
	id cell = [table_ cellAtRow:[table_ selectedRow] column:0];
	if( cell == initializeCell_ ) {
		[initializeCell_ setSelected:YES];
		// make alert sheet
		alert_initialize_ = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
		[alert_initialize_ setTitle:@"2tch"];
		[alert_initialize_ setBodyText:NSLocalizedString( @"initializeConfirm", nil )];
		[alert_initialize_ addButtonWithTitle:@"OK" ];
		[alert_initialize_ addButtonWithTitle:@"Cancel" ];
		[alert_initialize_ setRunsModal:NO];
		[alert_initialize_ setAlertSheetStyle:0];
		[alert_initialize_ setDelegate: self ];
		[alert_initialize_ presentSheetInView: self ];
	}
	else if( cell == cacheDeleteCell_ ) {
		[cacheDeleteCell_ setSelected:YES];
		// make alert sheet
		alert_delete_ = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
		[alert_delete_ setTitle:@"2tch"];
		[alert_delete_ setBodyText:NSLocalizedString( @"deleteAllCacheConfirm", nil )];
		[alert_delete_ addButtonWithTitle:@"OK" ];
		[alert_delete_ addButtonWithTitle:@"Cancel" ];
		[alert_delete_ setRunsModal:NO];
		[alert_delete_ setAlertSheetStyle:0];
		[alert_delete_ setDelegate: self ];
		[alert_delete_ presentSheetInView: self ];
	}
	else if(cell == updataBBSMenuCell_ ) {
		[cell setSelected:YES];
		[[(MyApp*)UIApp menuController] updateBBSMenuHTML];
		[cell setSelected:NO];
	}
	else {
		if( cell == threadIndexCell_ ) {
			NSArray *ary = [NSArray arrayWithObjects:
							NSLocalizedString( @"font0", nil ),
							NSLocalizedString( @"font1", nil ),
							NSLocalizedString( @"font2", nil ),
							NSLocalizedString( @"font3", nil ),
							NSLocalizedString( @"font4", nil ),
							nil ];
			MenuPreferenceTable* table = [[MenuPreferenceTable alloc] initWithFrame:tableRect withTitles:ary withDelegate:threadIndex_label_];
			[table autorelease];
			[transitionView_ transition:1 toView:table];
			[self changeNaviBar:0];
		}
		else if( cell == threadCell_ ) {
			NSArray *ary = [NSArray arrayWithObjects:
							NSLocalizedString( @"font0", nil ),
							NSLocalizedString( @"font1", nil ),
							NSLocalizedString( @"font2", nil ),
							NSLocalizedString( @"font3", nil ),
							NSLocalizedString( @"font4", nil ),
							nil ];
			MenuPreferenceTable* table = [[MenuPreferenceTable alloc] initWithFrame:tableRect withTitles:ary withDelegate:thread_label_];
			[table autorelease];
			[transitionView_ transition:1 toView:table];
			[self changeNaviBar:1];
		}
		else if( cell == cacheDaysToDeleteCell_ ) {
			NSArray *ary = [NSArray arrayWithObjects:
							NSLocalizedString( @"delete0", nil ),
							NSLocalizedString( @"delete1", nil ),
							NSLocalizedString( @"delete2", nil ),
							NSLocalizedString( @"delete3", nil ),
							NSLocalizedString( @"delete4", nil ),
							NSLocalizedString( @"delete5", nil ),
							nil ];
			MenuPreferenceTable* table = [[MenuPreferenceTable alloc] initWithFrame:tableRect withTitles:ary withDelegate:daysToDelete_label_];
			[table autorelease];
			[transitionView_ transition:1 toView:table];
			[self changeNaviBar:2];
		}
		[cell setSelected:NO];
	}
}

- (void) alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button {
	if( sheet == alert_delete_ ) {
		if( button == 1 )
			[self removeCacheAndReset];
	}
	else if( sheet == alert_initialize_ ) {
		if( button == 1 )
			[self initializeAll];
	}
	[sheet dismiss];
	[cacheDeleteCell_ setSelected:NO];
	[initializeCell_ setSelected:NO];
}

- (UIPreferencesTableCell*) preferencesTable:(UIPreferencesTable*)aTable cellForRow:(int)row inGroup:(int)group {
	switch( group ) {
		case 0:
			return titleCell_;
		case 1:
			switch( row ) {
				case 0:
					return threadIndexCell_;
				case 1:
					return threadCell_;
				case 2:
					return cacheDaysToDeleteCell_;
				case 3:
					return offlineCell_;
			}
		case 2:
			return updataBBSMenuCell_;
		case 3:
			return cacheDeleteCell_;
		case 4:
			return initializeCell_;
		case 5:
			return versionInfoCell_;
	}
}

@end
