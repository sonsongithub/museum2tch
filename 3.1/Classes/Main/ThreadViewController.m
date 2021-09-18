//
//  ThreadViewController.m
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewController.h"
#import "ThreadViewPopupRes.h"
#import "ThreadViewPopupImage.h"
#import "_tchAppDelegate.h"
#import "DatInfo.h"
#import "global.h"
#import "html-tool.h"
#import "ReplyNaviController.h"
#import "ReplyViewController.h"
#import "BookmarkNaviController.h"

NSString *kThreadViewOpenDat = @"kThreadViewOpenDat";
NSString *kThreadViewReloadDat = @"kThreadViewReloadDat";
NSString *kThreadViewRenewalDat = @"kThreadViewRenewalDat";

@implementation ThreadViewController

@synthesize isPopupOpened = isPopupOpened_;

#pragma mark Original Method

- (void) startDownload {
	NSString *dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString *boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	NSString *title = [UIAppDelegate.savedThread objectForKey:@"title"];
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	
	[tempClickedData_ removeAllObjects];
	[tempClickedData_ setObject:dat forKey:@"dat"];
	[tempClickedData_ setObject:boardPath forKey:@"boardPath"];
	[tempClickedData_ setObject:title forKey:@"title"];
	
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	NSMutableDictionary *datInfoDict = [[obj dictOfDat:dat] retain];
	[obj release];
	
	if( datInfoDict == nil ) {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url identifier:kThreadViewOpenDat];
	}
	else {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		NSString* size = [datInfoDict objectForKey:@"Content-Length"];
		NSString* last_update = [datInfoDict objectForKey:@"Last-Modified"];
		DNSLog( @"URL           :%@", url );
		DNSLog( @"Content-Length:%@", size );
		DNSLog( @"Last-Modified :%@",last_update );
		
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url lastModified:last_update size:[size intValue] identifier:kThreadViewReloadDat];
		[datInfoDict release];
	}
}

- (void) startToDownloadForRenewal {
	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"];
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	
	[tempClickedData_ removeAllObjects];
	[tempClickedData_ setObject:dat forKey:@"dat"];
	[tempClickedData_ setObject:boardPath forKey:@"boardPath"];
	[tempClickedData_ setObject:title forKey:@"title"];
	
	NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
	UIAppDelegate.downloder.delegate = self;
	[UIAppDelegate.downloder cancel];
	[self toggleStopButton];
	[UIAppDelegate.downloder startWithURL:url identifier:kThreadViewRenewalDat];
}

- (void) updateSavedThread {
	if( [tempClickedData_ objectForKey:@"dat"] && [tempClickedData_ objectForKey:@"boardPath"] && [tempClickedData_ objectForKey:@"title"] ) {
		[UIAppDelegate.savedThread removeAllObjects];
		[UIAppDelegate.savedThread setObject:[tempClickedData_ objectForKey:@"dat"] forKey:@"dat"];
		[UIAppDelegate.savedThread setObject:[tempClickedData_ objectForKey:@"boardPath"] forKey:@"boardPath"];
		[UIAppDelegate.savedThread setObject:[tempClickedData_ objectForKey:@"title"] forKey:@"title"];
	}
	
	[tempClickedData_ removeAllObjects];
}

- (void) removeCacheAndPopView {
	DNSLog( @"renewal download is successful." );

	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	// NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	[obj removeInfoOfDat:dat];
	[obj release];
	
	[UIAppDelegate.threadDat release];
	UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:boardPath dat:dat];
	[UIAppDelegate.threadDat clearOldData];
	[UIAppDelegate.threadDat release];
	UIAppDelegate.threadDat = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) reload {
	[self toggleReloadButton];

	[UIAppDelegate.toolbarController clear:self];
	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"]; // unused
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];

	[tempClickedData_ removeAllObjects];
	[tempClickedData_ setObject:dat forKey:@"dat"];
	[tempClickedData_ setObject:boardPath forKey:@"boardPath"];
	[tempClickedData_ setObject:title forKey:@"title"];
	
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	NSMutableDictionary *datInfoDict = [[obj dictOfDat:dat] retain];
	
	if( datInfoDict == nil ) {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url identifier:kThreadViewOpenDat];
	}
	else {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		NSString* size = [datInfoDict objectForKey:@"Content-Length"];
		NSString* last_update = [datInfoDict objectForKey:@"Last-Modified"];
		DNSLog( @"URL           :%@", url );
		DNSLog( @"Content-Length:%@", size );
		DNSLog( @"Last-Modified :%@",last_update );
		
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url lastModified:last_update size:[size intValue] identifier:kThreadViewReloadDat];
		
	}
	[datInfoDict release];
	[obj release];
}

