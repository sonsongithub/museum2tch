
#import "ThreadView.h"
#import "MainController.h"
#import "DatFile.h"
#import "global.h"

@interface UIWebView (HackWebView)	// for peeking msg to UIWebView
#ifdef _DEBUG_WEBVIEW
- (BOOL) respondsToSelector:(SEL) selector;
#endif
@end
@implementation UIWebView (HackWebView)
- (void) dealloc {
	DNSLog( @"UIWebView - dealloc" );
	[super dealloc];
}
#ifdef _DEBUG_WEBVIEW
- (BOOL) respondsToSelector:(SEL) selector {
	DNSLog(@"[UIWebView] respondsToSelector: %s", selector);
	return [super respondsToSelector:selector];
}
#endif
@end

@implementation ThreadView
/*
#ifdef _DEBUG
- (BOOL) respondsToSelector:(SEL) selector {
	DNSLog(@"[ThreadView] respondsToSelector: %s", selector);
	return [super respondsToSelector:selector];
}
#endif
*/
- (id) initWithFrame:(CGRect) frame withParentController:(id)fp {
	if( ! ( self = [super initWithFrame:frame] ) )
		return nil;
		
	parentController_ = fp;

	scroller_ = [[[UIScroller alloc] initWithFrame:CGRectMake(0, 0, 320, 372)] autorelease];
	[scroller_ setAdjustForContentSizeChange: YES];
	[scroller_ setClipsSubviews: YES];
	[self addSubview:scroller_];
	
	float white[4] = {1.0, 1.0, 1.0, 1};
	[scroller_ setBackgroundColor:CGColorCreate( CGColorSpaceCreateDeviceRGB(), white)];

	//
	isMakingHTML_ = NO;
	hasFinishedMakingHTML_ = YES;
	
	id center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
			selector:@selector(openThreadView:)
			name:@"openThreadView"
			object:nil];
			
	[uiWebView_ setTapDelegate: self];
	return self;
}

- (void)view: (UIView *)view handleTapWithCount:(int)count event: (GSEventRef)event fingerCount: (int)finger {
	NSLog (@"%d", count );
	if( count == 2 ) {
		id webView = [uiWebView_ webView];
		id preferences = [webView preferences];
		int size =[preferences defaultFontSize];
		if( size != 8 )
			[preferences setDefaultFontSize:8];
		else
			[preferences setDefaultFontSize:16];
	}
}


- (void) dealloc {
	DNSLog( @"UIWebView - dealloc" );
	[super dealloc];
}

- (id) uiWebView {
	return uiWebView_;
}

// delegate
- (void)webView:(WebView*)sender didStartProvisionalLoadForFrame:(WebFrame*)frame {
	if (frame == [sender mainFrame]) {
		resourceCount_ = 0;    
		resourceCompletedCount_ = 0;
		resourceFailedCount_ = 0;
		[UIApp setStatusBarShowsProgress:YES];
	}
}

- (id)webView:(WebView*)sender identifierForInitialRequest:(NSURLRequest*)request fromDataSource:(WebDataSource*)dataSource {
	NSNumber*number;
	number = [NSNumber numberWithInt:resourceCount_++];
	return number;
}

- (void)webView:(WebView*)sender resource:(id)identifier didFailLoadingWithError:(NSError*)error fromDataSource:(WebDataSource*)dataSource {
	resourceFailedCount_++;
	[self controlSyndicator];
}

- (void)webView:(WebView*)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource*)dataSource {
    resourceCompletedCount_++;
	[self controlSyndicator];
}

- (void) view:(id)view didDrawInRect:(CGRect)rect duration:(float)duration {
}

- (void) view:(id)view didSetFrame:(CGRect)currentRect oldFrame:(CGRect)oldRect {
	CGSize size = CGSizeMake( 320, currentRect.size.height );
	[scroller_ setContentSize:size];
	[scroller_ setOffset:CGPointMake(0,0)];
}

// method
- (void) controlSyndicator {
	int  downloadedCount = resourceCompletedCount_ + resourceFailedCount_;
	if( downloadedCount == resourceCount_ ) {
		[UIApp hideProgressHUD];
	}
}

- (void) pageForward {
	NSString *html = [[parentController_ datFile] getForwardPage];
	if( html )
		[uiWebView_ loadHTMLString:html baseURL:nil];
}

- (void) pageBackward {
	NSString *html = [[parentController_ datFile] getBackwardPage];
	if( html )
		[uiWebView_ loadHTMLString:html baseURL:nil];
}

- (void) setupWebView {
	// create WebView
	uiWebView_ = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)] autorelease];
	[uiWebView_ setDelegate:self];
	[[uiWebView_ webView] setPolicyDelegate:parentController_/*self*/];
	[uiWebView_ setTilingEnabled: YES];
	[uiWebView_ setTileSize: CGSizeMake(320,500)];
	[uiWebView_ setAutoresizes: YES];
	
	[scroller_ addSubview:uiWebView_];
	
	// set delegate
	id webView = [uiWebView_ webView];
	[webView setResourceLoadDelegate:self];
	
	id preferences = [webView preferences];
	DNSLog( @"size %d", [preferences defaultFontSize] );
	[preferences setDefaultFontSize:16];
	
	[webView setDownloadDelegate:self];
	[webView setFrameLoadDelegate:self];
	[uiWebView_ setMaxTileCount:40];
}

- (void) reload {
	[[parentController_ datFile] startDownload];
}

- (void) openThreadView:(NSNotification *)notification {
	NSString *str = [[parentController_ datFile] getCurrentPage];
	
	[uiWebView_ removeFromSuperview];
	[self setupWebView];
	[uiWebView_ loadHTMLString:str baseURL:nil];
	
	[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilForwardToView"
				object:self];
}

- (void) lostFocus:(id) fp {
	DNSLog( @"ThreadView - lost focus" );
}

- (void) load:(NSString*)str {
}
/*
- (void)postNotificationName:(NSString *) n {
	[[NSNotificationCenter defaultCenter] postNotificationName:n object:self];
}
*/
@end
