//
//  BoardViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardViewController.h"
#import "TitleViewController.h"
#import "StatusManager.h"
#import "BoardViewToolbarController.h"
#import "MainNavigationController.h"
#import "DatParser_old.h"
#import "BookmarkNavigationController.h"

@implementation BoardViewController

#pragma mark Update Navigationbar title

- (void)updateTitle {
	NSString* title = [DatParser_old categoryTitleWithPath:UIAppDelegate.status.categoryID];
	self.navigationItem.title = title;
}

#pragma mark Push Button Selector

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		cellData_ = [[NSMutableArray alloc] init];
		toolbarController_ = [[BoardViewToolbarController alloc] initWithDelegate:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:@"updateTitle" object:nil];
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
    
    // Set up the cell...
	NSDictionary* dict = [cellData_ objectAtIndex:indexPath.row];
    cell.text = [dict objectForKey:@"title"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* dict = [cellData_ objectAtIndex:indexPath.row];
	UIAppDelegate.status.boardTitle = [dict objectForKey:@"title"];
	UIAppDelegate.status.path = [dict objectForKey:@"path"];

	TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

- (void) readCellData {
	DNSLogMethod
	[cellData_ removeAllObjects];
	const char *sql = "SELECT title, id, path FROM board where category_id = ?;";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, UIAppDelegate.status.categoryID );
		DNSLog( @"%d", UIAppDelegate.status.categoryID );
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// DNSLog( @"%@ - %d", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)], sqlite3_column_int(statement, 1) );
			NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			int board_id = sqlite3_column_int(statement, 1);
			NSString *path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
								 title,
								  @"title",
								 path,
								  @"path",
								  [NSNumber numberWithInt:board_id],
								  @"id",
								  nil
								  ];
			[cellData_ addObject:dict];
		}
	}
	sqlite3_finalize(  statement );
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[UIAppDelegate.status popBoardInfo];
	[self readCellData];
	[self.tableView reloadData];
}

- (void)dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[toolbarController_ release];
	[cellData_ release];
    [super dealloc];
}

@end

