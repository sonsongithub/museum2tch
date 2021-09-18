//
//  HistoryViewController.m
//  2tch
//
//  Created by sonson on 08/12/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryViewToolbarController.h"
#import "BookmarkCellInfo.h"
#import "BookmarkViewCell.h"
#import "BookmarkNavigationController.h"
#import "MainNavigationController.h"
#import "ThreadViewController.h"
#import "Dat.h"
#import "HistoryController.h"

NSString *kHistoryViewCellIdentifier = @"kHistoryViewCellIdentifier";

@implementation HistoryViewController

@synthesize toolbarController = toolbarController_;

#pragma mark -
#pragma mark Class method, check current topViewcontroller when deleting the thread.

+ (void)checkCurrentThreadViewWithPath:(NSString*)path dat:(int)dat {
	MainNavigationController* navi = UIAppDelegate.navigationController;
	UIViewController* top = [navi topViewController];
	if( [top isKindOfClass:[ThreadViewController class]] ) {
		ThreadViewController* threadViewCon = (ThreadViewController*)top;
		if( threadViewCon.threadDat.dat == dat && [threadViewCon.threadDat.path isEqualToString:path] ) {
			[navi popViewControllerAnimated:NO];
		}
	}
	else {
	}
}

+ (void)checkCurrentThread{
	MainNavigationController* navi = UIAppDelegate.navigationController;
	UIViewController* top = [navi topViewController];
	if( [top isKindOfClass:[ThreadViewController class]] ) {
		[navi popViewControllerAnimated:NO];
	}
	else {
	}
}

#pragma mark -
#pragma mark Class method, delete all cache from threadInfo, or selected cache by user.

+ (void)deleteAllCache {
	DNSLogMethod
	const char *sql = "select path, dat FROM threadInfo";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	else {
		while( sqlite3_step( statement ) == SQLITE_ROW ) {
			char* path_source = (char *)sqlite3_column_text(statement, 0);
			if( path_source ) {
				NSString* path = [NSString stringWithUTF8String:path_source];
				int dat = sqlite3_column_int( statement, 1 );
				[HistoryViewController deleteThreadDatDataWithPath:path dat:dat];
			}
		}
	}
	sqlite3_finalize( statement );
	sqlite3_exec( UIAppDelegate.database, "delete from threadInfo", NULL, NULL, NULL );
}

+ (void)deleteThreadInfoAndCacheWithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	const char *sql = "delete FROM threadInfo where path = ? and dat = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	else {
		sqlite3_bind_text( statement, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 2, dat );
		sqlite3_step( statement );
	}
	sqlite3_finalize( statement );
}