- (void) setThreadTitle:(NSString*) newTitle {
	
	DNSLog( @"Try to set title - %@", newTitle );
	
	titleLabel_.text = newTitle;
	titleLabel_.font = [UIFont boldSystemFontOfSize:18.0f];
	
	CGRect test = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 240, 44) limitedToNumberOfLines:1];
	
	if( test.size.width > 200 ) {
		titleLabel_.font = [UIFont boldSystemFontOfSize:12.0f];
		titleLabel_.numberOfLines = 2;
	}
	self.navigationItem.titleView = titleLabel_;
}

- (void) updateThreadTitleAllOverTheApp {
	NSString* title = [tempClickedData_ objectForKey:@"title"];
	NSString* dat = [tempClickedData_ objectForKey:@"dat"];
	NSString* boardPath = [tempClickedData_ objectForKey:@"boardPath"];
	
	if( [title isEqualToString:dat] ) {
		SubjectTxt *obj = [SubjectTxt SubjectTxtFromCacheWithBoardPath:boardPath];
		DNSLog( @"search" );
		if( obj != nil ) {
			for( NSMutableDictionary*dict in obj.subjectList ) {
				if( [[dict objectForKey:@"dat"] isEqualToString:dat] ) {
					title =  [dict objectForKey:@"title"];
					[tempClickedData_ setObject:title forKey:@"title"];
					[UIAppDelegate.bookmark updateTitleOfBookmarkOfBoardPath:boardPath dat:dat title:title];
					break;
				}
			}
		}
		[obj release];
	}
}

- (void) openThreadWithBoardPath:(NSString*)boardPath dat:(NSString*)dat title:(NSString*)title {
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];

	if( title == nil ) {
		title = dat;
	}
	
	[tempClickedData_ removeAllObjects];
	[tempClickedData_ setObject:dat forKey:@"dat"];
	[tempClickedData_ setObject:boardPath forKey:@"boardPath"];
	[tempClickedData_ setObject:title forKey:@"title"];
	
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	NSMutableDictionary *datInfoDict = [[obj dictOfDat:dat] retain];
	[obj release];
	

	[UIAppDelegate.toolbarController clear:self];
	
	if( datInfoDict == nil ) {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url identifier:kThreadViewOpenDat];
	}
	else {
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		NSString* size = [datInfoDict objectForKey:@"Content-Length"];
		NSString* last_update = [datInfoDict objectForKey:@"Last-Modified"];
		DNSLog( @"URL           :%@", url );
		DNSLog( @"Content-Length:%@", size );
		DNSLog( @"Last-Modified :%@",last_update );
		
		UIAppDelegate.downloder.delegate = self;
		[UIAppDelegate.downloder cancel];
		[self toggleStopButton];
		[UIAppDelegate.downloder startWithURL:url lastModified:last_update size:[size intValue] identifier:kThreadViewReloadDat];
		[datInfoDict release];
	}
}

- (void) reloadNewThread {
	NSString* str = [self makeHTMLwithMode:0];
	if( str != nil ) {
		[webView_ loadHTMLString:str baseURL:nil];
		[str release];
	}
}

- (void) changeDisplayMode:(int)mode {
	DNSLog( @"[ThreadViewController] changeDisplayMode:" );
	if( currentMode_ != mode ) {
		currentMode_ = mode;
		[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
		NSString* str = [self makeHTMLwithMode:mode];
		if( str != nil ) {
			[webView_ loadHTMLString:str baseURL:nil];
			[str release];
		}
	}
}

#pragma mark Original Method - Toggle above navigationbar's buttons

- (void) toggleReloadButton {	
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
}

- (void) toggleStopButton {	
	UIBarButtonItem*	stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pushStopButton:)];
	self.navigationItem.rightBarButtonItem = stopButton;
	[stopButton release];
}

#pragma mark Original Method - UIWebView Javascript Controll

