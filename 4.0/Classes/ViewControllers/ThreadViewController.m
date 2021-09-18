//
//  RootViewController.m
//  scroller
//
//  Created by sonson on 08/12/15.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "ThreadViewController.h"
#import "ThreadCell.h"
#import "DatParser.h"
#import "ThreadResData.h"
#import "ThreadLayoutComponent.h"
#import "AnchorPopupViewController.h"
#import "AsciiPopupViewController.h"
#import "ThreadViewToolbarController.h"
#import "MainNavigationController.h"
#import "SNDownloader.h"
#import "StatusManager.h"
#import "Dat.h"
#import "SNWebBrowser.h"
#import "HistoryController.h"
#import "ReplyNavigationController.h"
#import "BookmarkController.h"
#import "BookmarkNavigationController.h"
#import "PopupLabel.h"
#import "ReplyViewController.h"
#import "ThreadDatParser.h"

NSString* kShowSearchBarThreadView = @"kShowSearchBarThreadView";
NSString* kHideSearchBarThreadView = @"kHideSearchBarThreadView";
NSString* kReduceTableViewToShowSearchBarThreadView = @"kReduceTableViewToShowSearchBarThreadView";
NSString* kExpandTableViewToCloseKeyboardThreadView = @"kExpandTableViewToCloseKeyboardThreadView";
NSString* kExpandTableViewToCloseSearchBarThreadView = @"kExpandTableViewToCloseSearchBarThreadView";
NSString* kThreadViewCellIdentifier = @"kThreadViewCellIdentifier";

#define ROWS_PER_SECTION 100

@implementation ThreadViewController

@synthesize candidatePath = candidatePath_;
@synthesize candidateDat = candidateDat_;
@synthesize threadDat = threadDat_;
@synthesize candidateThreadDat = candidateThreadDat_;

#pragma mark Push botton method

- (void)pushComposeButton:(id)sender {
	int i;
	NSMutableString *anchorString = [NSMutableString string];
	
	for( i = 0; i < [threadDat_.resList count]; i++ ) {
		ThreadResData *data = [threadDat_.resList objectAtIndex:i];
		if( data.isSelected ) {
			[anchorString appendFormat:@">>%d\n", i + 1];
			data.isSelected = NO;
		}
	}
	
	ReplyNavigationController* con = [ReplyNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	
	if( [con.visibleViewController respondsToSelector:@selector(setAnchor:)] ) {
		[(ReplyViewController*)con.visibleViewController setAnchor:anchorString];
	}
	
	[con release];
}

- (void)pushReloadButton:(id)sender {
	[self showStopButton];
	self.candidateDat = self.threadDat.dat;
	self.candidatePath = self.threadDat.path;
	self.candidateThreadDat = self.threadDat;
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void)pushStopButton:(id)sender {
	[self showReloadButton];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
}

- (void)pushAddButton:(id)sender {
	DNSLogMethod
	if( self.threadDat.path != nil && self.threadDat.dat != 0 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LocalStr( @"Bookmark this thread?" ) 
														   delegate:self
												  cancelButtonTitle:LocalStr( @"Cancel" )
											 destructiveButtonTitle:nil
												  otherButtonTitles:LocalStr( @"OK" ), nil];
		[sheet showInView:self.view];
		[sheet release];
	}
}

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushBackButton:(id)sender {
	DNSLogMethod
	[self pushCloseSearchButton:nil];
	NSDictionary* threadInfo = [UIAppDelegate.historyController goBack];
	[self loadThreadWithoutAddingHistory:threadInfo];
}

- (void)pushForwardButton:(id)sender {
	DNSLogMethod
	[self pushCloseSearchButton:nil];
	NSDictionary* threadInfo = [UIAppDelegate.historyController goForward];
	[self loadThreadWithoutAddingHistory:threadInfo];
}

#pragma mark Setup NavigationControll bar

- (void) updateTitle {
	DNSLogMethod
	titleLabel_.text = self.threadDat.title;
	CGRect titleRect = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 44) limitedToNumberOfLines:1];
	DNSLog( @"normal->%f,%f", titleRect.size.width, titleRect.size.height );
	if( titleRect.size.width > 180 ) {
		titleLabel_.font = [UIFont boldSystemFontOfSize:12.0f];
		titleLabel_.numberOfLines = 2;
		[titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 44) limitedToNumberOfLines:2];
	//	DNSLog( @"revised->%f,%f", titleRectRevised.size.width, titleRectRevised.size.height );
	}
	self.navigationItem.titleView = titleLabel_;
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

