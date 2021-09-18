#import "ThreadViewController.h"
#import "_tchAppDelegate.h"
#import "ReplyViewController.h"
#import "global.h"

@implementation ThreadViewController

#pragma mark For debug

#ifdef _DEBUG
- (BOOL) respondsToSelector:(SEL) selector {
	DNSLog(@"[UIWebView] respondsToSelector: %s", selector);
	return [super respondsToSelector:selector];
}
#endif

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		downloader_ = [[Downloader alloc] initWithDelegate:self];
		downloader_.navitaionItemDelegate = self.navigationItem;
		
		hud_ = [[SNHUDActivityView alloc] init];
		popupView_ = [[PopupView alloc] initWithFrame:CGRectMake( 0, 0, 100, 100 )];

		webView_.backgroundColor = [UIColor whiteColor];
		webView_.scalesPageToFit = NO;
		webView_.delegate = self;
		webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		indexView_ = [[VerticalBarIndexView alloc] initWithFrame:CGRectMake( 280, 6, 37, 356) delegate:self];
		[self.view addSubview:indexView_];
		
		
	}
	return self;
}


- (void) openActivityHUDTimer:(id)obj {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	int data = [db.resList count];
	NSString *msg = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString( @"ThreadViewResHUD", nil ),data,NSLocalizedString( @"ThreadViewLoadingHUD", nil )];
	[hud_ setupWithMessage:msg];
	[hud_ arrange:app.mainNavigationController.visibleViewController.view.frame];
	[webView_ addSubview:hud_];
}

- (void) viewWillAppear:(BOOL)animated {
//	[self loadHTML];
}

- (void) viewWillDisappear:(BOOL)animated {
	DNSLog( @"[ThreadViewController] viewWillDisappear:" );
//	[webView_ removeFromSuperview];
	[popupView_ cancel];
}

- (void)dealloc {
	DNSLog( @"[ThreadViewController] dealloc" );
	[hud_ release];
	[popupView_ release];
	[super dealloc];
}

- (void) setUIToolbarReload {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	[items removeLastObject];
    UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadAction:)] autorelease];
	[items addObject:systemItem];
	[underToolbar_ setItems:items animated:NO];
}

- (void) setUIToolbarStop {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	[items removeLastObject];
    UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLoading:)] autorelease];
	[items addObject:systemItem];
	[underToolbar_ setItems:items animated:NO];
}

- (void) reloadCurrentThread {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	NSString *boardPath = [app.savedThread objectForKey:@"boardPath"];
	NSString *dat = [app.savedThread objectForKey:@"dat"];
	
	NSMutableDictionary *c = [db contentLengthAndLastModifiedDictOfDat:dat atBoardPath:boardPath];
	
	if( c == nil ) {
		// new download
		DNSLog( @"Error - why isn't there the cache?" );
	}
	else {
		NSString* server= [db serverOfBoardPath:boardPath];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, boardPath, dat];
		NSString* size = [c objectForKey:@"Content-Length"];
		NSString* last_update = [c objectForKey:@"Last-Modified"];
		DNSLog( @"URL           :%@", url );
		DNSLog( @"Content-Length:%@", size );
		DNSLog( @"Last-Modified :%@",last_update );
		[downloader_ cancel];
		[self setUIToolbarStop];
		[downloader_ startWithURL:url lastModified:last_update size:[size intValue] identifier:@"threadview_resume"];
	}
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	DNSLog( @"[ThreadViewController] didFailLoading - %@", identifier );
	[self setUIToolbarReload];
}

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	if( [identifier isEqualToString:@"threadview_resume"] ) {
		if( [data length] > 0 ) {
			NSDictionary *requestDict = [(NSHTTPURLResponse *)downloader_.lastResponse allHeaderFields];
			DNSLog( @"resume get Content-Length:%@", [requestDict objectForKey:@"Content-Length"] );
			DNSLog( @"resume Last-Modified     :%@", [requestDict objectForKey:@"Last-Modified"] );
			_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
			DataBase *db = app.mainDatabase;
			
			NSString *boardPath = [app.savedThread objectForKey:@"boardPath"];
			NSString *dat = [app.savedThread objectForKey:@"dat"];
			
			NSMutableDictionary *c = [db contentLengthAndLastModifiedDictOfDat:dat atBoardPath:boardPath];
			int previous_size = [[c objectForKey:@"Content-Length"] intValue];
			int current_size = [[requestDict objectForKey:@"Content-Length"] intValue];
			[db setContentLength:[NSString stringWithFormat:@"%d",previous_size+current_size] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:dat atBoardPath:boardPath];
			[db readRes:boardPath dat:dat data:data];
			[self loadHTML];
		}
	}
	[self setUIToolbarReload];
}

