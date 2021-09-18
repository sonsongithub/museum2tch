#import "BaseInfoViewController.h"
#import "_tchAppDelegate.h"
#import "InfoViewCell.h"
#import "global.h"

NSString *kDismissInfoViewMsg = @"dismissInfoView";

@implementation BaseInfoViewController

- (IBAction)closeAction:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		DNSLog(@"[BaseBookmarkViewController] initWithNibName");
		/*
		 [[NSNotificationCenter defaultCenter] addObserver:self 
		 selector:@selector(dismissInfoView:)
		 name:kDismissInfoViewMsg
		 object:nil];
		 */
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[self reloadCacheSize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

- (void) dealloc {
	DNSLog( @"dealloc" );
	DNSLog( @"[InfoViewController] dealloc" );
	[cells_ removeAllObjects];
	[cells_ release];
	//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) dismissInfoView:(NSNotification *)notification {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) viewDidLoad {
	DNSLog( @"[BaseInfoViewController] viewDidLoad");
	self.view = [InfoNavController_ view];
	self.title = NSLocalizedString( @"InfoViewTitle", @"" );
	closeButton_.title = NSLocalizedString( @"InfoViewClose", @"" );
	
//	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
//	self.title = NSLocalizedString(@"InfoViewTitle", @"");
//	tableView_.delegate = self;
//	tableView_.dataSource = self;
	
	[self makeCells];
	[self reloadCacheSize];
	//[tableView_ reloadData];
	self.view.autoresizesSubviews = YES;
}


// fetch objects from our bundle based on keys in our Info.plist
- (id)infoValueForKey:(NSString*)key {
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (void)reloadCacheSize {
	InfoViewCell*cell = [cells_ objectForKey:@"CacheSizeCell"];
	cell.attr.text = NSLocalizedString( @"InfoViewCacheLoading", nil );
	
	cell = [cells_ objectForKey:@"DatFileCell"];
	cell.attr.text = NSLocalizedString( @"InfoViewCacheLoading", nil );
	
	[NSThread detachNewThreadSelector:@selector(checkSize) toTarget:self withObject:nil];
}


#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title;
	switch (section) {
		case 0: {
			title = NSLocalizedString(@"InfoView_AppSectionTitle", @"");
			break;
		}
		case 1: {
			title = NSLocalizedString(@"InfoView_CacheSectionTitle", @"");
			break;
		}
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: {
			return 4;
		}
		case 1: {
			return 3;
		}
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 37.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"InfoViewNormalCell"];
	if( cell == nil ) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"InfoViewNormalCell"] autorelease];
	}
	
	if( [indexPath section] == 0 ) {
		switch( [indexPath row] ) {
			case 0:
				cell = [cells_ objectForKey:@"TitleCell"];
				break;
			case 1:
				cell = [cells_ objectForKey:@"VersionCell"];
				break;
			case 2:
				cell = [cells_ objectForKey:@"CopyrightCell"];
				break;
			case 3:
				cell.text = NSLocalizedString( @"InfoViewGoToWebSite", @"" );
				cell.textAlignment = UITextAlignmentCenter;
				break;
		}
	}
	else if( [indexPath section] == 1 ) {
		switch( [indexPath row] ) {
			case 0:
				cell = [cells_ objectForKey:@"CacheSizeCell"];
				break;
			case 1:
				cell = [cells_ objectForKey:@"DatFileCell"];
				break;
			case 2:
				cell.text = NSLocalizedString( @"InfoViewDeleteCache", @"" );
				cell.textAlignment = UITextAlignmentCenter;
				break;
		}
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [indexPath section] == 0 && [indexPath row] == 3 ) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString( @"InfoViewGoToWebSiteURL", @"")]];
	}
	if( [indexPath section] == 1 && [indexPath row] == 2 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"InfoViewCacheSheetTitle", @"" )
														   delegate:self
												  cancelButtonTitle:NSLocalizedString( @"InfoViewCacheSheetCancelButton", @"" )
											 destructiveButtonTitle:NSLocalizedString( @"InfoViewCacheSheetDeleteButton", @"" )
												  otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
		DNSLog(@"UIButton was clicked");
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		[self delaeteAllCacheFilesAndQuit];
		DNSLog(@"ok");
	}
	else {
		DNSLog(@"cancel");
	}
	NSIndexPath *tableSelection = [tableView_ indexPathForSelectedRow];
	[tableView_ deselectRowAtIndexPath:tableSelection animated:YES];
}

