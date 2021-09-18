//
//  BookmarkViewController.m
//  2tch
//
//  Created by sonson on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewController.h"
#import "BookmarkNavigationController.h"
#import "BookmarkViewToolbarController.h"

@interface BookmarkCellData : NSObject {
	NSString*	title_;
	NSString*	path_;
	int			res_;
	int			dat_;
	int			bookmark_id_;
	int			bookmark_key_;
	int			bookmark_kind_;
	int			res_read_;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) int res;
@property (nonatomic, assign) int dat;
@property (nonatomic, assign) int bookmark_id;
@property (nonatomic, assign) int bookmark_key;
@property (nonatomic, assign) int bookmark_kind;
@property (nonatomic, assign) int res_read;
@end

@implementation BookmarkCellData

@synthesize title = title_;
@synthesize path = path_;
@synthesize res = res_;
@synthesize dat = dat_;
@synthesize bookmark_id = bookmark_id_;
@synthesize bookmark_key = bookmark_key_;
@synthesize bookmark_kind = bookmark_kind_;
@synthesize res_read = res_read_;

- (NSComparisonResult)compare:(BookmarkCellData*)input {
	int other_num = input.bookmark_id;
	int self_num = self.bookmark_id;
	if( other_num < self_num )
		return NSOrderedDescending;
	else if( other_num > self_num )
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

- (void)display {
	DNSLog( @"%d,%d,%d-%@", bookmark_id_, bookmark_kind_, bookmark_key_, title_ );
}

- (void)dealloc {
	[path_ release];
	[title_ release];
	[super dealloc];
}

@end

@implementation BookmarkViewController

#pragma mark Original method

+ (void)deleteBookmarkAt:(BookmarkCellData*)atIndex {
	static char *sql = "delete from bookmark where id = ?;";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, atIndex.bookmark_id );
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

- (void)segmentChanged:(id)sender {
	DNSLogMethod
	UISegmentedControl* segmentController = (UISegmentedControl*)sender;
	switch ( segmentController.selectedSegmentIndex ) {
		case 0:
			currentCell_ = cell_;
			[toolbarController_ setEditEnabled:YES];
			break;
		case 1:
			currentCell_ = newCell_;
			[toolbarController_ setEditEnabled:NO];
		default:
			break;
	}
	[self.tableView reloadData];
}

- (void)showCloseButton {
	UIBarButtonItem*	closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
	self.navigationItem.rightBarButtonItem = closeButton;
	[closeButton release];
}

- (void)hideCloseButton {
	self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark Button Event

- (void)pushCheckButton:(id)sender {
	DNSLogMethod
}

- (void)pushCloseButton:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)pushEditButton:(id)sender {
	DNSLogMethod
	[toolbarController_ setBookmarkEditinglMode];
	[self hideCloseButton];
	[tableView_ setEditing:YES animated:YES];
}

- (void)pushEditDoneButton:(id)sender {
	DNSLogMethod
	[toolbarController_ setNormalMode];
	[self showCloseButton];
	[tableView_ setEditing:NO animated:YES];
}

#pragma mark Reload Cell Data

- (void) readCellData {
	DNSLogMethod
	[cell_ removeAllObjects];
	[newCell_ removeAllObjects];
	[self readCellDataOfThread];
	[self readCellDataOfBoard];
	[cell_ sortUsingSelector:@selector(compare:)];
	DNSLog( @"aa" );
	for( BookmarkCellData* d in cell_ ) {
		DNSLog( @"%@", d.title );
	}
}

- (void) readCellDataOfThread {
	const char *sql = "select bookmark.id, threadInfo.title, threadInfo.path, threadInfo.dat, threadInfo.res, threadInfo.res_read, bookmark.bookmark_key from threadInfo, bookmark where bookmark.bookmark_key = threadInfo.id and bookmark.bookmark_kind = 2;";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int bookmark_id = sqlite3_column_int( statement, 0);
			NSString* title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString* path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			int dat = sqlite3_column_int( statement, 3);
			int res = sqlite3_column_int(statement, 4);
			int res_read = sqlite3_column_int(statement, 5);
			int bookmark_key = sqlite3_column_int( statement, 6);
			BookmarkCellData *d = [[BookmarkCellData alloc] init];
			d.title = title;
			d.res = res;
			d.path = path;
			d.dat = dat;
			d.bookmark_id = bookmark_id;
			d.bookmark_key = bookmark_key;
			d.bookmark_kind = 2;
			[cell_ addObject:d];
			[d release];
			
			if( res_read < res )
				[newCell_ addObject:d];
		}
	}
	sqlite3_finalize(  statement );
}

