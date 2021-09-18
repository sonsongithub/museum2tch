//
//  ThreadViewPopupRes.m
//  2tchfree
//
//  Created by sonson on 08/08/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "ThreadViewPopupRes.h"
#import "ThreadViewPopupImage.h"
#import "_tchAppDelegate.h"
#import "ThreadViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ThreadViewPopupRes

#pragma mark Original method

- (void) setRes:(NSArray*)ary {
	
	NSMutableString *buff = [NSMutableString string];
	
	[buff appendString:@"<html><head>"];
	[buff appendString:@"<STYLE TYPE=\"text/css\"><!--"];
	[buff appendString:@"body{font-weight:bold;background-color:transparent;margin:0;padding:0;width:246px;}"];
//	[buff appendString:@"body{font-weight:bold;background-color:#3A4E6B;margin:0;padding:0;width:236px;}"];
//	[buff appendString:@"body{font-weight:bold;background-color:#FFFFFF;margin:0;padding:0;width:236px;}"];
	[buff appendString:@"a:link{ color: #ccccff; }"];
	
	[buff appendString:@"p{margin:0;padding:0;font-size: 75%%;width:230px;}"];
	[buff appendString:@"div.entry{}"];
	[buff appendString:@"div.info{font-size: 75%%;width: 236px;color:#ffffff;margin:0 0 0 0;padding:3 0 3 5;}"];
	[buff appendString:@"div.body{font-size: 85%%;width: 220px;color:#ffffff;margin:0;padding:10 5 10 5;}"];
	[buff appendString:@"--></STYLE>"];
	[buff appendString:@"</head><body>"];
	
	for( NSNumber *num in ary ) {
		int a = [num intValue]-1;
		if( a >= 0 && a < [UIAppDelegate.threadDat.resList count] ) {
			NSDictionary *dict = [UIAppDelegate.threadDat.resList objectAtIndex:a];
			
			[buff appendFormat:@"<div id=\"r%d\" onMouseDown=\"clicked(%d)\">",a+1,a+1];
			[buff appendFormat:@"<div class=\"info\">",a+1,a+1];
			[buff appendFormat:@"%d %@ %@", a+1, [dict objectForKey:@"name"], [dict objectForKey:@"date_id"]];
			[buff appendString:@"</div>"];
			[buff appendString:@"</div>"];
			
			[buff appendString:@"<div class=\"body\">"];
			[buff appendString:[dict objectForKey:@"body"]];		
			[buff appendString:@"</div>"];
		}
	}
	[buff appendString:@"</body></html>"];
	
	[webView_ loadHTMLString:buff baseURL:nil];
}

#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		float webView_width = frame.size.width * 0.95;
		float webView_height = frame.size.height * 0.95;
		CGRect webView_rect = CGRectMake( ( frame.size.width - webView_width )/2+0.5, ( frame.size.height - webView_height )/2+0.5, webView_width, webView_height );
		webView_ = [[UIWebView alloc] initWithFrame:webView_rect];
		webView_.backgroundColor = [UIColor clearColor];
		webView_.detectsPhoneNumbers = NO;
		webView_.delegate = self;
		webView_.scalesPageToFit = NO;
		webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		//webView_.opaque = NO;
    }
    return self;
}

- (void)dealloc {
	[webView_ release];
    [super dealloc];
}

#pragma mark UIWebViewDelegate

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *str = [[request URL] absoluteString];
	NSString *url = str;
	NSString *extentionOfURL = [url substringWithRange:NSMakeRange([url length]-3, 3)];
	//	DNSLog( @"pop up?" );
	
	if( navigationType != UIWebViewNavigationTypeLinkClicked )
		return YES;
	else {
		if( [[[request URL] scheme] isEqualToString:@"applewebdata"] ) {
			//	DNSLog( @"pop up? - %@", str );
			NSArray *ary = [str componentsSeparatedByString:@"/"];
			NSString* res_num = [ary objectAtIndex:[ary count]-1];
			
			NSArray *res_num_array = [NSArray arrayWithObjects:[NSNumber numberWithInt:[res_num intValue]], nil];
			
			[self setRes:res_num_array];
			return NO;
		}
		else if( [[[request URL] scheme] isEqualToString:@"http"] ) {
			DNSLog(@"[UIWebViewNavigationTypeLinkClicked] URL->%@\n", str);
			NSDictionary* dict = isURLOf2ch(str);
			
			if( dict ) {
				UIViewController* con = [UIAppDelegate.navigationController visibleViewController];
				if( [con isKindOfClass:[ThreadViewController class]] ) {
					[(ThreadViewController*)con openThreadWithBoardPath:[dict objectForKey:@"boardPath"] dat:[dict objectForKey:@"dat"] title:nil];
					[self cancel];
				}
				return NO;
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
				[extentions release];
				if( isImage ) {
					CGRect rect = [self superview].frame;
					rect.size.width *= 0.8;
					rect.size.height *= 0.8;
					ThreadViewPopupImage* pop = [[ThreadViewPopupImage alloc] initWithFrame:rect];
					//	memoryWarningDelegate_ = pop;
					[pop setImageWithURL:url];
					[pop popupInView:[self superview]];
					[pop release];
					return NO;
				}
			}
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"AreYouSureToOpenWithSafari", nil) message:str
														   delegate:self cancelButtonTitle:NSLocalizedString( @"Cancel", nil) otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
			[alert show];
			[alert release];
			return NO;
		}
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self addSubview:webView_];
}

- (void)threadViewPopupUIViewAnimationDelegate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[super threadViewPopupUIViewAnimationDelegate:animationID finished:finished context:context];
	if( finished && [animationID isEqualToString:kThreadViewPopupUIViewPopup2] ) {
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 1 ) {
		[UIApp openURL:[NSURL URLWithString:actionSheet.message]];
	}
}


@end
