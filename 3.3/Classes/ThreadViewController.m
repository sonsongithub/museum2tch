//
//  ThreadViewController.m
//  2tch
//
//  Created by sonson on 08/11/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewController.h"
#import "string-private.h"
#import "SNDownloader.h"
#import "StatusManager.h"
#import "MainNavigationController.h"
#import "ThreadViewToolbarController.h"
#import "DatParser_old.h"
#import "DatHTMLManager.h"
#import "PopupMenuController.h"
#import "ThreadRenderingView.h"
#import "ThreadViewIndex.h"
#import "SNWebBrowser.h"
#import "HistoryController.h"
#import "AnchorPopupViewController.h"
#import "ReplyNavigationController.h"
#import "BookmarkHelper.h"
#import "BookmarkNavigationController.h"

@implementation ThreadViewController

@synthesize candidatePath = candidatePath_;
@synthesize candidateDat = candidateDat_;
@synthesize resList = resList_;

#pragma mark Load thread to rendering view

- (void)loadThread {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	NSMutableArray* newResList = [DatParser_old resListOfPath:self.candidatePath dat:self.candidateDat];
	if( newResList ) {
		UIAppDelegate.status.dat = self.candidateDat;
		UIAppDelegate.status.path = self.candidatePath;
		[popupMenuController_ rebuildPopupMenu:[newResList count]];
		self.resList = newResList;
		[self setFrom:-1 to:-1];
		[self updateTitle];
		[DatParser_old updateReadRes:[newResList count] path:UIAppDelegate.status.path dat:UIAppDelegate.status.dat];
		[UIAppDelegate.historyController insertNewThreadInfoWithPath:UIAppDelegate.status.path dat:UIAppDelegate.status.dat];
	}
	else {
	}
	[toolbarController_ updateBackButton:[UIAppDelegate.historyController canGoBack] forwardButton:[UIAppDelegate.historyController canGoForward]];
}

- (void)loadThreadWithoutAddingHistory:(NSDictionary*)threadInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	self.candidateDat = [[threadInfo objectForKey:@"dat"] intValue];
	self.candidatePath = [threadInfo objectForKey:@"path"];
	NSMutableArray* newResList = [DatParser_old resListOfPath:self.candidatePath dat:self.candidateDat];
	if( newResList ) {
		UIAppDelegate.status.dat = self.candidateDat;
		UIAppDelegate.status.path = self.candidatePath;
		[popupMenuController_ rebuildPopupMenu:[newResList count]];
		self.resList = newResList;
		[self setFrom:-1 to:-1];
		[self updateTitle];
		[DatParser_old updateReadRes:[newResList count] path:UIAppDelegate.status.path dat:UIAppDelegate.status.dat];
	}
	[toolbarController_ updateBackButton:[UIAppDelegate.historyController canGoBack] forwardButton:[UIAppDelegate.historyController canGoForward]];
}

#pragma mark Push button selectors

- (void)pushBookmarkButton:(id)sender {
	DNSLogMethod
	BookmarkNavigationController* con = [BookmarkNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

- (void)pushBackButton:(id)sender {
	DNSLogMethod
	NSDictionary* threadInfo = [UIAppDelegate.historyController goBack];
	[self loadThreadWithoutAddingHistory:threadInfo];
}

- (void)pushForwardButton:(id)sender {
	DNSLogMethod	
	NSDictionary* threadInfo = [UIAppDelegate.historyController goForward];
	[self loadThreadWithoutAddingHistory:threadInfo];
}

- (void)pushAddButton:(id)sender {
	if( UIAppDelegate.status.dat != 0 && UIAppDelegate.status.path != nil ) {
		[BookmarkHelper insertThreadIntoBookmarkOfDat:UIAppDelegate.status.dat path:UIAppDelegate.status.path];
	}
}

- (void)pushComposeButton:(id)sender {
	ReplyNavigationController* con = [ReplyNavigationController defaultController];
	[self.navigationController presentModalViewController:con animated:YES];
	[con release];
}

#pragma delegate from child view or viewcontroller 

- (void)openWebBrowser:(NSString*)url {
	DNSLogMethod
	SNWebBrowser* con = [[SNWebBrowser alloc] initWithoutRootViewController];
	[con openURLString:url];
	[self presentModalViewController:con animated:YES];
	[con release];
}

- (void)open2chLinkwithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	DNSLog( @"%@-%d", path, dat );
	self.candidateDat = dat;
	self.candidatePath = path;
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void)openAnchor:(NSArray*)resNumberArray {
	NSString *htmlString = [DatHTMLManager makeAnchorHTMLStringWithResNumberArray:resNumberArray resList:self.resList];
	[anchorPopupController_ showInView:self.navigationController.view withHTMLSource:htmlString];
}

#pragma mark for WebView to render thread view

- (void)scrollToDIV:(int)index {
	DNSLogMethod
	DNSLog( @"%d", index );
	if( !self.resList )
		return;
	
	NSString* script = [NSString stringWithFormat:@"linkScroll('r%d');",index];
	NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];
	DNSLog( @"height - %@", height );
	if( [height length] > 0 ) {
		DNSLog( @"normal" );
		script = [NSString stringWithFormat:@"window.scroll(0, %@);", height];
		DNSLog( @"%@", script );
		[webView_ stringByEvaluatingJavaScriptFromString:script];
	}
	else{
		NSString* script = @"document.documentElement.scrollHeight;";
		NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];
		script = [NSString stringWithFormat:@"window.scroll(0, %@);", height];
		[webView_ stringByEvaluatingJavaScriptFromString:script];
	}
}