+ (void)deleteThreadDatDataWithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%d.plist", DocumentFolderPath, path, dat];
	[[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
}

+ (void)deleteInvalidHistoryData {
}

#pragma mark -
#pragma mark UIButton Push Botton

- (void)pushDeleteButton:(id)sender {
	DNSLogMethod
	deleteAllSheet_ = [[UIActionSheet alloc] initWithTitle:LocalStr( @"DeleteAllCache?" ) 
												  delegate:self 
										 cancelButtonTitle:LocalStr( @"Cancel" )
									destructiveButtonTitle:LocalStr( @"Delete" )
										 otherButtonTitles:nil];
	[deleteAllSheet_ showInView:self.view];
	[deleteAllSheet_ release];
}

- (void)pushDoneButton:(id)sender {
	DNSLogMethod
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Fetch all history data

- (void)refreshAllCell {
	DNSLogMethod
	BOOL errorFound = NO;
	[cellInfo_ removeAllObjects];
	const char *sql = "SELECT threadInfo.title, threadInfo.res, threadInfo.res_read, board.title, threadInfo.path, threadInfo.dat FROM threadInfo, board where board.path = threadInfo.path order by date desc";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	else {
		int i = 0;
		while( sqlite3_step( statement ) == SQLITE_ROW ) {
			char* title = (char *)sqlite3_column_text(statement, 0);
			char* boardTitle = (char *)sqlite3_column_text(statement, 3);
			char* path = (char *)sqlite3_column_text(statement, 4);
			if( title && boardTitle && path ) {
				BookmarkCellInfo *info = [[BookmarkCellInfo alloc] init];
				[cellInfo_ addObject:info];
				info.number = i++;
				info.numberString = [NSString stringWithFormat:@"%03d", info.number + 1];
				info.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				info.resString = [NSString stringWithFormat:@"%03d", sqlite3_column_int( statement, 1 )];
				info.readString = [NSString stringWithFormat:@"%03d", sqlite3_column_int( statement, 2 )];
				info.boardTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				info.path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
				info.dat = sqlite3_column_int( statement, 5 );
				if( sqlite3_column_int( statement, 1 ) > sqlite3_column_int( statement, 2 ) )
					info.isUnread = YES;
				else
					info.isUnread = NO;
				[info release];
			}
			else {
				errorFound = YES;
			}
		}
	}
	sqlite3_finalize( statement );
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [BookmarkViewCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [cellInfo_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * 0 + indexPath.row;//[self indexFromIndexPath:indexPath];

	BookmarkViewCell *cell = (BookmarkViewCell*)[tableView dequeueReusableCellWithIdentifier:kHistoryViewCellIdentifier];
	if (cell == nil) {
		cell = [[[BookmarkViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kHistoryViewCellIdentifier] autorelease];
	}
	BookmarkCellInfo *data = [cellInfo_ objectAtIndex:cellIndex];
	cell.data = data;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.section * 0 + indexPath.row;
	BookmarkCellInfo *data = [cellInfo_ objectAtIndex:cellIndex];
	if( data.path && data.dat ) {
		[UIAppDelegate gotoThreadOfDat:data.dat path:data.path];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLogMethod
	cellToDelete_ = indexPath.section * 0 + indexPath.row;
	deleteAnItemSheet_ = [[UIActionSheet alloc] initWithTitle:LocalStr( @"DeleteACache?" )
												  delegate:self 
										 cancelButtonTitle:LocalStr( @"Cancel" )
									destructiveButtonTitle:LocalStr( @"Delete" )
										 otherButtonTitles:nil];
	[deleteAnItemSheet_ showInView:self.view];
	[deleteAnItemSheet_ release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DNSLogMethod
	DNSLog( @"%d", buttonIndex );
	
	if( actionSheet == deleteAllSheet_ && buttonIndex == 0 ) {
		[HistoryViewController checkCurrentThread];
		[HistoryViewController deleteAllCache];
		[UIAppDelegate.historyController clearEntries];
		[self refreshAllCell];
		[self.tableView reloadData];
	}
	else if( actionSheet == deleteAnItemSheet_ && buttonIndex == 0 && cellToDelete_ >= 0 && cellToDelete_ < [cellInfo_ count] ) {
	//	[self.tableView beginUpdates];
	//	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:cellToDelete_ inSection:0];
	//	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	//	[self.tableView endUpdates];
		BookmarkCellInfo *data = [cellInfo_ objectAtIndex:cellToDelete_];
		DNSLog( @"%@,%d", data.path, data.dat );
		
		[HistoryViewController checkCurrentThreadViewWithPath:data.path dat:data.dat];
		
		[HistoryViewController deleteThreadInfoAndCacheWithPath:data.path dat:data.dat];
		[HistoryViewController deleteThreadDatDataWithPath:data.path dat:data.dat];
		[UIAppDelegate.historyController deleteEntry:data.path dat:data.dat];
		[self refreshAllCell];
		[self.tableView reloadData];
	}
	cellToDelete_ = -1;
}

#pragma mark -
#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		self.toolbarController = [[HistoryViewToolbarController alloc] initWithDelegate:self];
		[self.toolbarController release];
		cellInfo_ = [[NSMutableArray alloc] init];
		cellToDelete_ = -1;
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	
	self.navigationItem.title = LocalStr( @"History" );
	[self.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[self refreshAllCell];
	[self.tableView reloadData];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushDoneButton:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[toolbarController_ release];
	[cellInfo_ release];
	[super dealloc];
}

@end