- (void) scrollToDIV:(int)index {
	if( /*index > ( page_ + 1 ) * 500 || */index > [UIAppDelegate.threadDat.resList count] ) {
		NSString* script = @"document.documentElement.scrollHeight;";
		NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( @"Goto last - %@", height );
		script = [NSString stringWithFormat:@"window.scrollBy(0, %@);", height];
		NSString* result = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( result );
	}
	else{
		NSString* script = [NSString stringWithFormat:@"linkScroll('r%d');",index];
		NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( @"height->%@",height );
		script = [NSString stringWithFormat:@"window.scroll(0, %@);", height];
		/*NSString* result = */[webView_ stringByEvaluatingJavaScriptFromString:script];
	}
}

- (void) scrollToDogear {
	NSString* script = [NSString stringWithFormat:@"linkScroll('dogear');",index];
	NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];	
	DNSLog( @"height->%@",height );
	script = [NSString stringWithFormat:@"window.scroll(0, %@);", height];
	/*NSString* result = */[webView_ stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark Original Method - make threadview resource

- (void) appendHeaderPart:(NSMutableString*)buff {
	[buff appendString:@"<html><head>"];
	[buff appendString:@"<script type=\"text/javascript\">"];
	[buff appendString:@"function scrollToID(id_string){var obj = document.getElementById(id_string);window.scroll(0, obj.offsetTop);}"];
	[buff appendString:@"var clickedID = 0; var d = \"\"; function linkScroll(linkId){var obj = document.getElementById(linkId);return obj.offsetTop;} function clicked(input){	if(input!=clickedID) {	if(clickedID!=0){divname='r'+clickedID; document.getElementById(divname).style.fontWeight='normal';} divname='r'+input;	document.getElementById(divname).style.fontWeight='bold';clickedID=input;	}else{divname='r'+input;	document.getElementById(divname).style.fontWeight='normal';clickedID=0;}}"];
	[buff appendString:@"var mini = \"body_ascii\";var max = \"body\";function toggleAsciiMode(input){var divname='body'+input;if( document.getElementById(divname).className == mini ) {document.getElementById(divname).className = max;}else if( document.getElementById(divname).className == max ) {document.getElementById(divname).className = mini;}else {document.getElementById(divname).className = mini;}scrollToID(\"r\"+input);}"];
	[buff appendString:@"</script>"];
	[buff appendString:@"<STYLE TYPE=\"text/css\"><!--"];
	[buff appendString:@"body{margin:0;padding:0;width:320px;}"];
	[buff appendString:@"p{margin:0;padding:0;font-size: 75%%;width:305px;}"];
	[buff appendString:@"div.entry{}"];
	[buff appendString:@"div.dogear{word-wrap: break-word;font-size: 100%%;font-weight:bold;color:#FFFFFF;width: 315px;background:#696969;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.info{word-wrap: break-word;font-size: 75%%;width: 315px;border-top:solid 1px #000000;background:#EFEFEF;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.body{word-wrap: break-word;font-size: 85%%;width: 290px;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"div.body_ascii{font-size: 2%%;width:200%%;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"--></STYLE>"];
	[buff appendString:@"</head><body>"];
}

- (NSString*) makeHTMLwithMode:(int)mode {
	
	DNSLog( @"[ThreadViewController] makeHTMLwithMode:" );
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if( UIAppDelegate.threadDat == nil ) {
		[pool release];
		return nil;
	}
	
	int i;
	int from = 1;
	int end = [UIAppDelegate.threadDat.resList count];
	BOOL isShownNewComming = NO;
	BOOL isLimitedNewTo200 = NO;
	
	if( mode == 0 ) {
		isShownNewComming = YES;
		from = UIAppDelegate.threadDat.newResNumber;
		if( end - from > 200 ) {
			from = end - 200;
			isLimitedNewTo200 = YES;
		}
	}
	if( mode >= 2 ) {
		from = 1 + ( mode - 2 ) * 200;
		end = from + 200;
		if( end > [UIAppDelegate.threadDat.resList count] ) {
			end = [UIAppDelegate.threadDat.resList count];
		}
	}
	
	[UIAppDelegate.toolbarController setThreadViewMode:self numberOfRes:[UIAppDelegate.threadDat.resList count] isLimitedNewTo200:isLimitedNewTo200 mode:mode];
	[indexView_ prepareForReuseFrom:from to:end];
	[self.view bringSubviewToFront:indexView_];
	UIAppDelegate.toolbarController.threadViewLabel.text = [UIAppDelegate.threadDat resDescription];
	
	NSMutableString *buff = [[NSMutableString alloc] init];
	[self appendHeaderPart:buff];
	
	for( i = from-1; i < end; i++ ) {
		NSDictionary *dict = [UIAppDelegate.threadDat.resList objectAtIndex:i];
		
		if( isShownNewComming && i == from-1 && from != 1 ) {
			NSDictionary *headDict = [UIAppDelegate.threadDat.resList objectAtIndex:0];
	
			[buff appendFormat:@"<div id=\"r%d\">",1];
			[buff appendFormat:@"<div class=\"info\">"];
			[buff appendFormat:@"%d %@ %@", 1, [headDict objectForKey:@"name"], [headDict objectForKey:@"date_id"]];
			
			[buff appendFormat:@"<br/><a href=\"javascript:clicked(%d);\">anchor</a> <a href=\"javascript:toggleAsciiMode(%d);\">ascii</a>", 1, 1];
			
			[buff appendString:@"</div>"];
			[buff appendString:@"</div>"];
			
			[buff appendFormat:@"<div class=\"body\" id=\"body%d\">",1];
			[buff appendString:[headDict objectForKey:@"body"]];		
			[buff appendString:@"</div>"];
			
			[buff appendFormat:@"<div id=\"r%d\">",i+1];
			[buff appendFormat:@"<div id=\"dogear\" class=\"dogear\">"];
	
			if( isLimitedNewTo200 )
				[buff appendString:NSLocalizedString( @"NewComming200", nil)];
			else
				[buff appendString:NSLocalizedString( @"NewComming", nil)];
			
			[buff appendString:@"</div>"];
		}
		else {
			[buff appendFormat:@"<div id=\"r%d\">",i+1];
		}
		
		[buff appendFormat:@"<div class=\"info\">"];
		[buff appendFormat:@"%d %@ %@", i+1, [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];
		
		[buff appendFormat:@"<br/><a href=\"javascript:clicked(%d);\">anchor</a> <a href=\"javascript:toggleAsciiMode(%d);\">ascii</a>", i+1, i+1];
		
		[buff appendString:@"</div>"];
		[buff appendString:@"</div>"];
		
		[buff appendFormat:@"<div class=\"body\" id=\"body%d\">",i+1];
		[buff appendString:[dict objectForKey:@"body"]];		
		[buff appendString:@"</div>"];
		
	}
	[buff appendString:@"</body></html>"];
	[pool release];
	return buff;	
}

#pragma mark Original method - function to process new downloaded NSData

- (void) openNewDat:(NSData*)data {
	
	NSDictionary *requestDict = [(NSHTTPURLResponse *)UIAppDelegate.downloder.lastResponse allHeaderFields];
	
	NSString* title = [tempClickedData_ objectForKey:@"title"];
	NSString* dat = [tempClickedData_ objectForKey:@"dat"];
	NSString* boardPath = [tempClickedData_ objectForKey:@"boardPath"];
	
	DNSLog( @"Title:%@", title );
	DNSLog( @"Dat:%@", dat );
	DNSLog( @"Content-Length:%@", [requestDict objectForKey:@"Content-Length"] );
	DNSLog( @"Last-Modified :%@", [requestDict objectForKey:@"Last-Modified"] );
	
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	[obj setLength:[requestDict objectForKey:@"Content-Length"] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:dat];
	[obj release];
	
	[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
	[UIAppDelegate.threadDat release];
	UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:boardPath dat:dat];
	[UIAppDelegate.threadDat append:data];
	
	[self reloadNewThread];
}

- (void) reloadDat:(NSData*)data {
//	NSString* title = [tempClickedData_ objectForKey:@"title"];
	NSString* dat = [tempClickedData_ objectForKey:@"dat"];
	NSString* boardPath = [tempClickedData_ objectForKey:@"boardPath"];

	if( [data length] > 0 ) {
		DNSLog( @"updated -- reloadDat" );
		NSDictionary *requestDict = [(NSHTTPURLResponse *)UIAppDelegate.downloder.lastResponse allHeaderFields];
		DNSLog( @"resume get Content-Length:%@", [requestDict objectForKey:@"Content-Length"] );
		DNSLog( @"resume Last-Modified     :%@", [requestDict objectForKey:@"Last-Modified"] );
		
		DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
		NSMutableDictionary *datInfoDict = [obj dictOfDat:dat];
		int previous_size = [[datInfoDict objectForKey:@"Content-Length"] intValue];
		int current_size = [[requestDict objectForKey:@"Content-Length"] intValue];
		
		if( previous_size == current_size ) {
			[obj setLength:[NSString stringWithFormat:@"%d",previous_size] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:dat];
			[obj release];
		}
		else {
			[obj setLength:[NSString stringWithFormat:@"%d",previous_size+current_size] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:dat];
			[obj release];
			
			[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];

			[UIAppDelegate.threadDat release];
			UIAppDelegate.threadDat = nil;
			UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:boardPath dat:dat];
			[UIAppDelegate.threadDat append:data];
		
			[self reloadNewThread];
		}
	}
	else {
		[UIAppDelegate.toolbarController back];
		DNSLog( @"not updated -- reloadDat" );
		if( [UIAppDelegate.threadDat.dat isEqualToString:dat] && [UIAppDelegate.threadDat.boardPath isEqualToString:boardPath] ) {
		}
		else {
			[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
			UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:boardPath dat:dat];
			[self reloadNewThread];
		}	
	}
}

- (void) renewalDat:(NSData*)data {
	DNSLog( @"renewal download is successful." );
	
	
	NSDictionary *requestDict = [(NSHTTPURLResponse *)UIAppDelegate.downloder.lastResponse allHeaderFields];
	
	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	// NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	// NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"];

	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath];
	[obj setLength:[requestDict objectForKey:@"Content-Length"] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:dat];
	[obj release];
	
	[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
	[UIAppDelegate.threadDat release];
	UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:boardPath dat:dat];
	[UIAppDelegate.threadDat clearOldData];
	[UIAppDelegate.threadDat append:data];
	
	[self reloadNewThread];
}

#pragma mark Original Method - UIButton selector

- (void) addBookmark {
	
	
	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	NSString* boaddTitle = [UIAppDelegate.bbsmenu serverOfBoardTitle:boardPath];
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"];
	NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
	
	[UIAppDelegate.savedThread objectForKey:@"res"];
	
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:dat forKey:@"dat"];
	[dict setObject:boardPath forKey:@"boardPath"];
	[dict setObject:boaddTitle forKey:@"boardTitle"];
	[dict setObject:server forKey:@"server"];
	[dict setObject:title forKey:@"title"];
	[dict setObject:res forKey:@"res"];
	
	[UIAppDelegate.bookmark addWithDictinary:dict];
	
	[res release];
	[dict release];
}