- (BOOL) stopBackgroundCheckSize {
	DNSLog( @"[InfoViewController] stopBackgroundCheckSize - trying to stop" );
	isTryingToStopCheckSize_ = YES;
	
	if( isFinishedCheckSize_ ) {
		DNSLog( @"[InfoViewController] stopBackgroundCheckSize - have already stopped" );
		return YES;
	}
	
	while( 1 ) {
		[NSThread sleepForTimeInterval:0.25];
		if( isFinishedCheckSize_ )
			break;
	}
	DNSLog( @"[InfoViewController] stopBackgroundCheckSize - has stopped" );
	return YES;
}

- (void) makeCells {
	cells_ = [[NSMutableDictionary dictionary] retain];
	InfoViewCell *cell;
	NSArray* ary = nil;
	
	// title
	ary = [[NSBundle mainBundle] loadNibNamed:@"InfoViewCell" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[InfoViewCell class]] ) {
			cell = (InfoViewCell*)obj;
			cell.title.text = NSLocalizedString( @"InfoViewApplicationTitle", nil );
			cell.attr.text = [self infoValueForKey:@"CFBundleName"];
			[cell setFont];
			[cells_ setObject:cell forKey:@"TitleCell"];
			break;
		}
	}
	
	// version
	ary = [[NSBundle mainBundle] loadNibNamed:@"InfoViewCell" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[InfoViewCell class]] ) {
			cell = (InfoViewCell*)obj;
#ifdef _DEBUG
			NSString *str = [NSString stringWithFormat:@"%@d (r%@)", [self infoValueForKey:@"CFBundleVersion"],NSLocalizedString( @"SvnRevision", @"" )];
#else
			NSString *str = [NSString stringWithFormat:@"%@ (r%@)", [self infoValueForKey:@"CFBundleVersion"],NSLocalizedString( @"SvnRevision", @"" )];
#endif		
			cell.title.text = NSLocalizedString( @"InfoViewVersionTitle", nil );
			cell.attr.text = str;
			[cell setFont];
			[cells_ setObject:cell forKey:@"VersionCell"];
			break;
		}
	}
	
	// copyright
	ary = [[NSBundle mainBundle] loadNibNamed:@"InfoViewCell" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[InfoViewCell class]] ) {
			cell = (InfoViewCell*)obj;
			cell.title.text = NSLocalizedString( @"InfoViewCopyRightTitle", nil );
			cell.attr.text = NSLocalizedString( @"InfoViewCopyRight", nil );
			[cell setFont];
			[cells_ setObject:cell forKey:@"CopyrightCell"];
			break;
		}
	}
	
	// cache size
	ary = [[NSBundle mainBundle] loadNibNamed:@"InfoViewCell" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[InfoViewCell class]] ) {
			cell = (InfoViewCell*)obj;
			cell.title.text = NSLocalizedString( @"InfoViewCacheSize", nil );
			cell.attr.text = NSLocalizedString( @"InfoViewCacheLoading", nil );
			//	cell.indicator.hidden = NO;
			//	[cell.indicator startAnimating];
		//	[NSThread detachNewThreadSelector:@selector(checkSize) toTarget:self withObject:nil];
			[cell setFont];
			[cells_ setObject:cell forKey:@"CacheSizeCell"];
			break;
		}
	}
	
	// number of dat files
	ary = [[NSBundle mainBundle] loadNibNamed:@"InfoViewCell" owner:self options:nil];
	for( id obj in ary ){
		if( [obj isKindOfClass:[InfoViewCell class]] ) {
			cell = (InfoViewCell*)obj;
			cell.title.text = NSLocalizedString( @"InfoViewNumberOfThread", nil );
			cell.attr.text = NSLocalizedString( @"InfoViewCacheLoading", nil );
			//	cell.indicator.hidden = NO;
			//	[cell.indicator startAnimating];
			//	[NSThread detachNewThreadSelector:@selector(checkSize) toTarget:self withObject:nil];
			[cell setFont];
			[cells_ setObject:cell forKey:@"DatFileCell"];
			break;
		}
	}
}