- (void)setFrom:(int)from to:(int)to {
	DNSLogMethod
	if( from == -1 && to == -1 && self.resList ) {
		int previous_res = 1;
		int res = 1;
		[DatParser_old getPreviousRes:&previous_res res:&res withDat:UIAppDelegate.status.dat path:UIAppDelegate.status.path];
		if( res - previous_res > 100 ) {
			previous_res = res - 100;
		}
		DNSLog( @"%d-%d", previous_res, res );
		NSString *html = [DatHTMLManager htmlNewModeFrom:previous_res to:res path:UIAppDelegate.status.path dat:UIAppDelegate.status.dat resList:self.resList];
		[webView_ loadHTMLString:html baseURL:nil];
		[indexView_ prepareForReuseFrom:previous_res to:res];
	}
	else if( self.resList ) {
		DNSLog( @"%d-%d", from, to );
		NSString *html = [DatHTMLManager htmlFrom:from to:to path:UIAppDelegate.status.path dat:UIAppDelegate.status.dat resList:self.resList];
		[webView_ loadHTMLString:html baseURL:nil];
		[indexView_ prepareForReuseFrom:from to:to];
	}
}

#pragma mark Start download method

- (void)tryToStartDownloadThreadWithCandidateThreadInfo {	
	int bytes = 0;
	NSString *lastModified = nil;
	int resRead = 1;
	DNSLog( @"%@-%d", self.candidatePath, self.candidateDat );
	[DatParser_old getBytes:&bytes lastModified:&lastModified resRead:&resRead ofPath:self.candidatePath dat:self.candidateDat];
	if( bytes > 0 ) {
		[self downloadResumeWithByte:bytes lastModified:lastModified];
	}
	else {
		[self downloadNewDat];
	}
}

- (void)downloadNewDat {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.candidateDat );
		sqlite3_bind_text( statement, 2, [self.candidatePath UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			NSString* url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			
			SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
			NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
			[self showStopButton];
			[downloader startWithRequest:req];
			[downloader release];
			[req release];
		}
	}
	sqlite3_finalize( statement );
}

- (void)downloadResumeWithByte:(int)bytes lastModified:(NSString*)lastModified {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.candidateDat );
		sqlite3_bind_text( statement, 2, [self.candidatePath UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			NSString* url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			DNSLog( url );
			SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
			NSMutableURLRequest *req = [SNDownloader defaultRequestWithURLString:url];
			[self showStopButton];
			[req setValue:[NSString stringWithFormat:@"bytes=%d-", bytes] forHTTPHeaderField: @"Range"];
			[req setValue:lastModified forHTTPHeaderField: @"If-Modified-Since"];
			[downloader startWithRequest:req];
			[downloader release];
			[req release];
		}
	}
	sqlite3_finalize( statement );
}

#pragma mark Setup NavigationControll bar

- (void) updateTitle {
	DNSLogMethod
	NSString* title = [DatParser_old threadTitleWithDat:UIAppDelegate.status.dat path:UIAppDelegate.status.path];
	titleLabel_.text = title;
	CGRect titleRect = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 44) limitedToNumberOfLines:1];
	DNSLog( @"normal->%f,%f", titleRect.size.width, titleRect.size.height );
	if( titleRect.size.width > 180 ) {
		titleLabel_.font = [UIFont boldSystemFontOfSize:12.0f];
		titleLabel_.numberOfLines = 2;
		CGRect titleRectRevised = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 44) limitedToNumberOfLines:2];
		DNSLog( @"revised->%f,%f", titleRectRevised.size.width, titleRectRevised.size.height );
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

#pragma mark Push botton method

- (void)pushReloadButton:(id)sender {
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void)pushStopButton:(id)sender {
	[self showReloadButton];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
}

