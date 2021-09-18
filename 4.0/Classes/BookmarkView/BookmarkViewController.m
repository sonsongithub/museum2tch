//
//  BookmarkViewController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkController.h"
#import "BookmarkViewController.h"
#import "BookmarkViewToolbarController.h"
#import "MainNavigationController.h"
#import "BookmarkViewCell.h"
#import "HistoryFolderCell.h"
#import "BookmarkCellInfo.h"
#import "Crawler.h"
#import "HistoryViewController.h"
#import "SNMiniBadgeView.h"
#import "BookmarkNavigationController.h"

NSString *kBookmarkHistoryCellIdentifier = @"kBookmarkHistoryCellIdentifier";
NSString *kBookmarkViewCellIdentifier = @"kBookmarkViewCellIdentifier";

@implementation BookmarkViewController

#pragma mark Original Method

- (void)refreshAllCell {
	DNSLogMethod
	[unreadCell_ removeAllObjects];
	BookmarkController *con = UIAppDelegate.bookmarkController;
	const char *sql = "SELECT threadInfo.res, threadInfo.res_read, board.title FROM threadInfo, board where board.path = threadInfo.path and threadInfo.path = ? and threadInfo.dat = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	int i = 0;
	for( BookmarkCellInfo *data in con.list ) {
		if( data.path && data.dat ) {
			sqlite3_bind_text( statement, 1, [data.path UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int( statement, 2, data.dat );
			sqlite3_step( statement );
			
			data.number = i++;
			data.numberString = [NSString stringWithFormat:@"%03d", data.number+1];
			data.resString = [NSString stringWithFormat:@"%03d", sqlite3_column_int( statement, 0 )];
			data.readString = [NSString stringWithFormat:@"%03d", sqlite3_column_int( statement, 1 )];
			// data.boardTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			if( sqlite3_column_int( statement, 0 ) > sqlite3_column_int( statement, 1 ) ) {
				data.isUnread = YES;
				[unreadCell_ addObject:data];
			}
			else
				data.isUnread = NO;
			
			sqlite3_reset( statement );
		}
		else {
			data.number = i++;
			data.numberString = [NSString stringWithFormat:@"%03d", data.number+1];
		}
	}
	[badge_ set:[unreadCell_ count]];
	sqlite3_finalize(  statement );
}

- (void)refreshCells {
	[self refreshAllCell];
	
	BookmarkController *con = UIAppDelegate.bookmarkController;
	UISegmentedControl* segmentController = toolbarController_.segmentControll;
	switch ( segmentController.selectedSegmentIndex ) {
		case 0:
			currentCell_ = con.list;
			break;
		case 1:
			currentCell_ = unreadCell_;
			break;
		default:
			break;
	}
	
	[self.tableView reloadData];
}

- (void)switchToEditingMode {
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)switchToNormalMode {
	UIBarButtonItem* crawlButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Crawl" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCrawlButton:)];
	self.navigationItem.leftBarButtonItem = crawlButton;
	[crawlButton release];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushDoneButton:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

#pragma mark UIButton Push Event

- (void)pushCrawlButton:(id)sender {
	cralwer_.delegate = self;
	[cralwer_ show:self.view];
}

- (void)pushDoneButton:(id)sender {
	DNSLogMethod
	[self dismissModalViewControllerAnimated:YES];
}

- (void)pushEditButton:(id)sender {
	DNSLogMethod
	self.navigationItem.rightBarButtonItem = nil;
	[self.tableView setEditing:YES animated:YES];
	[toolbarController_ toggleToEditDoneButton];
	[self.tableView reloadData];
	[self switchToEditingMode];
	badge_.hidden = YES;
}

- (void)pushEditDoneButton:(id)sender {
	DNSLogMethod
	[self.tableView setEditing:NO animated:YES];
	[toolbarController_ toggleToEditButton];
	[self refreshCells];
	[self switchToNormalMode];
}

#pragma mark Original UISegment Callback

- (void)segmentChanged:(id)sender {
	DNSLogMethod
	BookmarkController *con = UIAppDelegate.bookmarkController;
	UISegmentedControl* segmentController = toolbarController_.segmentControll;
	switch ( segmentController.selectedSegmentIndex ) {
		case 0:
			currentCell_ = con.list;
			break;
		case 1:
			currentCell_ = unreadCell_;
			break;
		default:
			break;
	}
	[self.tableView reloadData];
}

#define ROWS_PER_SECTION 100

#pragma mark UITableViewDelegate, UITableViewDataSource

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;
	if( cellIndex == 0 )
		return UITableViewCellAccessoryDisclosureIndicator;
	else
		return UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;
	if( cellIndex == 0 )
		return 44;
	else
		return [BookmarkViewCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [currentCell_ count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;
	if( cellIndex == 0 ) { 
		HistoryFolderCell *cell = (HistoryFolderCell*)[tableView dequeueReusableCellWithIdentifier:kBookmarkHistoryCellIdentifier];
		if (cell == nil) {
			cell = [[[HistoryFolderCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBookmarkHistoryCellIdentifier] autorelease];
		}
		cell.text = LocalStr( @"History" );
		return cell;
	}
	else {
		BookmarkViewCell *cell = (BookmarkViewCell*)[tableView dequeueReusableCellWithIdentifier:kBookmarkViewCellIdentifier];
		if (cell == nil) {
			cell = [[[BookmarkViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBookmarkViewCellIdentifier] autorelease];
		}
		BookmarkCellInfo *data = [currentCell_ objectAtIndex:cellIndex-1];
		cell.data = data;
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;//[self indexFromIndexPath:indexPath];
	if( cellIndex == 0 ) {
		HistoryViewController* con  = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
	else {
		BookmarkCellInfo *data = [currentCell_ objectAtIndex:cellIndex-1];//[self indexFromIndexPath:indexPath]];
		
		if( data.path && data.dat ) {
			[UIAppDelegate gotoThreadOfDat:data.dat path:data.path];
			[self dismissModalViewControllerAnimated:YES];
		}
		else {
			[UIAppDelegate gotoBoardOfPath:data.path];
			[self dismissModalViewControllerAnimated:YES];
		}
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	
		[self refreshCells];
		int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row-1;
		BookmarkCellInfo *cellInfo = [currentCell_ objectAtIndex:cellIndex];
		BookmarkController *con = UIAppDelegate.bookmarkController;
		[con.list removeObjectAtIndex:cellInfo.number];
		[self refreshAllCell];
	
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;
	if( cellIndex == 0 )
		return NO;
	else
		return YES;
}

#pragma mark UITableViewDelegate, UITableViewDataSource for Reordering

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * ROWS_PER_SECTION + indexPath.row;
	if( cellIndex == 0 )
		return NO;
	else
		return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	DNSLogMethod
    if( proposedDestinationIndexPath.row < 1 )
		return [NSIndexPath indexPathForRow:1 inSection:0];
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	DNSLogMethod
	BookmarkController *con = UIAppDelegate.bookmarkController;
	int fromCellIndex = fromIndexPath.section * ROWS_PER_SECTION + fromIndexPath.row-1;
	int toCellIndex = toIndexPath.section * ROWS_PER_SECTION + toIndexPath.row-1;
	
	id objectToMove = [con.list objectAtIndex:fromCellIndex];
	[objectToMove retain];
	[con.list removeObjectAtIndex:fromCellIndex];
	[con.list insertObject:objectToMove atIndex:toCellIndex];
	[objectToMove release];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		toolbarController_ = [[BookmarkViewToolbarController alloc] initWithDelegate:self];
		unreadCell_ = [[NSMutableArray alloc] init];
		
		cralwer_ = [[Crawler alloc] init];
		badge_ = [[SNMiniBadgeView alloc] init];
		
		[UIAppDelegate.window addSubview:badge_];
		badge_.rightTop = CGPointMake( 322, 435 );
		badge_.hidden = YES;
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	self.navigationItem.title = LocalStr( @"Bookmark" );
	[self switchToNormalMode];
	[(BookmarkNavigationController*)self.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushDoneButton:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	[self refreshCells];
}

- (void)viewWillDisappear:(BOOL)animated {
	DNSLogMethod
	badge_.hidden = YES;
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[badge_ removeFromSuperview];
	[badge_ release];
	[cralwer_ release];
	[unreadCell_ release];
	[toolbarController_ release];
    [super dealloc];
}


@end