#pragma mark IBOutlet

- (IBAction)addBookmarkAction:(id)sender {
	DNSLog( @"aaaaa" );
}

- (IBAction)openBookmarkAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[self presentModalViewController:app.baseBookmarkViewController animated:YES];
}

- (IBAction) cancelLoading:(id)sender {
	DNSLog( @"[MainViewController] cancelLoading:" );
	[downloader_ cancel];
	[self setUIToolbarReload];
}

- (IBAction)reloadAction:(id)sender {
	[self reloadCurrentThread];
}

- (IBAction)replyAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	NSString *boardPath = [app.savedThread objectForKey:@"boardPath"];
	NSString *dat = [app.savedThread objectForKey:@"dat"];
	
	app.replyViewController.server = [db serverOfBoardPath:boardPath];
	app.replyViewController.boardPath = boardPath;
	app.replyViewController.dat = dat;
	[self presentModalViewController:app.replyViewController animated:YES];
//	ReplyViewController *replyView = [[ReplyViewController alloc] initWithNibName:@"ReplyViewController" bundle:nil];
//	replyView.server = [db serverOfBoardPath:boardPath];
//	replyView.boardPath = boardPath;
//	replyView.dat = dat;
//	[self presentModalViewController:replyView animated:YES];
//	[replyView release];
}

- (void) setIndex:(int)index {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	if( index > [db.resList count]/50 ) {
		NSString* script = @"document.documentElement.scrollHeight;";
		NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( height );
		script = [NSString stringWithFormat:@"window.scrollBy(0, %@);", height];
		NSString* result = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( result );
	}
	else{
		NSString* script = [NSString stringWithFormat:@"linkScroll('r%d');",index*50+1];
		NSString* height = [webView_ stringByEvaluatingJavaScriptFromString:script];	
		DNSLog( @"height->%@",height );
		script = [NSString stringWithFormat:@"window.scroll(0, %@);", height];
		NSString* result = [webView_ stringByEvaluatingJavaScriptFromString:script];
	}
}

#pragma mark UIViewControllerDelegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

#pragma mark UIWebViewControllerDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	DNSLog( @"[ThreadViewController] webViewDidStartLoad:" );
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DNSLog( @"[ThreadViewController] webViewDidFinishLoad:" );
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	[hud_ dismiss];
}

- (void) hideHUD {	
	DNSLog( @"hide" );
	[UIView beginAnimations:@"end" context:nil];
	[UIView setAnimationDuration:0.9];
	[hudView_ setAlpha:0.0f];
	[UIView commitAnimations];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *str = [[request URL] absoluteString];
	NSString *extention = [str substringWithRange:NSMakeRange([str length]-3, 3)];
	DNSLog( @"pop up?" );
	
	if( navigationType != UIWebViewNavigationTypeLinkClicked )
		return YES;
	else {
		if( [[[request URL] scheme] isEqualToString:@"applewebdata"] ) {
			DNSLog( @"pop up? - %@", str );
			NSArray *ary = [str componentsSeparatedByString:@"/"];
			NSString* res_num = [ary objectAtIndex:[ary count]-1];
			_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
			DataBase *db = app.mainDatabase;
			if( [res_num intValue] <= [db.resList count] && [db.resList count] > 0 ) {
				NSDictionary *dict = [db.resList objectAtIndex:[res_num intValue]-1];
				NSString* res = [NSString stringWithFormat:@"%d %@ %@\n\n%@", [res_num intValue], [dict objectForKey:@"name"], [dict objectForKey:@"date_id"], eliminateHTMLTag(getConvertedSpecialChar([dict objectForKey:@"body"]))];
				[popupView_ setMessage:res];
				[popupView_ popupInView:self.view];
			}
		}
		else if( [[[request URL] scheme] isEqualToString:@"http"] ) {
			DNSLog(@"[UIWebViewNavigationTypeLinkClicked] URL->%@\n", str);
			if( [extention isEqualToString:@"jpg"] ||  [extention isEqualToString:@"png"] ||  [extention isEqualToString:@"gif"] ) {
				[popupView_ setImageWithURL:str];
				[popupView_ popupInView:self.view];
			}
			else if( [self isURLOf2ch:str] ) {
				DNSLog( @"[UIWebViewNavigationTypeLinkClicked] 2ch link" );
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"ThreadViewConfirmOpenSafari", nil) message:str
														   delegate:self cancelButtonTitle:NSLocalizedString( @"ThreadViewConfirmOpenSafariCancel", nil) otherButtonTitles:NSLocalizedString( @"ThreadViewConfirmOpenSafariOK", nil), nil];
				[alert show];
				[alert release];
				confirmOpenSafari_ = alert;
			}
			return NO;
		}
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( actionSheet == confirmOpenSafari_ ) {
		if( buttonIndex == 1 ) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.message]];
		}
	}
}

