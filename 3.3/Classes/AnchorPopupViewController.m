//
//  AnchorPopupViewController.m
//  2tch
//
//  Created by sonson on 08/12/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnchorPopupViewController.h"
#import "ThreadViewController.h"
#import <QuartzCore/QuartzCore.h>

#define POPOUT_IN_DURATION 0.15

// Notification identifier
NSString* kDismissBookmarkViewMsg = @"kDismissBookmarkViewMsg";

// while popuping animation identifier
NSString* kThreadViewPopupCAPopup1 = @"kThreadViewPopupCAPopup1";
NSString* kThreadViewPopupUIViewPopup1 = @"kThreadViewPopupUIViewPopup1";
NSString* kThreadViewPopupCAPopup2 = @"kThreadViewPopupCAPopup2";
NSString* kThreadViewPopupUIViewPopup2 = @"kThreadViewPopupCAPopup2";
NSString* kThreadViewPopupCAPopup3 = @"kThreadViewPopupCAPopup3";
NSString* kThreadViewPopupUIViewPopup3 = @"kThreadViewPopupCAPopup3";

// while popouting animation identifier
NSString* kThreadViewPopupCAPopout = @"kThreadViewPopupCAPopout";
NSString* kThreadViewPopupUIViewPopout = @"kThreadViewPopupUIViewPopout";

UIWebView* webViewAnchorForReuse = nil;

@implementation CancelView
@synthesize delegate = delegate_;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
	[delegate_ cancel];
}
- (void) dealloc {
	DNSLogMethod
	[super dealloc];
}
@end

@implementation ContentView
@synthesize delegate = delegate_;
@end

@implementation AnchorPopupViewController

@synthesize delegate = delegate_;

#pragma mark Original method

- (void)cancel {
	DNSLogMethod
	[UIView beginAnimations:kThreadViewPopupUIViewPopup1 context:nil];
	[UIView setAnimationDidStopSelector:@selector(animationDelegate:finished:context:)];
	[UIView setAnimationDuration:POPOUT_IN_DURATION];
	[UIView setAnimationDelegate:self];
	[contentView setAlpha:0.0f];
	[UIView commitAnimations];
	
	[backgroundCancelView removeFromSuperview];
	[contentView removeFromSuperview];
	
	historyCounter_ = 0;
}

- (void)showInView:(UIView*)view withHTMLSource:(NSString*)htmlString {
	DNSLogMethod
	if( backgroundCancelView.superview == nil ) {
		DNSLog( @"Popup" );
		[resStringBuff_ removeAllObjects];
		[view addSubview:backgroundCancelView];
		[view addSubview:contentView];
	}
	[webView_ loadHTMLString:htmlString baseURL:nil];
	[resStringBuff_ addObject:htmlString];
	
	[self updateBackButton];
}

- (BOOL)isIt2ch:(NSString*)input toDictionary:(NSDictionary**)dict {
	DNSLogMethod
	NSArray*elements = [input componentsSeparatedByString:@"/"];
	if( [elements count] >= 7 ) {
		
		NSString* server = [elements objectAtIndex:2];
		NSString* boardPath = [elements objectAtIndex:5];
		NSString* dat = [elements objectAtIndex:6];
		
		NSArray* serverElements = [server componentsSeparatedByString:@"."];
		
		if( [serverElements count] == 3 ) {
			if( [[serverElements objectAtIndex:1] isEqualToString:@"2ch"] ) {
				*dict = [NSDictionary dictionaryWithObjectsAndKeys:
						 server,		@"server",
						 boardPath,	@"path",
						 dat,			@"dat",
						 nil];
				return YES;
			}
		}
	}
	return NO;
}

#pragma mark Override

