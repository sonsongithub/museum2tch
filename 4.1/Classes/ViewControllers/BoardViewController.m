//
//  BoardViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardViewToolbarController.h"
#import "MainNavigationController.h"
#import "StatusManager.h"
#import "BookmarkNavigationController.h"
#import "BBSMenuParser.h"
#import "TitleViewController.h"

NSString *kBoardViewCellIdentifier = @"kBoardViewCellIdentifier";

@implementation BoardData
@synthesize title = title_;
@synthesize path = path_;
@synthesize boardID = boardID_;
- (void) dealloc {
	[title_ release];
	[path_ release];
	[super dealloc];
}
@end

@implementation BoardViewController

#pragma mark Original

- (void)updateTitle {
	NSString* title = [BBSMenuParser categoryTitleWithCategoryID:UIAppDelegate.status.categoryID];
	self.navigationItem.title = title;
}

- (void) readCellData {
	DNSLogMethod
	[cellData_ removeAllObjects];
	const char *sql = "SELECT title, path, id FROM board where category_id = ?;";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, UIAppDelegate.status.categoryID );
		DNSLog( @"%d", UIAppDelegate.status.categoryID );
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char* title = (char *)sqlite3_column_text(statement, 0);
			char* path = (char *)sqlite3_column_text(statement, 1);
			if( title && path ) {
				BoardData *data =[[BoardData alloc] init];
				data.title = [NSString stringWithUTF8String:title];
				data.path = [NSString stringWithUTF8String:path];
				data.boardID = sqlite3_column_int(statement, 2);
				[cellData_ addObject:data];
				[data release];
			}
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark Push Button Selector

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
}

- (void)pushSearchButton:(id)sender {
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[con pushSearchViewController];
	[self.navigationController presentModalViewController:con animated:YES];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		cellData_ = [[NSMutableArray alloc] init];
		toolbarController_ = [[BoardViewToolbarController alloc] initWithDelegate:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kUpdateTitleNotification object:nil];
		[self updateTitle];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	DNSLogMethod
    [super didReceiveMemoryWarning];
	if( self.navigationController.visibleViewController != self ) {
		[cellData_ removeAllObjects];
	}
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBoardViewCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBoardViewCellIdentifier] autorelease];
    }
    // Set up the cell...
	BoardData *data = [cellData_ objectAtIndex:indexPath.row];
    cell.text = data.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BoardData *data = [cellData_ objectAtIndex:indexPath.row];
	UIAppDelegate.status.boardTitle = data.title;
	UIAppDelegate.status.path = data.path;

	TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:con animated:YES];
	[con release];

}

#pragma mark Override

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[UIAppDelegate.status popBoardInfo];
	[self readCellData];
	[self.tableView reloadData];
	[self updateTitle];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[toolbarController_ release];
	[cellData_ release];
    [super dealloc];
}

@end

