//
//  TitleViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectParser.h"
#import "TitleViewController.h"
#import "SNDownloader.h"
#import "SubjectTxtParser.h"
#import "string-private.h"
#import "html-tool.h"
#import "ThreadViewController.h"
#import "UpdateSubjectTxtOperation.h"
#import "StatusManager.h"
#import "TitleViewToolbarController.h"
#import "MainNavigationController.h"
#import "TitleViewTerminateCell.h"
#import "DatParser_old.h"
#import "BookmarkHelper.h"
#import "BookmarkNavigationController.h"

#define ROWS_PER_SECTION 50

@implementation TitleViewController

@synthesize subjectTxtController = subjectTxtController_;
@synthesize searchQuery = searchQuery_;
@synthesize searchPrevQuery = searchPrevQuery_;
@synthesize isMultiThreading = isMultiThreading_;
@synthesize isLoading = isLoading_;

#pragma mark Update Navigationbar title

- (void)updateTitle {
	NSString* title = [DatParser_old boardTitleWithPath:UIAppDelegate.status.path];
	self.navigationItem.title = title;
}

#pragma mark SQLite helper tool

- (void)reload {
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/subject.txt' from board, server where server.id = board.server_id and board.path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);
		if (success != SQLITE_ERROR) {
			NSString* url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			DNSLog( @"%@", url );

			SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
			NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
			[downloader startWithRequest:req];
			[downloader release];
			[req release];
			
			[self showStopButton];
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark Setup NavigationControll bar

- (void)showReloadButton {
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
}

- (void)showStopButton {
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pushStopButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
}

#pragma mark Push botton method

- (void)pushReloadButton:(id)sender {
	[self showStopButton];
	[self reload];
}

- (void)pushStopButton:(id)sender {
	[self showReloadButton];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
}

- (void)pushAddButton:(id)sender {
	DNSLogMethod
	if( isMultiThreading_ ) {
		[self stopToUpdateSubjectTable];
		[BookmarkHelper insertBoardIntoBookmarkOfPath:UIAppDelegate.status.path];
		[self startToUpdateSubjectTable];
	}
	else {
		[BookmarkHelper insertBoardIntoBookmarkOfPath:UIAppDelegate.status.path];
	}
}

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushSearchButton:(id)sender {
	[toolbarController_ setCloseSearchButton];
	[self showSearchView];
//	[self reduceTableView];
}

- (void)pushCloseSearchButton:(id)sender {
	[toolbarController_ setSearchButton];
	[self hideSearchView];
	[self backTableView];
	self.searchQuery = @"";
	[allCell_ removeAllObjects];
	[newCell_ removeAllObjects];
	[cacheCell_ removeAllObjects];
}

- (void)toggleSource {
	if( currentCell_ == self.subjectTxtController.source )
		currentCell_ = self.subjectTxtController.sourceLimited;
	else if( currentCell_ == self.subjectTxtController.sourceLimited )
		currentCell_ = self.subjectTxtController.source;

	else if( currentCell_ == self.subjectTxtController.newComming )
		currentCell_ = self.subjectTxtController.newCommingLimited;
	else if( currentCell_ == self.subjectTxtController.newCommingLimited )
		currentCell_ = self.subjectTxtController.newComming;
	
	else if( currentCell_ == self.subjectTxtController.cache )
		currentCell_ = self.subjectTxtController.cacheLimited;
	else if( currentCell_ == self.subjectTxtController.cacheLimited )
		currentCell_ = self.subjectTxtController.cache;
	
	[self.tableView reloadData];
}

- (void)segmentChanged:(id)sender {
	DNSLogMethod
	DNSLog( @"%d,%d,%d", [allCell_ count], [newCell_ count], [cacheCell_ count] );
	UISegmentedControl* segmentController = (UISegmentedControl*)sender;
	
	if( !isSearching_ ) {
		switch ( segmentController.selectedSegmentIndex ) {
			case 0:
				DNSLog( @"TitleViewShowAll" );
				currentCell_ = self.subjectTxtController.source;
				break;
			case 1:
				DNSLog( @"TitleViewShowNewComming" );
				currentCell_ = self.subjectTxtController.newComming;
				break;
			case 2:
				DNSLog( @"TitleViewShowCached" );
				currentCell_ = self.subjectTxtController.cache;
				break;
			default:
				break;
		}
	}
	else {
		switch ( segmentController.selectedSegmentIndex ) {
			case 0:
				DNSLog( @"TitleViewShowAll" );
				currentCell_ = self.subjectTxtController.sourceLimited;
				break;
			case 1:
				DNSLog( @"TitleViewShowNewComming" );
				currentCell_ = self.subjectTxtController.newCommingLimited;
				break;
			case 2:
				DNSLog( @"TitleViewShowCached" );
				currentCell_ = self.subjectTxtController.cacheLimited;
				break;
			default:
				break;
		}
	}
	[self.tableView reloadData];
}

#pragma mark SearchView Management

- (void)reduceTableView {
}

- (void)backTableView {
	DNSLogMethod
	[UIView beginAnimations:@"start" context:nil];
	CGRect rect = self.tableView.frame;
	isOpenedKeyboard_ = NO;
	if( searchbar_.alpha > 0 ) {
		rect.origin.y = 44;
		rect.size.height = 328;
	}
	else {
		rect.origin.y = 0;
		rect.size.height = 372;
	}
	
	self.tableView.frame = rect;
	[UIView commitAnimations];
}

- (void)showSearchView {
	DNSLogMethod
	[UIView beginAnimations:@"start" context:nil];
	CGRect barRect = searchbar_.frame;
	barRect.size.height = 44;
	searchbar_.frame = barRect;
	searchbar_.text = @"";
	searchbar_.alpha = 1.0;
	[searchbar_ becomeFirstResponder];
	[UIView commitAnimations];
	isSearching_ = YES;
	isOpenedKeyboard_ = YES;
	[self toggleSource];
}

- (void)hideSearchView {
	[searchbar_ resignFirstResponder];
	[UIView beginAnimations:@"start" context:nil];
	CGRect barRect = searchbar_.frame;
	barRect.size.height = 0;
	searchbar_.frame = barRect;
	searchbar_.alpha = 0.0f;	
	searchbar_.text = @"";
	[UIView commitAnimations];
	isSearching_ = NO;
	[self toggleSource];
}

- (void)hideSearchItemsWithoutAnimation {
	CGRect barRect = searchbar_.frame;
	barRect.size.height = 0;
	searchbar_.frame = barRect;
	searchbar_.alpha = 0.0f;	
	searchbar_.text = @"";
	
	CGRect rect = self.tableView.frame;
	rect.origin.y = 0;
	rect.size.height = 372;
	self.tableView.frame = rect;
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	isOpenedKeyboard_ = YES;
	[UIView beginAnimations:@"start" context:nil];
	CGRect rect = self.tableView.frame;
	rect.origin.y = 44.0f;
	rect.size.height = 156;
	self.tableView.frame = rect;
	[UIView commitAnimations];
	[self.tableView reloadData];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	isOpenedKeyboard_ = NO;
	[UIView beginAnimations:@"start" context:nil];
	CGRect rect = self.tableView.frame;	rect.size.height = 328;
	self.tableView.frame = rect;
	[UIView commitAnimations];
	[self.tableView reloadData];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self hideSearchView];
	[self backTableView];
	[toolbarController_ setSearchButton];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[searchbar_ resignFirstResponder];
	[self backTableView];
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchQuery = [NSString stringWithString:searchText];
	[self.subjectTxtController limitWithKeyword:searchText];
	[self.tableView reloadData];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		toolbarController_ = [[TitleViewToolbarController alloc] initWithDelegate:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"load" object:nil];
		searchbar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,0)];
		searchbar_.showsCancelButton = YES;
		searchbar_.delegate = self;
		searchbar_.alpha = 0.0;
		self.searchPrevQuery = @"dummy";
		self.searchQuery = @"";
		[self.view addSubview:searchbar_];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:@"updateTitle" object:nil];
		[self updateTitle];
		
		titleVewShowTarget_ = TitleViewShowAll;
		currentCell_ = allCell_;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];	
	[UIAppDelegate.status popThreadInfo];
	[self showReloadButton];

	if( [self.subjectTxtController.path isEqualToString:UIAppDelegate.status.path] ) {
		DNSLog( @"Reuse" );
		[self.subjectTxtController makeCacheAndNewCommingData];
		if( searchbar_.text != nil )
			[self.subjectTxtController limitWithKeyword:searchbar_.text];
		[self.tableView reloadData];
	}
	else {
		DNSLog( @"Make new SubjectTxtController" );		
		self.subjectTxtController = [[SubjectTxtController alloc] initWithPath:UIAppDelegate.status.path];
		[self.subjectTxtController release];
		currentCell_ = self.subjectTxtController.source;
		
		if( isSearching_ ) {
			[self hideSearchItemsWithoutAnimation];
			isSearching_ = NO;
			isOpenedKeyboard_ = NO;
			[toolbarController_ setSearchButton];
		}
		
		if( [self.subjectTxtController.source count] > 0 ) {
			DNSLog( @"subjectTxtController" );
			[self.tableView reloadData];
		}
		else {
			[self reload];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	if( isSearching_ == NO ) {
		[searchbar_ resignFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
}

- (void)didReceiveMemoryWarning {
	DNSLogMethod
    [super didReceiveMemoryWarning];
	if( self.navigationController.visibleViewController != self ) {
	}
}

#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	[self.subjectTxtController.source removeAllObjects];
	[SubjectParser parse:data appendTarget:self.subjectTxtController.source];
	
	
	
	switch ( toolbarController_.segmentControll.selectedSegmentIndex ) {
		case 0:
			DNSLog( @"TitleViewShowAll" );
			currentCell_ = self.subjectTxtController.source;
			break;
		case 1:
			DNSLog( @"TitleViewShowNewComming" );
			currentCell_ = self.subjectTxtController.newComming;
			break;
		case 2:
			DNSLog( @"TitleViewShowCached" );
			currentCell_ = self.subjectTxtController.cache;
			break;
		default:
			break;
	}
	[self.subjectTxtController makeCacheAndNewCommingData];
	
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

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( isOpenedKeyboard_ )
		return 30;
	else
		return 44;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	DNSLogMethod
	NSMutableArray *ary = [NSMutableArray array];
	int i;
	for( i = 0; i <= [currentCell_ count] / ROWS_PER_SECTION; i++ ) {
		if( i % 2 == 0 )
			[ary addObject:[NSString stringWithFormat:@"%d",i*ROWS_PER_SECTION+1]];
		else
			[ary addObject:[NSString stringWithFormat:@"●"]];
	}
	return ary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int sections = [currentCell_ count] % ROWS_PER_SECTION == 0 ? [currentCell_ count] / ROWS_PER_SECTION : [currentCell_ count] / ROWS_PER_SECTION + 1;
	DNSLog( @"%d->%d", [currentCell_ count], sections );
	if( sections == 0)
		return 1;
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int sections = [currentCell_ count] % ROWS_PER_SECTION == 0 ? [currentCell_ count] / ROWS_PER_SECTION : [currentCell_ count] / ROWS_PER_SECTION + 1;
	
	if( [currentCell_ count] == 0 )
		return 0;
	
	if( section < sections-1 )
		return ROWS_PER_SECTION;
	else if( [currentCell_ count] % ROWS_PER_SECTION == 0 )
		return ROWS_PER_SECTION + 1;
	else
		return [currentCell_ count] % ROWS_PER_SECTION;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"%d - ", section*ROWS_PER_SECTION+1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	if( [currentCell_ count] > indexPath.section * ROWS_PER_SECTION + indexPath.row) {
		SubjectData *data = [currentCell_ objectAtIndex:indexPath.section * ROWS_PER_SECTION + indexPath.row];
		cell.text = data.title;
		if( isOpenedKeyboard_ ) {
			cell.backgroundColor = [UIColor grayColor];
			cell.font = [UIFont boldSystemFontOfSize:12];
		}
		else {
			cell.backgroundColor = [UIColor whiteColor];
			cell.font = [UIFont boldSystemFontOfSize:20];
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLogMethod	
	if( indexPath.section * ROWS_PER_SECTION + indexPath.row > [allCell_ count]-1 )
		return;
	
	SubjectData *data = [currentCell_ objectAtIndex:indexPath.section * ROWS_PER_SECTION + indexPath.row];
	ThreadViewController* con = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
	con.candidateDat = data.dat;
	con.candidatePath = UIAppDelegate.status.path;
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[subjectTxtController_ release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[searchPrevQuery_ release];
	[searchQuery_ release];
	[searchbar_ release];
	[toolbarController_ release];
    [super dealloc];
}

@end

