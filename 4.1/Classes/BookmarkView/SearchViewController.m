//
//  SearchViewController.m
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchViewToolbarController.h"
#import "BookmarkNavigationController.h"
#import "SNDownloader.h"
#import "BookmarkCellInfo.h"
#import "BookmarkViewCell.h"
#import "SearchTerminateCell.h"
#import "GTMNSString+HTML.h"
#import "GTMRegex.h"

#define SEARCH_COUNT 20

NSString *kSearchViewCellIdentifier = @"kSearchViewCellIdentifier";

NSString* getBoardTitle( NSString* path ) {
	const char *sql = "select title from board where path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);
		if (success != SQLITE_ERROR) {
			char *title_source = (char *)sqlite3_column_text(statement, 0);
			if( title_source ) {
				sqlite3_finalize( statement );
				return [NSString stringWithUTF8String:title_source];
			}
			sqlite3_finalize( statement );
			return nil;
		}
	}
	sqlite3_finalize( statement );
	return nil;
}

BookmarkCellInfo* traceSearchResut( char*p, int length, int* i ) {
	int startPoint = *i;
	while( *i < length ) {
		if( !strncmp( p+*i, " - <font size=-1><a href=http://", strlen( " - <font size=-1><a href=http://" ) ) ) {
			NSString* string = [[NSString alloc] initWithBytes:p+startPoint length:( *i - startPoint) encoding:NSJapaneseEUCStringEncoding];
			[string autorelease];
			NSString* pattern = @"<dt><a href=\"http://[^/]+/[^/]+/[^/]+/([^/]+)/([^/]+)/[^/]+\">([^<>]*)</a> \\((.+)\\)";
			NSEnumerator* enumerator = [string gtm_matchSegmentEnumeratorForPattern:pattern];
			NSArray* allSegments = [enumerator allObjects];
			
			for( id segment in allSegments ) {
				// NSString* source = [segment subPatternString:0];
				NSString* path = [segment subPatternString:1];
				NSString* boardTitle = getBoardTitle( [segment subPatternString:1] );
				NSString* dat = [segment subPatternString:2];
				NSString* title = [[segment subPatternString:3] gtm_stringByUnescapingFromHTML];
				NSString* res = [segment subPatternString:4];
				
				if( path && dat && title && res && boardTitle ) {
					DNSLog( @"-------------------------------------------------" );
					DNSLog( @"%@", title );
					DNSLog( @"%@", boardTitle );
					DNSLog( @"%@", path );
					DNSLog( @"%@", dat );
					DNSLog( @"%@", res );
					
					BookmarkCellInfo *cellInfo = [[BookmarkCellInfo alloc] init];
					cellInfo.title = title;
					cellInfo.resString = res;
					cellInfo.boardTitle = boardTitle;
					cellInfo.path = path;
					cellInfo.dat = [dat intValue];
					cellInfo.isUnread = NO;
					return cellInfo;
				}
				return nil;
			}
			return nil;
		}
		(*i)++;
	}
	
	NSString* string = [[NSString alloc] initWithBytes:p+startPoint length:( *i - startPoint - 1) encoding:NSJapaneseEUCStringEncoding];
	[string autorelease];
	DNSLog( @"Not Found Error - %@", string );

	return nil;
}
@implementation SearchViewController

@synthesize prevSearchText = prevSearchText_;

#pragma mark -
#pragma mark Button Event

- (void)pushBrazil:(id)sender {
	DNSLogMethod
}

- (void)parseSearchResult:(NSData*)data {
	DNSLogMethod
	int i = 0;
	int candidateCounter = 0;
	int length = [data length];
	char *p = (char*)[data bytes];
	while( i < length ) {
		if( !strncmp( p+i, "<dt><a href=\"http://", strlen( "<dt><a href=\"http://" ) ) ) {
			//i += strlen( "<dt><a href=\"http://" );
			candidateCounter++;
			BookmarkCellInfo* info = traceSearchResut( p, length, &i );
			if( info ) {
				info.number = [cellInfo_ count] + 1;
				info.numberString = [NSString stringWithFormat:@"%03d", [cellInfo_ count] + 1];
				[cellInfo_ addObject:info];
				[info release];
			}
			else {
				DNSLog( @"out" );
			}
			i++;
		}
		else {
			i++;
		}
	}
	
	if( candidateCounter < SEARCH_COUNT )
		searchFinished_ = YES;
	
	[self.tableView reloadData];
}

- (void)pushDoneButton:(id)sender {
	DNSLogMethod
	[self dismissModalViewControllerAnimated:YES];
}