- (void) pushAddButton:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToAddBookmark", nil )
													   delegate:self
											  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
										 destructiveButtonTitle:NSLocalizedString( @"Add", nil )
											  otherButtonTitles:nil];
	[sheet showInView:self.view];
	[sheet release];
	confirmBookmarkAddSheet_ = sheet;
}

- (void) pushBookmarkButton:(id)sender {
	
	
	[UIAppDelegate.downloder cancel];
	
	[[self navigationController] presentModalViewController:UIAppDelegate.bookmarkNaviController animated:YES];
}

- (void) pushTrashButton:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToRenewalDownload", nil )
													   delegate:self
											  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
										 destructiveButtonTitle:NSLocalizedString( @"OK", nil )
											  otherButtonTitles:NSLocalizedString( @"OnlyDelete", nil ), nil];
	[sheet showInView:self.view];
	[sheet release];
	confirmRenewalSheet_ = sheet;
}

- (void)pushReloadButton:(id)sender {
	[self toggleStopButton];
	[self reload];
}

- (void)pushStopButton:(id)sender {
	
	[UIAppDelegate.downloder cancel];
	[self toggleReloadButton];
	
	if( isAlreadyOpened_ ) {
		[UIAppDelegate.toolbarController back];
	}
	else {
		[UIAppDelegate.threadDat release];
		UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:[tempClickedData_ objectForKey:@"boardPath"] dat:[tempClickedData_ objectForKey:@"dat"]];
		
		if( [UIAppDelegate.threadDat.resList count] > 0 ) {
			[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
			[self reloadNewThread];
		}
	}
}

