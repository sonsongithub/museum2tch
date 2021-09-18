//
//  Crawler.m
//  2tch
//
//  Created by sonson on 08/12/27.
//  Copyright 2008 sonson. All rights reserved.
//

#import "Crawler.h"
#import "BookmarkCellInfo.h"
#import "BookmarkController.h"
#import "BookmarkViewController.h"
#import "Dat.h"
#import "DatParserOld.h"
#import "SNDownloader.h"

@implementation CrawlData

@synthesize title = title_;
@synthesize path = path_;
@synthesize dat = dat_;

- (void)dealloc {
	[title_ release];
	[path_ release];
	[super dealloc];
}

@end

@implementation Crawler

@synthesize delegate = delegate_;
@synthesize currentDat = currentDat_;

#pragma mark Original Method

- (void)setLoadingIntoActionLabel {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		actionLabel_.text = LocalStr( @"Loading..." );
	}
	[pool release];
	[NSThread exit];
}

- (void)makeCommitArrayWithBookmark {
	DNSLogMethod
	BookmarkController *con = UIAppDelegate.bookmarkController;
	for( BookmarkCellInfo *data in con.list ) {
		if( data.path && data.dat ) {
			DNSLog( @"a" );
			CrawlData *crawlData = [[CrawlData alloc] init];
			[commit_ addObject:crawlData];
			crawlData.title = data.title;
			crawlData.path = data.path;
			crawlData.dat = data.dat;
			[crawlData release];
		}
	}
	
	progressStep_ = 1.0f/[commit_ count];
	DNSLog( @"%f", progressStep_ );
	
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void)show:(id)view {
	cancelSheet_ = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:LocalStr( @"Cancel" ) destructiveButtonTitle:nil otherButtonTitles:nil];
	[cancelSheet_ showInView:view];
	
	progress_.progress = 0;
	
	[cancelSheet_ addSubview:targetLabel_];
	[cancelSheet_ addSubview:actionLabel_];
	[cancelSheet_ addSubview:progress_];
	CGRect frame = cancelSheet_.bounds;
	
	DNSLog( @"Height1 - %f", frame.size.height );
	
	frame.size.height += 130;
	
	DNSLog( @"Height2 - %f", frame.size.height );
	
	targetLabel_.font = [UIFont boldSystemFontOfSize:12];
	targetLabel_.frame = CGRectMake( 0, 0, 300, 20 );
	targetLabel_.center = CGPointMake( frame.size.width/2, 90 );
	targetLabel_.text = @"-";
	targetLabel_.textColor = [UIColor whiteColor];
	targetLabel_.shadowColor = [UIColor blackColor];
	targetLabel_.backgroundColor = [UIColor clearColor];
	targetLabel_.shadowOffset = CGSizeMake( 0, -1 );
	targetLabel_.textAlignment = UITextAlignmentCenter;
	
	actionLabel_.font = [UIFont boldSystemFontOfSize:12];
	actionLabel_.frame = CGRectMake( 0, 0, 300, 20 );
	actionLabel_.center = CGPointMake( frame.size.width/2, 110 );
	actionLabel_.text = @"-";
	actionLabel_.textColor = [UIColor whiteColor];
	actionLabel_.shadowColor = [UIColor blackColor];
	actionLabel_.backgroundColor = [UIColor clearColor];
	actionLabel_.shadowOffset = CGSizeMake( 0, -1 );
	actionLabel_.textAlignment = UITextAlignmentCenter;
	
	CGRect bounds = progress_.bounds;
	bounds.size.width = frame.size.width * 0.9;
	progress_.bounds = bounds;
	progress_.center = CGPointMake( frame.size.width/2, 137 );

	cancelSheet_.bounds = frame;
	[cancelSheet_ release];
	[self performSelector:@selector(makeCommitArrayWithBookmark) withObject:nil afterDelay:0.1];
}

#pragma mark -
#pragma mark Try to dowanlod thread data