- (void) readCellDataOfBoard {
	const char *sql = "select bookmark.id, board.title, board.path, bookmark.bookmark_key from board, bookmark where bookmark.bookmark_key = board.id and bookmark.bookmark_kind = 1;";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int bookmark_id = sqlite3_column_int( statement, 0);
			NSString* title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString* path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			int bookmark_key = sqlite3_column_int( statement, 3);
			
			BookmarkCellData *d = [[BookmarkCellData alloc] init];
			d.title = title;
			d.bookmark_id = bookmark_id;
			d.bookmark_key = bookmark_key;
			d.path = path;
			d.bookmark_kind = 1;
			[cell_ addObject:d];
			[d release];
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentCell_ count] + FIXED_ROW_NUMBER;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		BookmarkCellData *atIndex = [currentCell_ objectAtIndex:indexPath.row-1];
		[BookmarkViewController deleteBookmarkAt:atIndex];
		[self readCellData];
		
		NSArray *ary = [[NSArray alloc] initWithObjects:indexPath, nil];
		[self.tableView deleteRowsAtIndexPaths:ary withRowAnimation:UITableViewRowAnimationLeft];
		[ary release];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row >= FIXED_ROW_NUMBER ) {
		return YES;
	}
	else {
		return NO;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row < FIXED_ROW_NUMBER ) {
		UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"kBookmarkViewNormalCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"kBookmarkViewNormalCell"] autorelease];
		//	cell.hidesAccessoryWhenEditing = NO;
		}
		if( indexPath.row == 0 ) {
			[cell setText:NSLocalizedString( @"History", nil )];
		}
		return cell;
	}
	else {
		UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"kBookmarkViewCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"kBookmarkViewCell"] autorelease];
		}
		BookmarkCellData *d = [currentCell_ objectAtIndex:indexPath.row-FIXED_ROW_NUMBER];
		cell.text = d.title;
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLogMethod
	BookmarkCellData *data = [currentCell_ objectAtIndex:indexPath.row-1];
	if( data.bookmark_kind == 2 ) {
		[UIAppDelegate gotoThreadOfDat:data.dat path:data.path];
		[self dismissModalViewControllerAnimated:YES];
	}
	else if( data.bookmark_kind == 1 ) {
		[UIAppDelegate gotoBoardOfPath:data.path];
		[self dismissModalViewControllerAnimated:YES];
	}
}


#pragma mark Row reordering

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row >= FIXED_ROW_NUMBER ) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)updateBookmark {
	sqlite3_exec( UIAppDelegate.database, "delete from bookmark", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "VACUUM", NULL, NULL, NULL );
	
	sqlite3_exec( UIAppDelegate.database, "BEGIN", NULL, NULL, NULL );	
	static char *sql = "INSERT INTO bookmark (id, bookmark_key, bookmark_kind ) VALUES(NULL, ?, ? )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}
	
	for( BookmarkCellData* data in cell_ ) {
		sqlite3_bind_int( statement, 1, data.bookmark_key );
		sqlite3_bind_int( statement, 2, data.bookmark_kind );
		sqlite3_step(statement);
		sqlite3_reset(statement);
	}
	sqlite3_finalize( statement );
	sqlite3_exec( UIAppDelegate.database, "COMMIT", NULL, NULL, NULL );
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	DNSLogMethod
    if( proposedDestinationIndexPath.row < FIXED_ROW_NUMBER )
		return [NSIndexPath indexPathForRow:FIXED_ROW_NUMBER inSection:0];
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	DNSLogMethod
	
	id objectToMove = [cell_ objectAtIndex:fromIndexPath.row-1];
	[objectToMove retain];
	[cell_ removeObjectAtIndex:fromIndexPath.row-1];
	[cell_ insertObject:objectToMove atIndex:toIndexPath.row-1];
	[objectToMove release];
	[self updateBookmark];
	[self readCellData];
}

#pragma mark Original method

- (id)initWithStyle:(UITableViewStyle)style {
	DNSLogMethod
	if (self = [super initWithStyle:style]) {
		cell_ = [[NSMutableArray alloc] init];
		newCell_ = [[NSMutableArray alloc] init];
		toolbarController_ = [[BookmarkViewToolbarController alloc] initWithDelegate:self];
		currentCell_ = cell_;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[(BookmarkNavigationController*)self.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[toolbarController_ setNormalMode];
	[self showCloseButton];
	[self readCellData];
	[self.tableView reloadData];
}

- (void)dealloc {
	DNSLogMethod
	[toolbarController_ release];
	[newCell_ release];
	[cell_ release];
    [super dealloc];
}


@end
