//
//  InfoViewController.m
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "InfoViewController.h"
#import "InfoViewCell.h"
#import "global.h"

NSString* kInfoViewTableDataCell = @"kInfoViewTableDataCell";
NSString* kInfoViewTableNormalCell = @"kInfoViewTableNormalCell";

@implementation InfoViewController

@synthesize tableView = tableView_;

#pragma mark Class method

+ (InfoViewController*) defaultController {
	InfoViewController* obj = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
	
	[obj makeCells];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 416) style:UITableViewStyleGrouped];
	tableView.delegate = obj;
	tableView.dataSource = obj;
	
	obj.tableView = tableView;
	[obj.view addSubview:obj.tableView];
	
	return obj;
}

#pragma mark Original method

- (id)infoValueForKey:(NSString*)key {
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (void)pushCloseButton:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) makeCells {
	cells_ = [[NSMutableDictionary dictionary] retain];
	InfoViewCell *cell;
	
	// title
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = NSLocalizedString( @"Name", nil );
	cell.attributeLabel.text = [self infoValueForKey:@"CFBundleName"];
	[cells_ setObject:cell forKey:@"TitleCell"];
	[cell release];
	
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
#ifdef _DEBUG
	NSString *str = [NSString stringWithFormat:@"%@(r%@) Debug", [self infoValueForKey:@"CFBundleVersion"], [self infoValueForKey:@"CFBundleRevision"]];
#else
	NSString *str = [NSString stringWithFormat:@"%@(r%@)", [self infoValueForKey:@"CFBundleVersion"], [self infoValueForKey:@"CFBundleRevision"]];
#endif		
	cell.titleLabel.text = NSLocalizedString( @"Version", nil );
	cell.attributeLabel.text = str;
	[cells_ setObject:cell forKey:@"VersionCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = NSLocalizedString( @"Copyright", nil );
	cell.attributeLabel.text = NSLocalizedString( @"Rights", nil );
	[cells_ setObject:cell forKey:@"CopyrightCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = NSLocalizedString( @"CacheSize", nil );
	cell.attributeLabel.text = NSLocalizedString( @"Loading", nil );
	[cells_ setObject:cell forKey:@"CacheSizeCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = NSLocalizedString( @"Threads", nil );
	cell.attributeLabel.text = NSLocalizedString( @"Loading", nil );
	[cells_ setObject:cell forKey:@"DatFileCell"];
	[cell release];
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

- (void) checkSize {
	id pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread sleepForTimeInterval:0.75];
	
	@synchronized(self) {
		isFinishedCheckSize_ = NO;
		isTryingToStopCheckSize_ = NO;
	}
	
	NSFileManager *m = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray* ary = [m subpathsOfDirectoryAtPath:documentsDirectory error:nil];
	unsigned long long cachesize = 0;
	unsigned long long datfile_num = 0;
	for( NSString* path in ary ) {
		NSRange range = [path rangeOfString:@".dat"];
		
		if( range.location != NSNotFound ) {
			datfile_num++;
		
		NSString* targetPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
		NSDictionary* attr = [m fileAttributesAtPath:targetPath traverseLink:YES];
		NSNumber * fileSize;
		if (fileSize = [attr objectForKey:NSFileSize]) {
			// DNSLog(@"%@ - File size: %qi\n", targetPath, [fileSize unsignedLongLongValue]);
			cachesize += [fileSize unsignedLongLongValue];
		}
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
			cell.attributeLabel.text = [NSString stringWithFormat:@"%.1f %@", cacheForDisplay, unitString];
			//[tableView_ performSelector:@selector(reloadData) withObject:nil afterDelay:NO];
			
			cell = [cells_ objectForKey:@"DatFileCell"];
			cell.attributeLabel.text = [NSString stringWithFormat:@"%qi", datfile_num];
		}
	}
	[pool release];
	[NSThread exit];
}

- (void) deleteCookies {
	id storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	id cookies = [storage cookies];
	int i;
	for( i = 0; i < [cookies count]; i++ ) {
		id cookie = [cookies objectAtIndex:i];
		if( [[cookie domain] rangeOfString:@".2ch.net"].location != NSNotFound ) {
			[storage deleteCookie:cookie];
		}
	}
}

- (void) delaeteAllCacheFilesAndQuit {
	// prepare for deleting
	NSFileManager *m = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray* ary = [m subpathsOfDirectoryAtPath:documentsDirectory error:nil];
	
	[ThreadDat removeEvacuation];
	[SubjectTxt removeEvacuation];
	
	// delete file
	int existingFiles = [ary count];
	int deletedFiles = 0;
	for( NSString* path in ary ) {
		NSString* targetPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
		
		if( [path isEqualToString:@"bookmark.cache"] || [path isEqualToString:@"history.cache"] || [path isEqualToString:@"categoryList.cache"] ) {
			// save bookmaark and history file
			continue;
		}
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
	[UIAppDelegate.bbsmenu release];
	UIAppDelegate.bbsmenu = nil;
	
	[UIAppDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
	[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[UIAppDelegate.savedThread removeAllObjects];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:UIAppDelegate.savedLocation forKey:@"RestoreLocation3.2"];
	[[NSUserDefaults standardUserDefaults] setObject:UIAppDelegate.savedThread forKey:@"RestoreThread3.2"];
	
	InfoViewCell*cell = [cells_ objectForKey:@"CacheSizeCell"];
	isFinishedCheckSize_ = YES;	
	cell.attributeLabel.text = [NSString stringWithFormat:@"0.0 Byte"];
	
	cell = [cells_ objectForKey:@"DatFileCell"];
	cell.attributeLabel.text = @"0";
	
}

#pragma mark Override

- (void) viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString( @"Info", nil );
	UIBarButtonItem*closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
	self.navigationItem.rightBarButtonItem = closeButton;
	[closeButton release];
}

- (void) viewDidAppear:(BOOL)animated {
	[NSThread detachNewThreadSelector:@selector(checkSize) toTarget:self withObject:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	DNSLog( @"[InfoViewController] dealloc" );
	[self stopBackgroundCheckSize];
	[tableView_ release];
	[cells_ release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( actionSheet == deleteCookieSheet_ ) {
		// the user clicked one of the OK/Cancel buttons
		if (buttonIndex == 0) {
			[self deleteCookies];
			DNSLog(@"ok");
		}
		else {
			DNSLog(@"cancel");
		}
	}
	else if( actionSheet == deleteCacheSheet_ ) {
		// the user clicked one of the OK/Cancel buttons
		if (buttonIndex == 0) {
			[self delaeteAllCacheFilesAndQuit];
			DNSLog(@"ok");
		}
		else {
			DNSLog(@"cancel");
		}
	}
	NSIndexPath *tableSelection = [tableView_ indexPathForSelectedRow];
	[tableView_ deselectRowAtIndexPath:tableSelection animated:YES];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title;
	switch (section) {
		case 0: {
			title = NSLocalizedString(@"Application", nil);
			break;
		}
		case 1: {
			title = NSLocalizedString(@"Cache", nil);
			break;
		}
		case 2: {
			title = NSLocalizedString(@"Cookie", nil);
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
		case 2: {
			return 1;
		}
	}
	return 0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [indexPath section] == 0 && [indexPath row] == 3 ) {
		[UIApp openURL:[NSURL URLWithString:NSLocalizedString( @"GoToWebSite", nil)]];
	}
	if( [indexPath section] == 1 && [indexPath row] == 2 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToDeleteCache", nil )
														   delegate:self
												  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
											 destructiveButtonTitle:NSLocalizedString( @"Delete", nil )
												  otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
		deleteCacheSheet_ = sheet;
	}
	if( [indexPath section] == 2 && [indexPath row] == 0 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToDeleteCookie", nil )
														   delegate:self
												  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
											 destructiveButtonTitle:NSLocalizedString( @"Delete", nil )
												  otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
		deleteCookieSheet_ = sheet;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CenterTitleViewCell *temp = nil;
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kInfoViewTableNormalCell];
	if( cell == nil ) {
		cell = [[[CenterTitleViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableNormalCell] autorelease];
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
				temp = (CenterTitleViewCell*)cell;
				temp.titleLabel.text = NSLocalizedString( @"GoToWebSite", nil );
				cell = temp;
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
				temp = (CenterTitleViewCell*)cell;
				temp.titleLabel.text = NSLocalizedString( @"DeleteCache", nil );
				cell = temp;
				break;
		}
	}
	else if( [indexPath section] == 2 ) {
		switch( [indexPath row] ) {
			case 0:
				temp = (CenterTitleViewCell*)cell;
				temp.titleLabel.text = NSLocalizedString( @"DeleteCookie", nil );
				cell = temp;
				break;
		}
	}
    return cell;
}

@end
