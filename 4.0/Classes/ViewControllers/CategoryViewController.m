//
//  CategoryViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryViewToolbarController.h"
#import "SNTableViewController.h"
#import "SNDownloader.h"
#import "MainNavigationController.h"
#import "BBSMenuParser.h"
#import "InfoNaviController.h"

#import "BookmarkNavigationController.h"
#import "BoardViewController.h"
#import "StatusManager.h"

NSString* kCategoryViewCellIdentifier = @"kCategoryViewCellIdentifier";

@implementation CategoryData

@synthesize title = title_;
@synthesize categoryID = categoryID_;

- (void) dealloc {
	[title_ release];
	[super dealloc];
}

@end

@implementation CategoryViewController

#pragma mark Navigationbar Apperance Controller

- (void)showReloadButton {
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	
	UIBarButtonItem*	infoButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Info" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushInfoButton:)];
	self.navigationItem.leftBarButtonItem = infoButton;
	[infoButton release];
}

- (void)showStopButton {
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pushStopButton:)];
	self.navigationItem.rightBarButtonItem = stopButton;
	[stopButton release];
	
	self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark Push Button Selector

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushReloadButton:(id)sender {
	DNSLogMethod
	[self showStopButton];
	// bbsTableURL
	NSString* url = [[NSUserDefaults standardUserDefaults] stringForKey:@"bbsTableURL"];
	DNSLog( @"bbstable - %@", url );
	if( url == nil ) {
		url = @"http://menu.2ch.net/bbstable.html";
	}
	SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
	NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
	[downloader startWithRequest:req];
	[downloader release];
	[req release];
}

- (void)pushStopButton:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
	[self showReloadButton];
}

- (void)pushInfoButton:(id)sender {
	InfoNaviController* con = [InfoNaviController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

#pragma mark Original method

- (void) readCellData {
	[cellData_ removeAllObjects];

	const char *sql = "SELECT title, id FROM category";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char* title = (char *)sqlite3_column_text(statement, 0);
			if( title ) {
				CategoryData* data = [[CategoryData alloc] init];
				data.title = [NSString stringWithUTF8String:title];
				data.categoryID = sqlite3_column_int(statement, 1);
				[cellData_ addObject:data];
				[data release];
			}
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellData_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryViewCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCategoryViewCellIdentifier] autorelease];
    }
	CategoryData* data = [cellData_ objectAtIndex:indexPath.row];
    cell.text = data.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CategoryData* data = [cellData_ objectAtIndex:indexPath.row];
	UIAppDelegate.status.categoryTitle = data.title;
	UIAppDelegate.status.categoryID = data.categoryID;
	
	BoardViewController *con = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	[self showReloadButton];
	[BBSMenuParser parse:data];
	[self readCellData];
	[self.tableView reloadData];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	[self showReloadButton];
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
	[self showReloadButton];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		cellData_ = [[NSMutableArray alloc] init];
		toolbarController_ = [[CategoryViewToolbarController alloc] initWithDelegate:self];
		self.navigationItem.title = LocalStr( @"Category" );
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[self showReloadButton];
	[super viewWillAppear:animated];
	[UIAppDelegate.status popCategoryInfo];
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[self readCellData];
	[self.tableView reloadData];
}

#pragma mark dealloc

- (void)dealloc {
	[toolbarController_ release];
	[cellData_ release];
    [super dealloc];
}


@end
