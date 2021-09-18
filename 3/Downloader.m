//
//  Downloader.m
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "Downloader.h"

@implementation Downloader

@synthesize navitaionItemDelegate = navitaionItemDelegate_;
@synthesize lastResponse = lastResponse_;

/*
// for debug
- (BOOL) respondsToSelector:(SEL) selector {
	return [super respondsToSelector:selector];
}
*/

#pragma mark Override method

- (void) dealloc {
	DNSLog( @"[Downloader] dealloc" );
	[url_ release];
	[identifier_ release];
	[lastResponse_ release];
	[super dealloc];
}

#pragma mark Original method

- (id) initWithDelegate:(id)fp{
	DNSLog( @"[Downloader] initWithDelegate:" );
	self = [super init];
	isDownloading_ = NO;
	
	delegate_ = fp;
	return self;
}

- (void) startWithURL:(NSString*)url identifier:(NSString*)identifier {
	DNSLog( @"[Downloader] startWithURL:" );
	[identifier_ release];
	identifier_ = [[NSString stringWithString:identifier] retain];

	[url_ release];
	url_ = [[NSString stringWithString:url] retain];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:@"Monazilla/1.00 (iphone/0.00)" forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"identity" forHTTPHeaderField: @"Accept-Encoding"];
	//[theRequest setValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
	[theRequest setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[theRequest setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[theRequest setValue:@"close" forHTTPHeaderField: @"Connection"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];			// Important?
	[theRequest setTimeoutInterval:10.0];
	
	// alloc NSMutableData to save the downloaded data
	data_ = [[NSMutableData data] retain];
	
	// start downloading
	connection_ = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	isDownloading_ = YES;
	[self startProgressAnimation];
}


- (void) startWithURL:(NSString*)url lastModified:(NSString*)lastModified size:(int)length identifier:(NSString*)identifier {
	DNSLog( @"[Downloader] startWithURL:lastModified:size:identifier:" );
	
	[identifier_ release];
	identifier_ = [[NSString stringWithString:identifier] retain];
	
	[url_ release];
	url_ = [[NSString stringWithString:url] retain];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:@"Monazilla/1.00 (iphone/0.00)" forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"identity" forHTTPHeaderField: @"Accept-Encoding"];
	[theRequest setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[theRequest setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[theRequest setValue:@"close" forHTTPHeaderField: @"Connection"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData]; // Important
	[theRequest setTimeoutInterval:10.0];
	
	NSString* rangeStr = [NSString stringWithFormat:@"bytes=%d-", length];
	
	[theRequest setValue:rangeStr forHTTPHeaderField: @"Range"];
	[theRequest setValue:lastModified forHTTPHeaderField: @"If-Modified-Since"];
	
	// alloc NSMutableData to save the downloaded data
	data_ = [[NSMutableData data] retain];
	
	// start downloading
	connection_ = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	isDownloading_ = YES;
}

- (void) startWithURL:(NSString*)url lastModifiedDataAndSize:(id)dict identifier:(NSString*)identifier {
	DNSLog( @"[Downloader] startWithURL:lastModifiedDataAndSize:identifier:" );
	
	[identifier_ release];
	identifier_ = [[NSString stringWithString:identifier] retain];
	
	[url_ release];
	url_ = [[NSString stringWithString:url] retain];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:@"Monazilla/1.00 (iphone/0.00)" forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"identity" forHTTPHeaderField: @"Accept-Encoding"];
	[theRequest setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[theRequest setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[theRequest setValue:@"close" forHTTPHeaderField: @"Connection"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData]; // Important
	[theRequest setTimeoutInterval:10.0];
	
	NSString* rangeStr = [NSString stringWithFormat:@"bytes=%@-", [dict objectForKey:@"Content-Length"]];
	[theRequest setValue:rangeStr forHTTPHeaderField: @"Range"];
	[theRequest setValue:[dict objectForKey:@"Last-Modified"] forHTTPHeaderField: @"If-Modified-Since"];
	
	// alloc NSMutableData to save the downloaded data
	data_ = [[NSMutableData data] retain];
	
	// start downloading
	connection_ = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	isDownloading_ = YES;
}

- (void) cancelDownload:(NSNotification *)notification {
	DNSLog( @"[Downloader] cancelDownload:" );
	[self cancel];
}

- (void) cancel {
	if( isDownloading_ ) {
		isDownloading_ = NO;
		DNSLog( @"[Downloader] cancel - identifier:%@", identifier_ );
		[self stopProgressAnimation];
		[connection_ cancel];
		[data_ release];
	}
}

- (int)getContentLength:(NSURLResponse *)response {
	NSDictionary*requestDict = [(NSHTTPURLResponse *) response allHeaderFields];
	return [[requestDict valueForKey:@"Content-Length"] intValue]; 
}

- (void)outputResponse:(NSURLResponse *)response {
	int i;
	NSDictionary	*requestDict = [(NSHTTPURLResponse *) response allHeaderFields]; 
	NSArray			*values = [requestDict allValues];
	NSArray			*keys = [requestDict allKeys];
	DNSLog( @"[Downloader] Response------------------------------------------------------------" );
	for( i = 0; i < [values count]; i++ ) {
		NSString* key = [keys objectAtIndex:i];
		DNSLog( @"[Downloader] %s = %s", [key UTF8String], [[requestDict valueForKey:key] UTF8String] );
		
		if( [key isEqualToString:@"Content-Length"] ) {
			sscanf( [[requestDict valueForKey:key] UTF8String], "%d", &dataSizeToReceive_ );
		}
	}
	DNSLog( @"[Downloader] --------------------------------------------------------------------" );
}

#pragma mark for progress animation

- (void) startProgressAnimation {
	DNSLog( @"[MyNavigationController] start:" );
	
	CGRect frame;
	frame = CGRectMake(0.0, 0.0, 100, 150);
	progressBar_ = [[UIProgressView alloc] initWithFrame:frame];
	progressBar_.progressViewStyle =  UIProgressViewStyleDefault;
	progressBarView_ = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 100, 10 )];
	[progressBarView_ addSubview:progressBar_];
	navitaionItemDelegate_.titleView = progressBarView_;
	progressBar_.progress = 0.0;
	
	frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	UIActivityIndicatorView *progressView = [[[UIActivityIndicatorView alloc] initWithFrame:frame] autorelease];
	progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									 UIViewAutoresizingFlexibleRightMargin |
									 UIViewAutoresizingFlexibleTopMargin |
									 UIViewAutoresizingFlexibleBottomMargin);

	[(UIActivityIndicatorView *)navitaionItemDelegate_.rightBarButtonItem.customView startAnimating];

	UIApplication *app =[UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (void) setProgress {
	progressBar_.progress = (float)[data_ length] / (float)dataSizeToReceive_;
	DNSLog( @"[Downloader] - Already downloaded - %d/%d byte - %3.0f%%", [data_ length], dataSizeToReceive_, (float)[data_ length] / (float)dataSizeToReceive_*100.0f );
}

- (void) stopProgressAnimation {
	[progressBar_ release];
	progressBar_ = nil;
	[progressBarView_ release];
	progressBarView_= nil;
	navitaionItemDelegate_.titleView = nil;
	
	UIApplication *app =[UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
}

#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DNSLog( @"[Downloader] connection:didReceiveResponse:" );
	[lastResponse_ release];
	lastResponse_ = [response copy];
	[self outputResponse:response];
	if( ![[[response URL] absoluteString] isEqualToString: url_] ) {
		DNSLog( @"[Downloader] - Error:different URL was loaded" );
		
		[connection_ cancel];
		[data_ release];
		isDownloading_ = NO;
		[self stopProgressAnimation];
		if( [delegate_ respondsToSelector:@selector(didFailLoadingWithIdentifier:)] ) {
			[delegate_ didFailLoadingWithIdentifier:identifier_ isDifferentURL:YES];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[data_ appendData:data];
	[self setProgress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DNSLog( @"[Downloader] connectionDidFinishLoading:" );
	isDownloading_ = NO;
	if( [delegate_ respondsToSelector:@selector(didFinishLoading:identifier:)] ) {
		[delegate_ didFinishLoading:data_ identifier:identifier_];
	}
	[self stopProgressAnimation];
	[data_ release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DNSLog( @"[Downloader] connection:didFailWithError: - %@", [error localizedDescription] );
	isDownloading_ = NO;
		
	if( [delegate_ respondsToSelector:@selector(didFailLoadingWithIdentifier:error:isDifferentURL:)] ) {
		[delegate_ didFailLoadingWithIdentifier:identifier_ error:error isDifferentURL:NO];
	}
	[self stopProgressAnimation];
	[data_ release];
}


@end
