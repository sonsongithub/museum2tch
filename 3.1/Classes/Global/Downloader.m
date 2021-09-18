//
//  Downloader.m
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "Downloader.h"
#import "_tchAppDelegate.h"
#import "ThreadViewController.h"

@implementation Downloader

@synthesize delegate = delegate_;
@synthesize navitaionItemDelegate = navitaionItemDelegate_;
@synthesize lastResponse = lastResponse_;

#pragma mark Override method

- (void) dealloc {
	DNSLog( @"[Downloader] dealloc" );
	[url_ release];
	[identifier_ release];
	[lastResponse_ release];
	[progressBar_ release];
	[progressBarView_ release];
	[backupTitleString_ release];
	[super dealloc];
}

#pragma mark Original method

- (id) init {
	DNSLog( @"[Downloader] init:" );
	self = [super init];
	isDownloading_ = NO;
	
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
	[theRequest setValue:NSLocalizedString( @"User-Agent", nil ) forHTTPHeaderField: @"User-Agent"];
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
	[theRequest setValue:NSLocalizedString( @"User-Agent", nil ) forHTTPHeaderField: @"User-Agent"];
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
	
	[self startProgressAnimation];
}

- (void) cancelDownload:(NSNotification *)notification {
	DNSLog( @"[Downloader] cancelDownload:" );
	[self cancel];
}

- (void) cancel {
	if( isDownloading_ ) {
		isDownloading_ = NO;
		delegate_ = nil;
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
	
	
	progressBar_ = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 150)];
	progressBarView_ = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 100, 10 )];
	progressBar_.progressViewStyle = UIProgressViewStyleBar;
	[progressBarView_ addSubview:progressBar_];
	
	backupViewController_ = UIAppDelegate.navigationController.topViewController;
	backupTitleView_ = UIAppDelegate.navigationController.topViewController.navigationItem.titleView;
	UIAppDelegate.navigationController.topViewController.navigationItem.titleView = progressBarView_;

	progressBar_.progress = 0.0;
}

- (void) setProgress {
	progressBar_.progress = (float)[data_ length] / (float)dataSizeToReceive_;
}

- (void) stopProgressAnimation {
	
	
	if( [backupViewController_ isKindOfClass:[ThreadViewController class]] && [UIAppDelegate.navigationController.topViewController isKindOfClass:[ThreadViewController class]] ) {
		UIAppDelegate.navigationController.topViewController.navigationItem.titleView = backupTitleView_;
	}
	else {
		UIAppDelegate.navigationController.topViewController.navigationItem.titleView = nil;
	}
	[progressBar_ release];
	[progressBarView_ release];	

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
		if( [delegate_ respondsToSelector:@selector(didFailLoadingWithIdentifier:error:isDifferentURL:)] ) {
			[delegate_ didFailLoadingWithIdentifier:identifier_ error:nil isDifferentURL:NO];
		}
		delegate_ = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[data_ appendData:data];
	[self setProgress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DNSLog( @"[Downloader] connectionDidFinishLoading:" );
	DNSLog( @"[Downloader] - Download has finished - %d/%dbyte", [data_ length], dataSizeToReceive_ );
	isDownloading_ = NO;
	[self stopProgressAnimation];
	if( [delegate_ respondsToSelector:@selector(didFinishLoading:identifier:)] ) {
		[delegate_ didFinishLoading:data_ identifier:identifier_];
	}
	[data_ release];
	delegate_ = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DNSLog( @"[Downloader] connection:didFailWithError: - %@", [error localizedDescription] );
	isDownloading_ = NO;
	[self stopProgressAnimation];
		
	if( [delegate_ respondsToSelector:@selector(didFailLoadingWithIdentifier:error:isDifferentURL:)] ) {
		[delegate_ didFailLoadingWithIdentifier:identifier_ error:error isDifferentURL:NO];
	}
	[data_ release];
	delegate_ = nil;
}


@end