- (void)tryToStartDownloadThreadWithCandidateThreadInfo {	
	DNSLogMethod
	
	if( [commit_ count] == 0 ) {
		DNSLog( @"crawl is finished" );
		[cancelSheet_ dismissWithClickedButtonIndex:0 animated:YES];
		[(BookmarkViewController*)delegate_ refreshCells];
		return;
	}

	progress_.progress += progressStep_;
	
	CrawlData* data = [commit_ lastObject];
	self.currentDat = [[Dat alloc] initWithDat:data.dat path:data.path];
	[self.currentDat release];
	
	targetLabel_.text = data.title;
	actionLabel_.text = LocalStr( @"Downloading..." );
	
	[commit_ removeLastObject];
	
	
	if( [self.currentDat.resList count] > 999 ) {
		// already 1001 loaded
		[self tryToStartDownloadThreadWithCandidateThreadInfo];
	}
	else if( self.currentDat.bytes > 0 ) {
		[self downloadResumeWithByte:self.currentDat.bytes lastModified:self.currentDat.lastModified];
	}
	else {
		[self downloadNewDat];
	}
}

#pragma mark -
#pragma mark Try to dowanlod thread data

- (void)downloadNewDat {
	DNSLogMethod
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.currentDat.dat );
		sqlite3_bind_text( statement, 2, [self.currentDat.path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			char* url_source = (char *)sqlite3_column_text(statement, 0);
			if( url_source ) {
				NSString* url = [NSString stringWithUTF8String:url_source];
				
				SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
				downloader.enableErrorMessage = NO;
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
	const char *sql = "select 'http://' || server.address || '/' || board.path || '/dat/' || ? || '.dat' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, self.currentDat.dat );
		sqlite3_bind_text( statement, 2, [self.currentDat.path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			char* url_source = (char *)sqlite3_column_text(statement, 0);
			if( url_source ) {
				NSString* url = [NSString stringWithUTF8String:url_source];
				DNSLog( url );
				SNDownloader* downloader = [[SNDownloader alloc] initWithDelegate:self];
				downloader.enableErrorMessage = NO;
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

#pragma mark -
#pragma mark SNDownloaderDelegate

- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response {
	DNSLogMethod
	int bytes = self.currentDat.bytes;
	
	DNSLog( @"already - %d", bytes );
	DNSLog( @"got - %d", [data length] );
	
	if( [data length] != bytes && [data length] > 0) {
		
		[NSThread detachNewThreadSelector:@selector(setLoadingIntoActionLabel) toTarget:self withObject:nil];
		
		NSDictionary *headerDict = [response allHeaderFields];
		
		self.currentDat;
//		int preve_read = [self.currentDat.resList count];
		[DatParserOld parse:data appendTo:self.currentDat];		
		[Dat updateThreadInfoWithoutResReadWithRes:[self.currentDat.resList count] title:self.currentDat.title path:self.currentDat.path dat:self.currentDat.dat];
		
		self.currentDat.bytes = bytes + [[headerDict objectForKey:@"Content-Length"] intValue];
		self.currentDat.lastModified = [headerDict objectForKey:@"Last-Modified"];
		[self.currentDat write];
	}
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void) didFailLoadingWithError:(NSError *)error {
	DNSLogMethod
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

- (void) didDifferenctURLLoading {
	DNSLogMethod
	[self tryToStartDownloadThreadWithCandidateThreadInfo];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DNSLogMethod
	[commit_ removeAllObjects];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloaderCancel object:self];
	[(BookmarkViewController*)delegate_ refreshCells];
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	
	progress_ = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	targetLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
	actionLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
	
	commit_ = [[NSMutableArray alloc] init];
	isCanceled_ = NO;
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[targetLabel_ release];
	[actionLabel_ release];
	[progress_ release];
	[currentDat_ release];
	[commit_ release];
	[super dealloc];
}

@end
