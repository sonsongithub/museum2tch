//
//  TitleViewController.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleViewController.h"
#import "TitleViewToolbarController.h"
#import "SNDownloader.h"
#import "StatusManager.h"
#import "MainNavigationController.h"
#import "SubjectTxt.h"
#import "SubjectParser.h"
#import "SubjectData.h"
#import "TitleCell.h"
#import "ThreadViewController.h"
#import "BookmarkController.h"
#import "BookmarkNavigationController.h"

#define ROWS_PER_SECTION 100

NSString* kShowSearchBarTitleView = @"kShowSearchBarTitleView";
NSString* kHideSearchBarTitleView = @"kHideSearchBarTitleView";
NSString* kReduceTableViewToShowSearchBarTitleView = @"kReduceTableViewToShowSearchBarTitleView";
NSString* kExpandTableViewToCloseKeyboardTitleView = @"kExpandTableViewToCloseKeyboardTitleView";
NSString* kExpandTableViewToCloseSearchBarTitleView = @"kExpandTableViewToCloseSearchBarTitleView";
NSString* kTitleViewCellIdentifier = @"kTitleViewCellIdentifier";

@implementation TitleViewController

@synthesize subjectTxt = subjectTxt_;

#pragma mark Reloading

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
			char *url_source = (char *)sqlite3_column_text(statement, 0);
			if( url_source ) {
				NSString* url = [NSString stringWithUTF8String:url_source];
				DNSLog( @"%@", url );
				
				SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
				NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
				[downloader startWithRequest:req];
				[downloader release];
				[req release];
			}
		}
	}
	sqlite3_finalize(  statement );
}

#pragma mark Setup NavigationControll bar

- (void)updateTitle {
	NSString *title = [SubjectTxt boardTitleWithPath:UIAppDelegate.status.path];
	self.navigationItem.title = title;
}

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
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
}

- (void)pushAddButton:(id)sender {
	DNSLogMethod
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LocalStr( @"Bookmark this board?" )
												  delegate:self 
										 cancelButtonTitle:LocalStr( @"Cancel" )
									destructiveButtonTitle:nil
										 otherButtonTitles:LocalStr( @"OK" ), nil];
	[sheet showInView:self.view];
	[sheet release];
}

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushSearchButton:(id)sender {
	[searchbar_ becomeFirstResponder];
	[self reduceTableViewToShowSearchBar:YES];
	[toolbarController_ setCloseSearchButton];
	isSearching_ = YES;
	[self changeShownCell];
}

- (void)pushCloseSearchButton:(id)sender {
	[toolbarController_ setSearchButton];
	[self expandTableViewToCloseSearchBar:YES];
	isSearching_ = NO;
	[self changeShownCell];
}

#pragma mark Cell Resource Management

- (void)changeShownCell {
	DNSLogMethod
	UISegmentedControl* segmentController = toolbarController_.segmentControll;
	if( !isSearching_ ) {
		switch ( segmentController.selectedSegmentIndex ) {
			case 0:
				DNSLog( @"TitleViewShowAll" );
				currentCell_ = self.subjectTxt.source;
				break;
			case 1:
				DNSLog( @"TitleViewShowCached" );
				currentCell_ = self.subjectTxt.cache;
				break;
			default:
				break;
		}
	}
	else {
		switch ( segmentController.selectedSegmentIndex ) {
			case 0:
				DNSLog( @"TitleViewShowAll" );
				currentCell_ = self.subjectTxt.sourceLimited;
				break;
			case 1:
				
				DNSLog( @"TitleViewShowCached" );
				currentCell_ = self.subjectTxt.cacheLimited;
				break;
			default:
				break;
		}
	}
	[self.tableView reloadData];
}

#pragma mark UISegmentation Coallback

- (void)segmentChanged:(id)sender {
	DNSLogMethod
	[self changeShownCell];
}

#pragma mark IndexPath Management