- (id)init {
	DNSLogMethod
    if (self = [super init]) {
		if( webViewAnchorForReuse == nil ) {
			DNSLog( @"alloc webview" );
			webViewAnchorForReuse = [[UIWebView alloc] initWithFrame:CGRectZero];
			webViewAnchorForReuse.detectsPhoneNumbers = NO;
			webViewAnchorForReuse.backgroundColor = [UIColor whiteColor];
			webViewAnchorForReuse.scalesPageToFit = NO;
			webViewAnchorForReuse.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			webView_ = webViewAnchorForReuse;
			webView_.delegate = self;
		}
		else {
			DNSLog( @"reuse webview" );
			webView_ = webViewAnchorForReuse;
			webView_.delegate = self;
		}
		
		backgroundCancelView = [[CancelView alloc] initWithFrame:CGRectMake( 0, 0, 320, 480)];
		backgroundCancelView.delegate = self;
		backgroundCancelView.backgroundColor = [UIColor clearColor];
		
		contentView = [[ContentView alloc] initWithFrame:CGRectMake( 0, 0, 200, 300)];
		contentView.delegate = self;
		contentView.backgroundColor = [UIColor clearColor];
		contentView.frame = CGRectMake(0,0, 320*0.8, 460*0.8);
		contentView.center = CGPointMake( 160, 230 );
		
		backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton setImage:[UIImage imageNamed:@"anchorRewind.png"] forState:UIControlStateNormal];
		[backButton setImage:[UIImage imageNamed:@"anchorRewind_dis.png"] forState:UIControlStateDisabled];
		backButton.frame = CGRectMake(0,0,19,22);
		
		UIImage *img =  [UIImage imageNamed:@"anchorBack.png"];
		UIImage *newImg = [img stretchableImageWithLeftCapWidth:27 topCapHeight:27];
		background = [[UIImageView alloc] initWithImage:newImg];
		background.frame = contentView.bounds;
		background.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		webView_.frame = CGRectMake( 0, 0, contentView.frame.size.width - 30, contentView.frame.size.height - 30 - 26 );
		webView_.center = CGPointMake( contentView.frame.size.width * 0.5, contentView.frame.size.height * 0.5 - 13 );
		[contentView addSubview:background];
		[contentView addSubview:webView_];
		[contentView setAlpha:1.0f];
		backButton.center = CGPointMake( contentView.frame.size.width * 0.5, contentView.frame.size.height - 25);
		[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchDown];
		[contentView addSubview:backButton];
		
		resStringBuff_ = [[NSMutableArray alloc] init];
		[self updateBackButton];
    }
    return self;
}

- (void)back:(id)sender {
	DNSLogMethod
	if( [resStringBuff_ count] > 1 ) {
		NSString* prev = [resStringBuff_ objectAtIndex:[resStringBuff_ count]-2];
		[webView_ loadHTMLString:prev baseURL:nil];
		[resStringBuff_ removeLastObject];
	}
	[self updateBackButton];
}
		
- (void)updateBackButton {
	if( [resStringBuff_ count] < 2 ) 
		backButton.enabled = NO;
	else
		backButton.enabled = YES;
}

#pragma mark CoreAnimation Delegate

- (void)animationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	DNSLogMethod
	if( [animationID isEqualToString:kThreadViewPopupUIViewPopup1] ) {
		[backgroundCancelView removeFromSuperview];
		[contentView removeFromSuperview];
	}
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DNSLogMethod
	[UIView beginAnimations:kThreadViewPopupUIViewPopup1 context:nil];
	[UIView setAnimationDuration:POPOUT_IN_DURATION];
	[UIView setAnimationDelegate:self];
	[contentView setAlpha:1.0f];
	[UIView commitAnimations];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	DNSLogMethod
	DNSLog( @"%@", [[request URL] absoluteString] );
	if( navigationType != UIWebViewNavigationTypeLinkClicked )
		return YES;
	else {
		NSDictionary *link2ch;
		if( [[[request URL] scheme] isEqualToString:@"applewebdata"] ) {
			DNSLog( @"click anchor" );
			NSArray *ary = [[[request URL] absoluteString] componentsSeparatedByString:@"/"];
			NSString* res_num = [ary objectAtIndex:[ary count]-1];
			NSArray *res_num_array = [NSArray arrayWithObjects:[NSNumber numberWithInt:[res_num intValue]], nil];
			[delegate_ openAnchor:res_num_array];
			return NO;
		}
		else if( [self isIt2ch:[[request URL] absoluteString] toDictionary:&link2ch] ) {
			DNSLog( @"2ch link" );
			[delegate_ open2chLinkwithPath:[link2ch objectForKey:@"path"] dat:[[link2ch objectForKey:@"dat"] intValue]];
			[self cancel];
			return NO;
		}
		else {
			DNSLog( @"normal link - %@", [[request URL] absoluteString] );
			[delegate_ openWebBrowser:[[request URL] absoluteString]];
			return NO;
		}
	}
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[resStringBuff_ release];
	webView_.delegate = nil;
	[backgroundCancelView release];
	[contentView release];
    [super dealloc];
}


@end
