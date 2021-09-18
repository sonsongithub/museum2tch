//
//  ThreadRenderingView.m
//  2tch
//
//  Created by sonson on 08/12/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadRenderingView.h"
#import "ThreadViewController.h"
#import "DatParser.h"

@implementation ThreadRenderingView

@synthesize mainDelegate = mainDelegate_;

- (void)setMainDelegate:(id)newValue {
	if( newValue == nil ) {
		mainDelegate_ = nil;
		[self loadHTMLString:@"" baseURL:nil];
	}
	else {
		mainDelegate_ = newValue;
	}
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.delegate = self;
    }
    return self;
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	DNSLogMethod
	if( navigationType != UIWebViewNavigationTypeLinkClicked )
		return YES;
	else {
		NSDictionary *link2ch;
		if( [[[request URL] scheme] isEqualToString:@"applewebdata"] ) {
			DNSLog( @"click anchor" );
			[mainDelegate_ openAnchor:[DatParser getNumbers:[[request URL] absoluteString]]];
			return NO;
		}
		else if( [self isIt2ch:[[request URL] absoluteString] toDictionary:&link2ch] ) {
			DNSLog( @"2ch link" );
			[mainDelegate_ open2chLinkwithPath:[link2ch objectForKey:@"path"] dat:[[link2ch objectForKey:@"dat"] intValue]];
			return NO;
		}
		else {
			DNSLog( @"normal link - %@", [[request URL] absoluteString] );
			[mainDelegate_ openWebBrowser:[[request URL] absoluteString]];
			return NO;
		}
	}
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	DNSLogMethod
	if( [string length] > 0 ) {
		[UIAppDelegate openHUDOfString:NSLocalizedString( @"Loading", nil )];
	}
	[super loadHTMLString:string baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DNSLogMethod
	[UIAppDelegate closeHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DNSLogMethod
	[UIAppDelegate closeHUD];
}

- (void)dealloc {
    [super dealloc];
}

@end