- (void)startSearch:(NSString*)searchWord {
	NSArray* words = [searchWord componentsSeparatedByString:@" "];
	NSMutableString* query = [NSMutableString string];
	NSMutableString* url = [NSMutableString stringWithString:@"http://find.2ch.net/?STR="];
	for( NSString* word in words ) {
		[query appendFormat:@"%@+", [word stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]];
	}
	if( [query characterAtIndex:[query length]-1] == 43 ) {
		[query deleteCharactersInRange:NSMakeRange([query length]-1, 1)];
	}
	[url appendString:query];
	
	
	int offset = 0;
	int count = SEARCH_COUNT;
	
	//COUNT=25&TYPE=TITLE&BBS=ALL&OFFSET=150
	
	if( [prevSearchText_ isEqualToString:searchWord] ) {
		// append
		page_++;
		offset = page_ * SEARCH_COUNT + 1;
	}
	else {
		// clear buffer
		searchFinished_ = NO;
		[cellInfo_ removeAllObjects];
		page_ = 0;
	}
	[url appendFormat:@"&COUNT=%d", count];
	[url appendFormat:@"&OFFSET=%d", offset];
	DNSLog( @"%@", url );
	
	[toolbarController_ showActivityView];
	SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
	NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
	[downloader startWithRequest:req];
	[downloader release];
	[req release];
	loading_ = YES;
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [BookmarkViewCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( [cellInfo_ count] == 0 )
		return 1;
	else
		return [cellInfo_ count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BookmarkViewCell *cell = (BookmarkViewCell*)[tableView dequeueReusableCellWithIdentifier:kSearchViewCellIdentifier];
	if (cell == nil) {
		cell = [[[BookmarkViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSearchViewCellIdentifier] autorelease];
	}
	if( indexPath.row < [cellInfo_ count] ) {
		BookmarkCellInfo *data = [cellInfo_ objectAtIndex:indexPath.row];
		cell.data = data;
		return cell;
	}
	else {
		[terminateCell_ setFinished:searchFinished_ resultLength:[cellInfo_ count]];
		return terminateCell_;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int cellIndex = indexPath.row;
	BookmarkCellInfo *data = [cellInfo_ objectAtIndex:cellIndex];
	if( data.path && data.dat ) {
		[UIAppDelegate gotoThreadOfDat:data.dat path:data.path];
		[self dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
//	DNSLog( @"%d", [data length] );
//	DNSLog( @"%@", [[[NSString alloc] initWithCString:[data bytes] encoding:NSJapaneseEUCStringEncoding] autorelease] );
	[self parseSearchResult:data];
	loading_ = NO;
	[toolbarController_ hideActivityView];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	loading_ = NO;
	[toolbarController_ hideActivityView];
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
	loading_ = NO;
	[toolbarController_ hideActivityView];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	DNSLogMethod
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DNSLogMethod
	[self startSearch:searchBar.text];
	self.prevSearchText = searchBar.text;
	[searchBar resignFirstResponder];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DNSLogMethod
}

#pragma mark -
#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		toolbarController_ = [[SearchViewToolbarController alloc] initWithDelegate:self];
		cellInfo_ = [[NSMutableArray alloc] init];
		searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake( 0, 0, 320, 44 )];
		CGRect tableRect = tableView_.frame;
		tableRect.size.height -= 44;
		tableRect.origin.y += 44;
		tableView_.frame = tableRect;
		[self.view addSubview:searchBar_];
		[searchBar_ release];
		searchBar_.delegate = self;
		loading_ = NO;
		terminateCell_ = [[SearchTerminateCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TerminateCell"];
		
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	
	self.navigationItem.title = LocalStr( @"find.2ch" );
	[(BookmarkNavigationController*)self.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[self.tableView reloadData];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Done" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushDoneButton:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	if( [cellInfo_ count] == 0 )
		[searchBar_ becomeFirstResponder];
	else
		[searchBar_ resignFirstResponder];
	
	if( [searchBar_.text length] > 0 ) {
		searchFinished_ = NO;
	}
	else {
		searchFinished_ = YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if( searchFinished_ )
		return;
	if( loading_ )
		return;
	if( searchBar_.text != nil && [searchBar_.text length] > 0 ) {
		const int offset = 0;
		if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + offset) {
			[self startSearch:searchBar_.text];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[terminateCell_ release];
	[toolbarController_ release];
	[cellInfo_ release];
    [super dealloc];
}

@end