#pragma mark Method to load, set up thread data

- (void)tryToOpen {
	DNSLogMethod
	if( self.threadDat.dat == self.candidateDat && [self.threadDat.path isEqualToString:self.candidatePath] ) {
		[self updateTitle];
	}
	else {
		self.candidateThreadDat = [[Dat alloc] initWithDat:self.candidateDat path:self.candidatePath];
		[self.candidateThreadDat release];
		[self tryToStartDownloadThreadWithCandidateThreadInfo];
	}
}

- (void)tryToStartDownloadThreadWithCandidateThreadInfo {	
	DNSLogMethod
	if( [self.candidateThreadDat.resList count] > 999 ) {
		// already 1001 loaded
		[self setCandidateData];
		[self showReloadButton];
	}
	else if( self.candidateThreadDat.bytes > 0 ) {
		[self downloadResumeWithByte:self.candidateThreadDat.bytes lastModified:self.candidateThreadDat.lastModified];
	}
	else {
		[self downloadNewDat];
	}
}

- (void)setCandidateData {
	// check whether new thread data is available
	if( [self.candidateThreadDat hasData] ) {
		self.threadDat = self.candidateThreadDat;

		if( [searchbar_.text length] > 0 && searchbar_.alpha > 0 ) {
			[self searchWithText:searchbar_.text];
			currentArray_ = searchedArray_;
		}
		else {
			currentArray_ = self.threadDat.resList;
		}
		self.candidateThreadDat = nil;
		[self.tableView reloadData];
		float offset = [Dat lastOffsetWithPath:self.threadDat.path dat:self.threadDat.dat];
		//DNSLog( @"%f,%f", offset, self.tableView.contentSize.height );
		//if( offset > self.tableView.contentSize.height ) {
			self.tableView.contentOffset = CGPointMake( 0, offset );
		//}
		[UIAppDelegate.historyController insertNewThreadInfoWithPath:self.threadDat.path dat:self.threadDat.dat];
		UIAppDelegate.status.dat = self.threadDat.dat;
		UIAppDelegate.status.path = self.threadDat.path;
		[Dat updateLastOffset:offset path:self.threadDat.path dat:self.threadDat.dat res_read:[self.threadDat.resList count]];
	}
	else {
		self.candidateThreadDat = nil;
	}
	[self updateTitle];
	[toolbarController_ updateBackButton:[UIAppDelegate.historyController canGoBack] forwardButton:[UIAppDelegate.historyController canGoForward]];
}

- (void)loadThreadWithoutAddingHistory:(NSDictionary*)threadInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
	
	self.candidateThreadDat = [[Dat alloc] initWithDat:[[threadInfo objectForKey:@"dat"] intValue] path:[threadInfo objectForKey:@"path"]];
	[self.candidateThreadDat release];
	// check whether new thread data is available
	if( [self.candidateThreadDat hasData] ) {
		self.threadDat = self.candidateThreadDat;
		currentArray_ = self.threadDat.resList;
		self.candidateThreadDat = nil;
		[self.tableView reloadData];
		
		CGPoint offset = CGPointMake( 0, [Dat lastOffsetWithPath:self.threadDat.path dat:self.threadDat.dat] );
		self.tableView.contentOffset = offset;
		
		UIAppDelegate.status.dat = self.threadDat.dat;
		UIAppDelegate.status.path = self.threadDat.path;
	}
	else {
		self.candidateThreadDat = nil;
	}
	[toolbarController_ updateBackButton:[UIAppDelegate.historyController canGoBack] forwardButton:[UIAppDelegate.historyController canGoForward]];
}