- (void)pushReplyButton:(id)sender {
	
	[UIAppDelegate.downloder cancel];
	[self toggleReloadButton];
	
	NSString* script = @"clickedID;";
	NSString* clickedID = [webView_ stringByEvaluatingJavaScriptFromString:script];	
	DNSLog( clickedID );
	
	ReplyNaviController* con = [ReplyNaviController defaultController];
	
	if( [clickedID intValue] != 0 )
		[(ReplyViewController*)con.visibleViewController setAnchor:[clickedID intValue]];
	
	[[self navigationController] presentModalViewController:con animated:YES];
	[con release];
}

#pragma mark Original method - UIWebViewNavigation - Method

- (void) processHTTPLinkWithURLString:(NSString*)url {
	NSDictionary* dict = isURLOf2ch(url);
	NSString *extentionOfURL = [url substringWithRange:NSMakeRange([url length]-3, 3)];
	
	
	if( dict ) {
		DNSLog( @"[UIWebViewNavigationTypeLinkClicked] 2ch link" );
		[self openThreadWithBoardPath:[dict objectForKey:@"boardPath"] dat:[dict objectForKey:@"dat"] title:nil ];
		return;
	}
	else {
		BOOL isImage = NO;
		NSArray *extentions = [[NSArray alloc] initWithObjects:@"jpg", @"JPG", @"png", @"PNG", @"gif", @"GIF", nil];
		
		for( NSString* extention in extentions ) {
			if( [extentionOfURL isEqualToString:extention] ) {
				isImage = YES;
				break;
			}
		}
		if( isImage ) {
			CGRect rect = self.view.frame;
			rect.size.width *= 0.8;
			rect.size.height *= 0.8;
			ThreadViewPopupImage* pop = [[ThreadViewPopupImage alloc] initWithFrame:rect];
			memoryWarningDelegate_ = pop;
			[pop setImageWithURL:url];
			[pop popupInView:self.view];
			[pop release];
			return;
		}
		[extentions release];
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"AreYouSureToOpenWithSafari", nil) message:url
													   delegate:self cancelButtonTitle:NSLocalizedString( @"Cancel", nil) otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
	[alert show];
	[alert release];
}

