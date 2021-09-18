//
//  InfoViewController.m
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoViewCell.h"
#import "InfoViewCellCenterTitle.h"
#import "StatusManager.h"
#import "BookmarkController.h"

NSString* kInfoViewTableDataCell = @"kInfoViewTableDataCell";
NSString* kInfoViewTableNormalCell = @"kInfoViewTableNormalCell";

@implementation InfoViewController

@synthesize tableView = tableView_;

#pragma mark -
#pragma mark For get application bundle infomation

- (id)infoValueForKey:(NSString*)key {
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

#pragma mark -
#pragma mark Original method

- (void)pushCloseButton:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) makeCells {
	cells_ = [[NSMutableDictionary dictionary] retain];
	InfoViewCell *cell;
	
	// title
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = LocalStr( @"Name" );
	cell.attributeLabel.text = [self infoValueForKey:@"CFBundleDisplayName"];
	[cells_ setObject:cell forKey:@"TitleCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
#ifdef _DEBUG
	NSString *str = [NSString stringWithFormat:@"%@(r%@) Debug", [self infoValueForKey:@"CFBundleVersion"], [self infoValueForKey:@"CFBundleRevision"]];
#else
	NSString *str = [NSString stringWithFormat:@"%@(r%@)", [self infoValueForKey:@"CFBundleVersion"], [self infoValueForKey:@"CFBundleRevision"]];
#endif		
	cell.titleLabel.text = LocalStr( @"Version" );
	cell.attributeLabel.text = str;
	[cells_ setObject:cell forKey:@"VersionCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = LocalStr( @"Copyright" );
	cell.attributeLabel.text = LocalStr( @"Rights" );
	[cells_ setObject:cell forKey:@"CopyrightCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = LocalStr( @"CacheSize" );
	cell.attributeLabel.text = LocalStr( @"Loading" );
	[cells_ setObject:cell forKey:@"CacheSizeCell"];
	[cell release];
	
	cell = [[InfoViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableDataCell];
	cell.titleLabel.text = LocalStr( @"Threads" );
	cell.attributeLabel.text = LocalStr( @"Loading" );
	[cells_ setObject:cell forKey:@"DatFileCell"];
	[cell release];
}

#pragma mark -
#pragma mark For user action, such as getting cache size, deleting cache

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
		NSString* lastComponent = [path lastPathComponent];
		NSString* targetPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
		NSDictionary* attr = [m fileAttributesAtPath:targetPath traverseLink:YES];
		NSNumber * fileSize;
		DNSLog( @"Path - %@", lastComponent );
		// other file
		if( [lastComponent isEqualToString:@"status.plist"] || [lastComponent isEqualToString:@"bookmark.plist"] || [lastComponent isEqualToString:@"2tch.sql"] ) {
		}
		else if( [lastComponent isEqualToString:@"subject.plist"] ) {
			if (fileSize = [attr objectForKey:NSFileSize]) {
				DNSLog(@"%@ - File size: %qi\n", targetPath, [fileSize unsignedLongLongValue]);
				cachesize += [fileSize unsignedLongLongValue];
			}
		}
		else if( [[lastComponent pathExtension] isEqualToString:@"plist"] ) {
			datfile_num++;
			if (fileSize = [attr objectForKey:NSFileSize]) {
				DNSLog(@"%@ - File size: %qi\n", targetPath, [fileSize unsignedLongLongValue]);
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
	//
	[UIAppDelegate openHUDOfString:LocalStr( @"Initializing..." )];
	[NSThread sleepForTimeInterval:0.5];
	
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
		NSString* lastComponent = [path lastPathComponent];
		if( [lastComponent isEqualToString:@"2tch.sql"] ) {
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
	
	[UIAppDelegate.status popCategoryInfo];
	[UIAppDelegate.bookmarkController clear];
	
	InfoViewCell*cell = [cells_ objectForKey:@"CacheSizeCell"];
	isFinishedCheckSize_ = YES;	
	cell.attributeLabel.text = [NSString stringWithFormat:@"0.0 Byte"];
	
	cell = [cells_ objectForKey:@"DatFileCell"];
	cell.attributeLabel.text = @"0";
	
	sqlite3_exec( UIAppDelegate.database, "delete from category", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "delete from board", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "delete from server", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "delete from threadInfo", NULL, NULL, NULL );
	
	[UIAppDelegate closeHUD];
}

#pragma mark -
#pragma mark Override

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	[self makeCells];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 416) style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;
	self.tableView = [tableView autorelease];
	[self.view addSubview:self.tableView];
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = LocalStr( @"Info" );
	UIBarButtonItem*closeButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Close" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
	self.navigationItem.rightBarButtonItem = closeButton;
	[closeButton release];
}

- (void)viewDidAppear:(BOOL)animated {
	[NSThread detachNewThreadSelector:@selector(checkSize) toTarget:self withObject:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSIndexPath *tableSelection = [tableView_ indexPathForSelectedRow];
	[tableView_ deselectRowAtIndexPath:tableSelection animated:YES];
	if( actionSheet == deleteCacheSheet_ ) {
		// the user clicked one of the OK/Cancel buttons
		if (buttonIndex == 0) {
			[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
			[self performSelector:@selector(delaeteAllCacheFilesAndQuit) withObject:nil afterDelay:0.0];
			//[self delaeteAllCacheFilesAndQuit];
			DNSLog(@"ok");
		}
		else {
			DNSLog(@"cancel");
		}
	}
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title;
	switch (section) {
		case 0: {
			title = LocalStr(@"Application");
			break;
		}
		case 1: {
			title = LocalStr(@"Cache");
			break;
		}
		case 2: {
			title = LocalStr(@"Cookie");
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
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:LocalStr( @"WebSiteURL" )]];
	}
	if( [indexPath section] == 1 && [indexPath row] == 2 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LocalStr( @"AreYouSureToInitialize" )
														   delegate:self
												  cancelButtonTitle:LocalStr( @"Cancel" )
											 destructiveButtonTitle:LocalStr( @"Initialize" )
												  otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
		deleteCacheSheet_ = sheet;
	}
	if( [indexPath section] == 2 && [indexPath row] == 0 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LocalStr( @"AreYouSureToDeleteCookie" )
														   delegate:self
												  cancelButtonTitle:LocalStr( @"Cancel" )
											 destructiveButtonTitle:LocalStr( @"Delete" )
												  otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
		deleteCookieSheet_ = sheet;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	InfoViewCellCenterTitle *temp = nil;
	UITableViewCell* cell = nil;
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
				cell = [tableView dequeueReusableCellWithIdentifier:kInfoViewTableNormalCell];
				if( cell == nil ) {
					cell = [[[InfoViewCellCenterTitle alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableNormalCell] autorelease];
				}
				temp = (InfoViewCellCenterTitle*)cell;
				temp.titleLabel.text = LocalStr( @"GoToWebSite" );
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
				cell = [tableView dequeueReusableCellWithIdentifier:kInfoViewTableNormalCell];
				if( cell == nil ) {
					cell = [[[InfoViewCellCenterTitle alloc] initWithFrame:CGRectZero reuseIdentifier:kInfoViewTableNormalCell] autorelease];
				}
				temp = (InfoViewCellCenterTitle*)cell;
				temp.titleLabel.text = LocalStr( @"Initialize" );
				cell = temp;
				break;
		}
	}
    return cell;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	DNSLogMethod
	[self stopBackgroundCheckSize];
	[tableView_ release];
	[cells_ release];
    [super dealloc];
}

@end
