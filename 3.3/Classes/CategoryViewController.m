//
//  CategoryViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "BoardViewController.h"
#import "SNDownloader.h"
#import "BBSMenuParser.h"
#import "StatusManager.h"
#import "CategoryViewToolbarController.h"
#import "MainNavigationController.h"
#import "BookmarkNavigationController.h"
#import "BookmarkNavigationController.h"

@implementation CategoryViewController

#pragma mark Push Button Selector

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushReloadButton:(id)sender {
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pushStopButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	
	SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
	NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:@"http://menu.2ch.net/bbstable.html"];
	[downloader startWithRequest:req];
	[downloader release];
	[req release];
}

- (void)pushStopButton:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
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
			// DNSLog( @"[MainViewController] %@ - %d", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)], sqlite3_column_int(statement, 1) );
			NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)],
								  @"title",
								  [NSNumber numberWithInt:sqlite3_column_int(statement, 1)],
								  @"id",
								  nil
								  ];
			[cellData_ addObject:dict];
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellData_ count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary* dict = [cellData_ objectAtIndex:indexPath.row];
    cell.text = [dict objectForKey:@"title"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* dict = [cellData_ objectAtIndex:indexPath.row];
	UIAppDelegate.status.categoryTitle = [dict objectForKey:@"title"];
	UIAppDelegate.status.categoryID = [[dict objectForKey:@"id"] intValue];
	
	BoardViewController *con = [[[BoardViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	[self.navigationController pushViewController:con animated:YES];
//	[con release];
}

#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	[BBSMenuParser parse:data];
	[self readCellData];
	[self.tableView reloadData];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		cellData_ = [[NSMutableArray alloc] init];
		toolbarController_ = [[CategoryViewToolbarController alloc] initWithDelegate:self];
		self.navigationItem.title = NSLocalizedString( @"Category", nil );
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[UIAppDelegate.status popCategoryInfo];
	
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	[self readCellData];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	DNSLogMethod
    [super didReceiveMemoryWarning];
	if( self.navigationController.visibleViewController != self ) {
		[cellData_ removeAllObjects];
	}
}

- (void)dealloc {
	[toolbarController_ release];
	[cellData_ release];
    [super dealloc];
}


@end