- (void) processAnchorWithURLString:(NSString*)url {
	NSArray *ary = [url componentsSeparatedByString:@"/"];
	NSString* res_num = [ary objectAtIndex:[ary count]-1];
	NSArray *res_num_array = [NSArray arrayWithObjects:[NSNumber numberWithInt:[res_num intValue]], nil];
	
	CGRect rect =self.view.frame;
	rect.size.width *= 0.8;
	rect.size.height *= 0.8;
	ThreadViewPopupRes *pop = [[ThreadViewPopupRes alloc] initWithFrame:rect];
	[pop setRes:res_num_array];
	[pop popupInView:self.view];
	[pop release];
}

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		indexView_ = [[ThreadViewIndex alloc] initWithDelegate:self];
		[self.view addSubview:indexView_];
		
		tempClickedData_ = [[NSMutableDictionary dictionary] retain];
		
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0,0,240,44)];
		titleLabel_.text = @"";
		titleLabel_.backgroundColor = [UIColor clearColor];
		titleLabel_.textColor = [UIColor whiteColor];
		titleLabel_.textAlignment = UITextAlignmentCenter;
		titleLabel_.shadowColor = [UIColor blackColor];
		titleLabel_.numberOfLines = 2;
		titleLabel_.lineBreakMode = UILineBreakModeMiddleTruncation;
		
		isAlreadyOpened_ = NO;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	DNSLog( @"[ThreadViewController] didReceiveMemoryWarning" );
	
	
	[UIAppDelegate.threadDat evacuate];
	UIAppDelegate.threadDat = nil;

	// release html code dictionary
	releaseDictionariesForHTMLDecode();
    [super didReceiveMemoryWarning];
}

- (void) viewWillDisappear:(BOOL)animated {
	
	[UIAppDelegate.downloder cancel];
}

- (void) clearWebView {
	[webView_ release];
	webView_ = nil;
	
	[UIAppDelegate.toolbarController clear:self];
	isAlreadyOpened_ = NO;
}

- (void) viewWillAppear:(BOOL)animated {
	[self toggleReloadButton];
	
	if( webView_ == nil ) {
		
		
		[UIAppDelegate.threadDat release];
		UIAppDelegate.threadDat = nil;
		[UIAppDelegate.toolbarController clear:self];
		
        webView_ = [[UIWebView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372 )];
		webView_.delegate = self;
		webView_.detectsPhoneNumbers = NO;
		webView_.backgroundColor = [UIColor whiteColor];
		webView_.scalesPageToFit = NO;
		webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.view addSubview:webView_];
		[self startDownload];
	}
}