- (int)indexFromIndexPath:(NSIndexPath *)indexPath {
	int sections = [currentCell_ count] % ROWS_PER_SECTION <= 1 ? [currentCell_ count] / ROWS_PER_SECTION + 1 : [currentCell_ count] / ROWS_PER_SECTION + 2;
	
	if( [currentCell_ count] % ROWS_PER_SECTION < 1 ) {
		if( indexPath.section == sections - 1 )
			return [currentCell_ count] - 1;
		else
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
	}
	else {
		if( indexPath.section == sections - 1 )
			return [currentCell_ count] - 1;
		else if( indexPath.section == sections - 2 )
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
		else
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
	}	
}

#pragma mark SearchView Management

- (void)reduceTableViewToShowSearchBar:(BOOL)animated {
	DNSLogMethod
	if( animated )
		[UIView beginAnimations:kReduceTableViewToShowSearchBarTitleView context:nil];
	
	CGRect rect = self.tableView.frame;
	rect.origin.y = 44;
	rect.size.height = 156;
	self.tableView.frame = rect;
	rect = searchbar_.frame;
	rect.size.height = 44;
	searchbar_.frame = rect;
	searchbar_.alpha = 1.0;
	
	if( animated )
		[UIView commitAnimations];
}

- (void)expandTableViewToCloseKeyboard:(BOOL)animated {
	DNSLogMethod
	if( animated )
		[UIView beginAnimations:kExpandTableViewToCloseKeyboardTitleView context:nil];
	
	CGRect rect = self.tableView.frame;
	rect.origin.y = 44.0f;
	rect.size.height = 328;
	self.tableView.frame = rect;
	
	if( animated )
		[UIView commitAnimations];
}

- (void)expandTableViewToCloseSearchBar:(BOOL)animated {
	DNSLogMethod
	if( animated )
		[UIView beginAnimations:kExpandTableViewToCloseSearchBarTitleView context:nil];
	
	CGRect rect = self.tableView.frame;
	rect.origin.y = 0;
	rect.size.height = 372;
	self.tableView.frame = rect;
	rect = searchbar_.frame;
	rect.size.height = 0;
	searchbar_.frame = rect;
	searchbar_.alpha = 0.0;
	
	if( animated )
		[UIView commitAnimations];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DNSLogMethod
	DNSLog( @"%d", buttonIndex );
	if( buttonIndex == 0 ) {
		BookmarkController* con = UIAppDelegate.bookmarkController;
		[con addBookmarkOfBoardWithPath:self.subjectTxt.path title:[SubjectTxt boardTitleWithPath:self.subjectTxt.path]];
	}
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	[self reduceTableViewToShowSearchBar:YES];
	[self.tableView reloadData];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[self expandTableViewToCloseSearchBar:YES];
	[toolbarController_ setSearchButton];
	[searchbar_ resignFirstResponder];
	isSearching_ = NO;
	[self changeShownCell];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[self expandTableViewToCloseKeyboard:YES];
	[searchbar_ resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DNSLogMethod
	[self.subjectTxt limitWithKeyword:searchText];
	isSearching_ = YES;
	[self.tableView reloadData];
}

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		toolbarController_ = [[TitleViewToolbarController alloc] initWithDelegate:self];
		searchbar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,0)];
		searchbar_.showsCancelButton = YES;
		searchbar_.delegate = self;
		searchbar_.alpha = 0.0;
		[self.view addSubview:searchbar_];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kUpdateTitleNotification object:nil];
		isSearching_ = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];	
	[UIAppDelegate.status popThreadInfo];
	
	[self updateTitle];
	
	if( self.subjectTxt == nil ) {
		// make new
		self.subjectTxt = [[SubjectTxt alloc] initWithPath:UIAppDelegate.status.path];
		[self.subjectTxt release];
		currentCell_ = self.subjectTxt.source;
		[self.tableView reloadData];
	}
	else if( ![self.subjectTxt.path isEqualToString:UIAppDelegate.status.path] ) {
		// path has changed
		self.subjectTxt = [[SubjectTxt alloc] initWithPath:UIAppDelegate.status.path];
		[self.subjectTxt release];
		currentCell_ = self.subjectTxt.source;
		[self.tableView reloadData];
	}
	else {
		[self.subjectTxt makeCacheAndNewCommingData];
	}
	
	if( ![self.subjectTxt hasData] ) {
		[self reload];
	}
	
	[self showReloadButton];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
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
	if( self.subjectTxt != nil ) {
		[self.subjectTxt.source removeAllObjects];
		[SubjectParser parse:data appendTarget:self.subjectTxt.source];
		[self.subjectTxt write];
	//	currentCell_ = self.subjectTxt.source;
		[self.subjectTxt makeCacheAndNewCommingData];
		
		if( [searchbar_.text length] > 0 && searchbar_.alpha > 0.0 )
			[self.subjectTxt limitWithKeyword:searchbar_.text];
		
		[self.tableView reloadData];
	}
	[self showReloadButton];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	[self showReloadButton];
}