- (void) checkSize {
	id pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread sleepForTimeInterval:0.75];
	
	@synchronized(self) {
		isFinishedCheckSize_ = NO;
		isTryingToStopCheckSize_ = NO;
		InfoViewCell*cell = [cells_ objectForKey:@"CacheSizeCell"];
		//	cell.indicator.hidden = NO;
		//	[cell.indicator startAnimating];
	}
	
	NSFileManager *m = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray* ary = [m subpathsOfDirectoryAtPath:documentsDirectory error:nil];
	unsigned long long cachesize = 0;
	unsigned long long datfile_num = 0;
	for( NSString* path in ary ) {
		NSRange range = [path rangeOfString:@".dat"];
		
		if( range.location != NSNotFound )
			datfile_num++;
		
		NSString* targetPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
		NSDictionary* attr = [m fileAttributesAtPath:targetPath traverseLink:YES];
		NSNumber * fileSize;
		if (fileSize = [attr objectForKey:NSFileSize]) {
			// DNSLog(@"%@ - File size: %qi\n", targetPath, [fileSize unsignedLongLongValue]);
			cachesize += [fileSize unsignedLongLongValue];
		}
		@synchronized(self) {
			if( isTryingToStopCheckSize_ ) {
				break;
			}
		}
	}
	DNSLog( @"All size is %qi", cachesize );
	DNSLog( @"All Dat files are %qi", datfile_num );
	
	@synchronized(self) {
		isFinishedCheckSize_ = YES;
	}
	
	@synchronized(self) {
		if( !isTryingToStopCheckSize_ ) {
			float digit = 0;
			if( cachesize > 0 )
				digit = log10( cachesize );
			float cacheForDisplay = 0;
			NSString *unitString = nil;
			if( digit > 9 ) {
				cacheForDisplay = cachesize / 1000000000.0f;
				unitString = @"GB";
			}
			else if( digit > 6 ) {
				cacheForDisplay = cachesize / 1000000.0f;
				unitString = @"MB";
			}
			else if( digit > 3 ) {
				cacheForDisplay = cachesize / 1000.0f;
				unitString = @"KB";
			}
			else {
				cacheForDisplay = cachesize;
				unitString = @"Byte";
			}
			InfoViewCell*cell = [cells_ objectForKey:@"CacheSizeCell"];
			//	cell.indicator.hidden = YES;
			isFinishedCheckSize_ = YES;	
			cell.attr.text = [NSString stringWithFormat:@"%.1f %@", cacheForDisplay, unitString];
			//[tableView_ performSelector:@selector(reloadData) withObject:nil afterDelay:NO];
						
			cell = [cells_ objectForKey:@"DatFileCell"];
			cell.attr.text = [NSString stringWithFormat:@"%qi", datfile_num];
		}
	}
	[pool release];
	[NSThread exit];
}

- (void) delaeteAllCacheFilesAndQuit {
	// prepare for deleting
	NSFileManager *m = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray* ary = [m subpathsOfDirectoryAtPath:documentsDirectory error:nil];
	
	// delete file
	int existingFiles = [ary count];
	int deletedFiles = 0;
	for( NSString* path in ary ) {
		NSString* targetPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
		NSError *error = nil;
		existingFiles++;
		if( [m removeItemAtPath:targetPath error:&error] ) {
			deletedFiles++;
		}
		else {
			DNSLog( @"%@ -> %@", targetPath, [error localizedDescription] );
		}
	}
	
	// confirm
	DNSLog( @"deleted file %d/existing file %d", deletedFiles, existingFiles );
	
	// refresh bbsmenu
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	[db.categoryList removeAllObjects];
	db.boardList = nil;
	[app.mainNavigationController.mainViewController reloadTable];
	
	[self reloadCacheSize];
	
}

@end