#pragma mark SNDownloaderDelegate method

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	[self showReloadButton];
	int bytes = 0;
	int previous_res = 1;
	int new_res = 1;
	NSString *lastModified = nil;
	[DatParser_old getBytes:&bytes lastModified:&lastModified resRead:&previous_res ofPath:self.candidatePath dat:self.candidateDat];
	
	if( bytes > 0 && lastModified && [data length] != bytes && [data length] > 0) {
		NSDictionary *headerDict = [response allHeaderFields];
		new_res = [DatParser_old appendNewThreadData:data path:self.candidatePath dat:self.candidateDat];
		if( new_res > 0 ) {
			[DatParser_old updateSubjectWithBytes:(bytes + [[headerDict objectForKey:@"Content-Length"] intValue]) lastModified:[headerDict objectForKey:@"Last-Modified"] resRead:new_res previousRes:previous_res ofPath:self.candidatePath dat:self.candidateDat];
			DNSLog( @"Update Content-Length:%d", bytes + [[headerDict objectForKey:@"Content-Length"] intValue] );
			DNSLog( @"Update Last-Modified :%@", [headerDict objectForKey:@"Last-Modified"] );
		}
		[self loadThread];
	}
	else if( bytes == 0 && lastModified == nil ) {
		NSDictionary *headerDict = [response allHeaderFields];
		new_res = [DatParser_old appendNewThreadData:data path:self.candidatePath dat:self.candidateDat];
		if( new_res > 0 ) {
			NSString* title = [DatParser_old threadTitleWithDat:self.candidateDat path:self.candidatePath];
			[DatParser_old insertSubjectWithBytes:[[headerDict objectForKey:@"Content-Length"] intValue] lastModified:[headerDict objectForKey:@"Last-Modified"] resRead:new_res title:title ofPath:self.candidatePath dat:self.candidateDat];
			DNSLog( @"Update Content-Length:%@", [headerDict objectForKey:@"Content-Length"] );
			DNSLog( @"Update Last-Modified :%@", [headerDict objectForKey:@"Last-Modified"] );
		}
		[self loadThread];
	}
	else {
		if( self.resList == nil || ( self.candidateDat != UIAppDelegate.status.dat && ![self.candidatePath isEqualToString:UIAppDelegate.status.path] ) )
			[self loadThread];
	}
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	[self showReloadButton];
	[self loadThread];
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
	[self showReloadButton];
	[self loadThread];
}

- (void) didCacheURLLoading {
	DNSLogMethod
	[self showReloadButton];
	[self loadThread];
}

- (void) didCancelLoadingResponse:(NSURLResponse*)httpURLResponse {
	DNSLogMethod
	DNSLog( @"%@-%d", self.candidatePath, self.candidateDat );
	[self showReloadButton];
	[self updateTitle];
}

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		popupMenuController_ = [[PopupMenuController alloc] init];
		toolbarController_ = [[ThreadViewToolbarController alloc] initWithDelegate:self popupMenuControllerView:popupMenuController_.view];
		popupMenuController_.delegate = self;
		webView_ = UIAppDelegate.webView;
		webView_.mainDelegate = self;
		webView_.frame = CGRectMake( 0, 0, 320, 416);
		[self.view addSubview:webView_];
		indexView_ = [[ThreadViewIndex alloc] initWithDelegate:self];
		[self.view addSubview:indexView_];
		
		anchorPopupController_ = [[AnchorPopupViewController alloc] init];
		anchorPopupController_.delegate = self;
		
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0,0,240,44)];
		titleLabel_.text = @"";
		titleLabel_.backgroundColor = [UIColor clearColor];
		titleLabel_.textColor = [UIColor whiteColor];
		titleLabel_.textAlignment = UITextAlignmentCenter;
		titleLabel_.shadowColor = [UIColor blackColor];
		titleLabel_.numberOfLines = 2;
		titleLabel_.lineBreakMode = UILineBreakModeMiddleTruncation;
		titleLabel_.font = [UIFont boldSystemFontOfSize:18.0f];
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[toolbarController_ updateBackButton:[UIAppDelegate.historyController canGoBack] forwardButton:[UIAppDelegate.historyController canGoForward]];
	[UIAppDelegate.navigationController updateToolbarWithController:toolbarController_ animated:YES];
	[self showReloadButton];
	
	if( !self.resList )
		[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
}

- (void)dealloc {
	DNSLogMethod
	webView_.mainDelegate = nil;
	[titleLabel_ release];
	[indexView_ release];
	[resList_ release];
	[candidatePath_ release];
	[popupMenuController_ release];
	[toolbarController_ release];
	[anchorPopupController_ release];
	
    [super dealloc];
}


@end