- (void)searchWithText:(NSString*)text {
	[searchedArray_ removeAllObjects];
	for( ThreadResData* threadResData in self.threadDat.resList ) {
		for( ThreadLayoutComponent* component in threadResData.body ) {
			if( [component.text rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
				[searchedArray_ addObject:threadResData];
				break;
			}
		}
	}
}

#pragma mark Save scroll amount

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	DNSLogMethod
	CGPoint offset = self.tableView.contentOffset;
	if( self.threadDat ) {
		//		[Dat updateLastOffset:offset.y path:self.threadDat.path dat:self.threadDat.dat];
		[Dat updateLastOffset:offset.y path:self.threadDat.path dat:self.threadDat.dat res_read:[self.threadDat.resList count]];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	DNSLogMethod
	CGPoint offset = self.tableView.contentOffset;
	if( self.threadDat ) {
		//[Dat updateLastOffset:offset.y path:self.threadDat.path dat:self.threadDat.dat];
		[Dat updateLastOffset:offset.y path:self.threadDat.path dat:self.threadDat.dat res_read:[self.threadDat.resList count]];
	}
}

#pragma mark Open new thread, external site and anchor

- (void)openWebBrowser:(NSString*)url {
	DNSLogMethod
	SNWebBrowser* con = [[SNWebBrowser alloc] initWithoutRootViewController];
	[con openURLString:url];
	[self presentModalViewController:con animated:YES];
	[con release];
}

- (void)open2chLinkwithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	[self searchBarCancelButtonClicked:searchbar_];
	[anchorPopupController_ cancel];
	DNSLog( @"%@-%d", path, dat );
	self.candidateDat = dat;
	self.candidatePath = path;
	[self tryToOpen];
}

- (void)openAnchor:(NSArray*)resNumberArray {
	DNSLogMethod
	anchorPopupController_.source = self.threadDat.resList;
	[anchorPopupController_ showInView:self.navigationController.view withNumbers:resNumberArray];
}

- (void)openAsciiView:(int)resNumber {
	asciiPopupViewController_.resData = [self.threadDat.resList objectAtIndex:resNumber-1];
	[asciiPopupViewController_ showInView:self.navigationController.view];
}

#pragma mark Push UIToolbar

- (void) pushSearchButton:(id)sender {
	DNSLogMethod
	[toolbarController_ setCloseSearchButton];
	[self showSearchBar];
}

- (void) pushCloseSearchButton:(id)sender {
	DNSLogMethod
	[toolbarController_ setSearchButton];
	[self hideSearchBar];
	
	[UIView beginAnimations:kHideSearchBarThreadView context:nil];
	CGRect rect = self.tableView.frame;
	rect.origin.y = 0;
	rect.size.height = 372;
	self.tableView.frame = rect;
	[UIView commitAnimations];
	
	[searchedArray_ removeAllObjects];
	currentArray_ = self.threadDat.resList;
	[self.tableView reloadData];
}

#pragma mark Start download method

- (void)downloadNewDat {
	DNSLogMethod
	[self showStopButton];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.candidateThreadDat.dat );
		sqlite3_bind_text( statement, 2, [self.candidateThreadDat.path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			char *url_source = (char *)sqlite3_column_text(statement, 0);
			if( url_source ) {
				NSString* url = [NSString stringWithUTF8String:url_source];
				SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
				NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
				[downloader startWithRequest:req];
				[downloader release];
				[req release];
			}
		}
	}
	sqlite3_finalize( statement );
}

- (void)downloadResumeWithByte:(int)bytes lastModified:(NSString*)lastModified {
	DNSLogMethod
	[self showStopButton];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.candidateThreadDat.dat );
		sqlite3_bind_text( statement, 2, [self.candidateThreadDat.path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			char* url_source = (char *)sqlite3_column_text(statement, 0);
			if( url_source ) {
				NSString* url = [NSString stringWithUTF8String:url_source];
				DNSLog( url );
				SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
				NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
				
				[req setValue:[NSString stringWithFormat:@"bytes=%d-", bytes] forHTTPHeaderField: @"Range"];
				[req setValue:lastModified forHTTPHeaderField: @"If-Modified-Since"];
				[downloader startWithRequest:req];
				[downloader release];
				[req release];
			}
		}
	}
	sqlite3_finalize( statement );
}

#pragma mark SearchView Management

- (void) showSearchBar {
	DNSLogMethod
	[UIView beginAnimations:kShowSearchBarThreadView context:nil];
	CGRect barRect = searchbar_.frame;
	barRect.size.height = 44;
	searchbar_.frame = barRect;
	searchbar_.text = @"";
	searchbar_.alpha = 1.0;
	[searchbar_ becomeFirstResponder];
	[UIView commitAnimations];
}

