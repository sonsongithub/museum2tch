//
//  SNWebBrowser.m
//  2tch
//
//  Created by sonson on 08/12/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNWebBrowser.h"

UIWebView* webViewForReuse = nil;

@implementation SNWebBrowser

#pragma mark Class method

- (id) initWithoutRootViewController {
	DNSLogMethod
	UIViewController *controller = [[UIViewController alloc] initWithNibName:nil bundle:nil];
	self = [super initWithRootViewController:controller];
	
	if( webViewForReuse == nil ) {
		DNSLog( @"alloc webview" );
		webViewForReuse = [[UIWebView alloc] initWithFrame:CGRectZero];
		webViewForReuse.detectsPhoneNumbers = NO;
		webViewForReuse.backgroundColor = [UIColor whiteColor];
		webViewForReuse.scalesPageToFit = YES;
		webViewForReuse.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		webView_ = webViewForReuse;
	}
	else {
		DNSLog( @"reuse webview" );
		webView_ = webViewForReuse;
	}
	UIToolbar* bar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 372, 320, 44)];
	bar.barStyle = UIBarStyleBlackOpaque;
	[controller.view addSubview:bar];
	[bar release];
	
	webView_.delegate = self;
	webView_.frame = CGRectMake( 0, 0, 320, 416);
	[controller.view addSubview:webView_];
	[controller release];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *flexibleSpace;	
	backButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushBackButton:)];
	[items addObject:backButton_];
	backButton_.enabled = NO;
	[backButton_ release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	forwardButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Forward.png"] style:UIBarButtonItemStylePlain  target:self action:@selector(pushForwardButton:)];
	[items addObject:forwardButton_];
	forwardButton_.enabled = NO;
	[forwardButton_ release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	imageButton_= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downloadImage.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushImageButton:)];
	[items addObject:imageButton_];
	imageButton_.enabled = NO;
	[safariButton_ release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:flexibleSpace];
	[flexibleSpace release];
	
	safariButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSafariButton:)];
	[items addObject:safariButton_];
	safariButton_.enabled = NO;
	[safariButton_ release];
	
	[bar setItems:items];
	[items release];
	
	UIBarButtonItem*	closeButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Close" ) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
	controller.navigationItem.rightBarButtonItem = closeButton;
	[closeButton release];
	
	self.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	return self;
}

- (void)pushBackButton:(id)sender {
	DNSLogMethod
	[webView_ goBack];
}

- (void)pushForwardButton:(id)sender {
	DNSLogMethod
	[webView_ goForward];
}

- (void)pushImageButton:(id)sender {
	DNSLogMethod
	DNSLog( [webView_.request.URL absoluteString] );
	[UIAppDelegate openHUDOfString:LocalStr( @"Downloading..." )];
	//NSURL* url = [NSURL URLWithString:@"http://www.yahoo.co.jp"];
	NSURL* url = [NSURL URLWithString:[webView_.request.URL absoluteString]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if( error ) {
		[UIAppDelegate closeHUD];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"ImageSaving" )
														message:[error localizedDescription]
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
		return;
	}
	
	UIImage *img = [UIImage imageWithData:data];
	if( img == nil ) {
		[UIAppDelegate closeHUD];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"ImageSaving" )
														message:LocalStr( @"FailedDecodingImage" )
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
		return;
	}
	
	UIImageWriteToSavedPhotosAlbum( img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil );
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	DNSLogMethod
	[UIAppDelegate closeHUD];
	if( error == nil ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"ImageSaving" ) message:LocalStr( @"HasSaved" )
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"ImageSaving" ) message:[error localizedDescription]
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
	}
}

- (BOOL)isImageURL:(NSString*)imageURL {
	DNSLogMethod
	if( [imageURL length] < 4 )
		return NO;
	NSArray* extentions = [[NSArray alloc] initWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", nil];
	NSString* last = [imageURL substringWithRange:NSMakeRange([imageURL length]-4, 4)];
	DNSLog( @"%@", last );
	for( NSString *extention in extentions ) {
		if( [last rangeOfString:extention].location != NSNotFound ) {
			[extentions release];
			return YES;
		}
	}
	[extentions release];
	return NO;
}

- (void)pushSafariButton:(id)sender {
	DNSLogMethod
	DNSLog( [webView_.request.URL absoluteString] );
	[[UIApplication sharedApplication] openURL:webView_.request.URL];
}

- (void)updateButton {
	DNSLogMethod
	backButton_.enabled = [webView_ canGoBack];
	forwardButton_.enabled = [webView_ canGoForward];
}

- (void)pushCloseButton:(id)sender {
	DNSLogMethod
	[self dismissModalViewControllerAnimated:YES];
}

- (void)openURLString:(NSString*)url {
	DNSLogMethod
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[webView_ loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	DNSLogMethod
	imageButton_.enabled = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DNSLogMethod
	[self updateButton];
	imageButton_.enabled = [self isImageURL:[webView_.request.URL absoluteString]];
	safariButton_.enabled = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.visibleViewController.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DNSLogMethod
	[self updateButton];
	safariButton_.enabled = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.visibleViewController.title = LocalStr( @"Error" );
}

- (void) dealloc {
	DNSLogMethod
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	webView_.delegate = nil;
	[webView_ loadHTMLString:@"" baseURL:nil];
	[super dealloc];
}

@end