- (void)dealloc {
	DNSLog( @"[ThreadViewController] dealloc" );
	[webView_ release];
	[indexView_ release];
	[tempClickedData_ release];
	[titleLabel_ release];
	
	
	[UIAppDelegate.threadDat release];
	UIAppDelegate.threadDat = nil;
	
    [super dealloc];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 1 ) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.message]];
	}
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( actionSheet == confirmRenewalSheet_ ) {
		if( buttonIndex == 0 )
			[self startToDownloadForRenewal];
		if( buttonIndex == 1 )
			[self removeCacheAndPopView];
	}
	else if( actionSheet == confirmBookmarkAddSheet_ ) {
		if( buttonIndex == 0 )
			[self addBookmark];
	}
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *str = [[request URL] absoluteString];
	NSString *urlString = str;
//	DNSLog( @"pop up?" );
	
	// out of click, like load image and so on
	if( navigationType != UIWebViewNavigationTypeLinkClicked ) {
		return YES;
	}
	else if( [[[request URL] scheme] isEqualToString:@"applewebdata"] ) {
		[self processAnchorWithURLString:urlString];
		return NO;
	}
	else if( [[[request URL] scheme] isEqualToString:@"http"] ) {
		[self processHTTPLinkWithURLString:urlString];
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DNSLog( @"[ThreadViewController] webViewDidFinishLoad:" );
	
	[self updateThreadTitleAllOverTheApp];
	[self updateSavedThread];
	[UIAppDelegate closeHUD];
	[self scrollToDogear];
	[self setThreadTitle:[UIAppDelegate.savedThread objectForKey:@"title"]];
	
	NSString* dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	NSString* boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	NSString* boaddTitle = [UIAppDelegate.bbsmenu serverOfBoardTitle:boardPath];
	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"];
	NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
	
	[UIAppDelegate.savedThread objectForKey:@"res"];
	
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:dat forKey:@"dat"];
	[dict setObject:boardPath forKey:@"boardPath"];
	[dict setObject:boaddTitle forKey:@"boardTitle"];
	[dict setObject:server forKey:@"server"];
	[dict setObject:title forKey:@"title"];
	[dict setObject:res forKey:@"res"];
	
	[UIAppDelegate.history addWithDictinary:dict];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSuccessOpenThreadFromBookmark object:self];
	
	[res release];
	[dict release];
	
	isAlreadyOpened_ = YES;
}

#pragma mark DownloaderDelegate

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[ThreadViewController] didFinishLoading - %@", identifier );
	
	[self toggleReloadButton];
	
	if ( [identifier isEqualToString:kThreadViewOpenDat] ) {
		[self openNewDat:data];
	}
	if ( [identifier isEqualToString:kThreadViewReloadDat] ) {
		[self reloadDat:data];
	}
	if( [identifier isEqualToString:kThreadViewRenewalDat] ) {
		[self renewalDat:data];
	}
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	DNSLog( @"[ThreadViewController] didFailLoadingWithIdentifier:error:isDifferentURL: - %@", identifier );
	
	[self toggleReloadButton];
//	[self updateSavedThread];
	NSString* title = [UIAppDelegate.savedThread objectForKey:@"title"];
	[self setThreadTitle:title];
	
	if( [identifier isEqualToString:kThreadViewReloadDat] ) {
		
		[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];

		[UIAppDelegate.threadDat release];
		UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:[tempClickedData_ objectForKey:@"boardPath"] dat:[tempClickedData_ objectForKey:@"dat"]];
//		UIAppDelegate.threadDat = [ThreadDat ThreadDatWithBoardPath:[UIAppDelegate.savedThread objectForKey:@"boardPath"] dat:[UIAppDelegate.savedThread objectForKey:@"dat"]];
		
		if( [UIAppDelegate.threadDat.resList count] > 0 ) {
			[self reloadNewThread];
		}
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:[error localizedDescription]
												   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
		[alert show];
		[alert release];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFailedOpenThreadFromBookmark object:self];
		
		
		if( isAlreadyOpened_ ) {
			DNSLog( @"isAlreadyOpened_" );
			[UIAppDelegate.toolbarController back];
		}
		else {
			DNSLog( @"isAlreadyOpened_  no " );
		}
	}
}

@end