- (void) hideSearchBar {
	DNSLogMethod
	[UIView beginAnimations:kHideSearchBarThreadView context:nil];
	CGRect barRect = searchbar_.frame;
	barRect.size.height = 0;
	searchbar_.frame = barRect;
	searchbar_.text = @"";
	searchbar_.alpha = 0.0;
	[searchbar_ resignFirstResponder];
	[UIView commitAnimations];
}

- (void)reduceTableViewToShowSearchBar:(BOOL)animated {
	DNSLogMethod
	if( animated )
		[UIView beginAnimations:kReduceTableViewToShowSearchBarThreadView context:nil];
	
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
		[UIView beginAnimations:kExpandTableViewToCloseKeyboardThreadView context:nil];
	
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
		[UIView beginAnimations:kExpandTableViewToCloseSearchBarThreadView context:nil];
	
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

#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		searchbar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,0)];
		searchbar_.showsCancelButton = YES;
		searchbar_.delegate = self;
		[self.view addSubview:searchbar_];
		searchbar_.alpha = 0.0;
		
		UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
		self.navigationItem.rightBarButtonItem = reloadButton;
		[reloadButton release];
		
		anchorPopupController_ = [[AnchorPopupViewController alloc] init];
		anchorPopupController_.delegate = self;
		
		asciiPopupViewController_ = [[AsciiPopupViewController alloc] init];
		//asciiPopupViewController_.delegate = self;
		
		toolbarController_ = [[ThreadViewToolbarController alloc] initWithDelegate:self];
		searchedArray_ = [[NSMutableArray alloc] init];
		
		titleLabel_ = [[PopupLabel alloc] initWithFrame:CGRectMake(0,0,240,44)];
		titleLabel_.text = @"";
		titleLabel_.backgroundColor = [UIColor clearColor];
		titleLabel_.textColor = [UIColor whiteColor];
		titleLabel_.textAlignment = UITextAlignmentCenter;
		titleLabel_.shadowColor = [UIColor blackColor];
		titleLabel_.numberOfLines = 2;
		titleLabel_.lineBreakMode = UILineBreakModeMiddleTruncation;
		titleLabel_.font = [UIFont boldSystemFontOfSize:18.0f];
		titleLabel_.userInteractionEnabled = YES;
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kUpdateTitleNotification object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	DNSLogMethod
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[self tryToOpen];
	[self.tableView reloadData];
	[super viewDidAppear:animated];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DNSLogMethod
	DNSLog( @"%d", buttonIndex );
	if( buttonIndex == 0 ) {
		BookmarkController* con = UIAppDelegate.bookmarkController;
		[con addBookmarkOfThreadWithPath:self.threadDat.path dat:self.threadDat.dat title:self.threadDat.title];
	}
}

#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	[self showReloadButton];
	int bytes = self.candidateThreadDat.bytes;
	
	DNSLog( @"already - %d", bytes );
	DNSLog( @"got - %d", [data length] );
	
	if( [data length] != bytes && [data length] > 0) {
		NSDictionary *headerDict = [response allHeaderFields];
		Dat* candidateDat = self.candidateThreadDat;
		
		ThreadDatParser* parser = [[ThreadDatParser alloc] init];
		[parser parse:data appendToDat:candidateDat];
		
		//[DatParser parse:data appendTo:candidateDat];		
		[Dat updateThreadInfoWithRes:[candidateDat.resList count] resRead:[candidateDat.resList count] title:candidateDat.title path:candidateDat.path dat:candidateDat.dat];
		
		[parser release];
		
		candidateDat.bytes = bytes + [[headerDict objectForKey:@"Content-Length"] intValue];
		candidateDat.lastModified = [headerDict objectForKey:@"Last-Modified"];
		[candidateDat write];
	}
	[self setCandidateData];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	[self showReloadButton];
	[self setCandidateData];
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
	[self showReloadButton];
	[self setCandidateData];
}

- (void) didCacheURLLoading {
	[self showReloadButton];
	DNSLogMethod
}