- (void) didDifferenctURLLoading {	
	DNSLogMethod
	[self showReloadButton];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [TitleCell height];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	DNSLogMethod
	NSMutableArray *ary = [NSMutableArray array];
	int i;
	
	int sections = [currentCell_ count] % ROWS_PER_SECTION <= 1 ? [currentCell_ count] / ROWS_PER_SECTION + 1 : [currentCell_ count] / ROWS_PER_SECTION + 2;
	
	for( i = 0; i < sections; i++ ) {
		if( i != sections - 1 )
			[ary addObject:[NSString stringWithFormat:@"%d",i*ROWS_PER_SECTION+1]];
		else
			[ary addObject:[NSString stringWithFormat:@"%d",[currentCell_ count]]];
	}
	return ary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int sections = [currentCell_ count] % ROWS_PER_SECTION <= 1 ? [currentCell_ count] / ROWS_PER_SECTION + 1 : [currentCell_ count] / ROWS_PER_SECTION + 2;
	if( sections == 0)
		return 1;
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int sections = [currentCell_ count] % ROWS_PER_SECTION <= 1 ? [currentCell_ count] / ROWS_PER_SECTION + 1 : [currentCell_ count] / ROWS_PER_SECTION + 2;
	
	if( [currentCell_ count] == 0 )
		return 0;
	
	if( [currentCell_ count] % ROWS_PER_SECTION == 1 ) {
		if( section == sections - 1 )
			return 1;
		else
			return ROWS_PER_SECTION;
	}
	else {
		if( section == sections - 1 )
			return 1;
		else if( section == sections - 2 )
			return ([currentCell_ count] % ROWS_PER_SECTION !=0 ? [currentCell_ count] % ROWS_PER_SECTION : ROWS_PER_SECTION )- 1;
		else
			return ROWS_PER_SECTION;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	int sections = [currentCell_ count] % ROWS_PER_SECTION <= 1 ? [currentCell_ count] / ROWS_PER_SECTION + 1 : [currentCell_ count] / ROWS_PER_SECTION + 2;
	if( section != sections - 1 )
		return [NSString stringWithFormat:@"%d -",section*ROWS_PER_SECTION+1];
	else
		return [NSString stringWithFormat:@"%d",[currentCell_ count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TitleCell *cell = (TitleCell*)[tableView dequeueReusableCellWithIdentifier:kTitleViewCellIdentifier];
	if (cell == nil) {
		cell = [[[TitleCell alloc] initWithFrame:CGRectZero reuseIdentifier:kTitleViewCellIdentifier] autorelease];
	}
	
	SubjectData *data = [currentCell_ objectAtIndex:[self indexFromIndexPath:indexPath]];
	cell.data = data;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLogMethod
	SubjectData *data = [currentCell_ objectAtIndex:[self indexFromIndexPath:indexPath]];
	DNSLog( @"%@", data.title );
	
	ThreadViewController* con = [[ThreadViewController alloc] initWithStyle:UITableViewStylePlain];
	con.candidateDat = data.dat;
	con.candidatePath = UIAppDelegate.status.path;
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[subjectTxt_ release];
	[searchbar_ release];
	[toolbarController_ release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