#pragma mark Original method

- (void) loadHTML {
	DNSLog( @"[ThreadViewController] loadHTML:" );
	
//	webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,372)];
	webView_.backgroundColor = [UIColor whiteColor];
	webView_.scalesPageToFit = NO;
	webView_.delegate = self;
	webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//	[self.view addSubview:webView_];
	[self.view bringSubviewToFront:indexView_];
//	[webView_ release];
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(openActivityHUDTimer:) userInfo:nil repeats:NO];
	
	NSString* str = [self makeHTMLWithLandscape:NO];
	[webView_ loadHTMLString:str baseURL:nil];
	return;
}

- (NSString*) makeHTMLWithLandscape:(BOOL)landscape{
	
	DNSLog( @"[ThreadViewController] makeHTMLWithLandscape:" );
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	int i;
	
	if( [db.resList count]/50 > 19 )
		[indexView_ prepareForReuse:[db.resList count]/50+1];
	else
		[indexView_ prepareForReuse:[db.resList count]/50+2];
	
	NSMutableString *buff = [NSMutableString string];
	
	[buff appendString:@"<html><head>"];
	[buff appendString:@"<script type=\"text/javascript\">function linkScroll(linkId){var obj = document.getElementById(linkId);return obj.offsetTop;}</script>"];
	[buff appendString:@"<STYLE TYPE=\"text/css\"><!--"];
	[buff appendString:@"body{margin:0;padding:0;width:320px;}"];
	[buff appendString:@"p{margin:0;padding:0;font-size: 75%%;width:305px;}"];
	[buff appendString:@"div.entry{}"];
	[buff appendString:@"div.info{font-size: 75%%;width: 315px;border-top:solid 1px #000000;background:#EFEFEF;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.body{font-size: 85%%;width: 290px;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"--></STYLE>"];
	[buff appendString:@"</head><body>"];

	for( i = 0; i < [db.resList count]; i++ ) {
		NSDictionary *dict = [db.resList objectAtIndex:i];
		
		if( i % 50 == 0 )
			[buff appendFormat:@"<div id=\"r%d\">",i+1];
		
#ifdef _MAKE_MAIL_TO_TAG
		
		[buff appendString:@"<div class=\"info\">"];
		[buff appendFormat:@"%d <A HREF=\"%@\">%@</A> %@", i+1, [dict objectForKey:@"email"], [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];
		[buff appendString:@"</div>"];
#else
		[buff appendString:@"<div class=\"info\">"];
		[buff appendFormat:@"%d %@ %@", i+1, [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];
		[buff appendString:@"</div>"];
#endif
		//
		[buff appendString:@"<div class=\"body\">"];
		[buff appendString:[dict objectForKey:@"body"]];		
		[buff appendString:@"</div>"];
		
		if( i % 50 == 0 )
			[buff appendFormat:@"</div>",i];
	}
	[buff appendString:@"</body></html>"];
	return buff;

}

- (BOOL) isURLOf2ch:(NSString*)url {
	NSArray*elements = [url componentsSeparatedByString:@"/"];
	if( [elements count] >= 7 ) {
		
		NSString* server = [elements objectAtIndex:2];
		NSString* boardPath = [elements objectAtIndex:5];
		NSString* dat = [elements objectAtIndex:6];
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		DataBase *db = app.mainDatabase;
		if( [server isEqualToString:[db serverOfBoardPath:boardPath]] ) {
			return YES;
		}
		else
			return NO;
	}
	return NO;
}

#pragma mark For HUD

@end