- (void) didCancelLoadingResponse:(NSURLResponse*)httpURLResponse {
	[self showReloadButton];
	DNSLogMethod
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
	
	[searchedArray_ removeAllObjects];
	currentArray_ = self.threadDat.resList;
	[self.tableView reloadData];
	[toolbarController_ setSearchButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[self expandTableViewToCloseKeyboard:YES];
	[searchbar_ resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DNSLogMethod
	[self searchWithText:searchText];
	currentArray_ = searchedArray_;
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (int)indexFromIndexPath:(NSIndexPath *)indexPath {
	int sections = [currentArray_ count] % ROWS_PER_SECTION <= 1 ? [currentArray_ count] / ROWS_PER_SECTION + 1 : [currentArray_ count] / ROWS_PER_SECTION + 2;
	
	if( [currentArray_ count] % ROWS_PER_SECTION < 1 ) {
		if( indexPath.section == sections - 1 )
			return [currentArray_ count] - 1;
		else
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
	}
	else {
		if( indexPath.section == sections - 1 )
			return [currentArray_ count] - 1;
		else if( indexPath.section == sections - 2 )
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
		else
			return indexPath.section * ROWS_PER_SECTION + indexPath.row;
	}	
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	DNSLogMethod
	NSMutableArray *ary = [NSMutableArray array];
	int i;
	
	int sections = [currentArray_ count] % ROWS_PER_SECTION <= 1 ? [currentArray_ count] / ROWS_PER_SECTION + 1 : [currentArray_ count] / ROWS_PER_SECTION + 2;
	
	for( i = 0; i < sections; i++ ) {
		if( i != sections - 1 )
			[ary addObject:[NSString stringWithFormat:@"%d",i*ROWS_PER_SECTION+1]];
		else
			[ary addObject:[NSString stringWithFormat:@"%d",[currentArray_ count]]];
	}
	return ary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int sections = [currentArray_ count] % ROWS_PER_SECTION <= 1 ? [currentArray_ count] / ROWS_PER_SECTION + 1 : [currentArray_ count] / ROWS_PER_SECTION + 2;
	if( sections == 0)
		return 1;
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int sections = [currentArray_ count] % ROWS_PER_SECTION <= 1 ? [currentArray_ count] / ROWS_PER_SECTION + 1 : [currentArray_ count] / ROWS_PER_SECTION + 2;
	
	if( [currentArray_ count] == 0 )
		return 0;
	
	if( [currentArray_ count] % ROWS_PER_SECTION == 1 ) {
		if( section == sections - 1 )
			return 1;
		else
			return ROWS_PER_SECTION;
	}
	else {
		if( section == sections - 1 )
			return 1;
		else if( section == sections - 2 )
			return ([currentArray_ count] % ROWS_PER_SECTION !=0 ? [currentArray_ count] % ROWS_PER_SECTION : ROWS_PER_SECTION )- 1;
		else
			return ROWS_PER_SECTION;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	int sections = [currentArray_ count] % ROWS_PER_SECTION <= 1 ? [currentArray_ count] / ROWS_PER_SECTION + 1 : [currentArray_ count] / ROWS_PER_SECTION + 2;
	if( section != sections - 1 )
		return [NSString stringWithFormat:@"%d -",section*ROWS_PER_SECTION+1];
	else
		return [NSString stringWithFormat:@"%d",[currentArray_ count]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ThreadResData* r = [currentArray_ objectAtIndex:[self indexFromIndexPath:indexPath]];
	return r.height + [ThreadCell offsetHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadCell *cell = (ThreadCell*)[tableView dequeueReusableCellWithIdentifier:kThreadViewCellIdentifier];
    if (cell == nil) {
        cell = [[[ThreadCell alloc] initWithFrame:CGRectZero reuseIdentifier:kThreadViewCellIdentifier] autorelease];
    }
	else {
		[cell prepareForReuse];
	}
	ThreadResData* r = [currentArray_ objectAtIndex:[self indexFromIndexPath:indexPath]];
	cell.resObject = r;
	cell.height = r.height;
	cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLogMethod
}

#pragma mark Dealloc

- (void)dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[toolbarController_ release];
	[threadDat_ release];
	[anchorPopupController_ release];
	[asciiPopupViewController_ release];
	[candidatePath_ release];
	[candidateThreadDat_ release];
	[searchedArray_ release];
	[titleLabel_ release];
    [super dealloc];
}


@end

