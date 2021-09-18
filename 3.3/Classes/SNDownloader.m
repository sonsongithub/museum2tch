//
//  SNDownloader.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNDownloader.h"
#import "_tchAppDelegate.h"
#import "MainNavigationController.h"

@implementation SNURLConnection

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
	DNSLogMethod
	self = [super initWithRequest:request delegate:delegate];
	delegate_ = [delegate retain];
	return self;
}

- (void)dealloc {
	DNSLogMethod
	[delegate_ release];
	[super dealloc];
}

@end

@implementation SNDownloader

+ (NSMutableURLRequest*)defaultRequestWithURLString:(NSString*)urlString {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
	[request setValue:NSLocalizedString( @"User-Agent", nil ) forHTTPHeaderField: @"User-Agent"];
	[request setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[request setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[request setValue:@"identity" forHTTPHeaderField: @"Accept-Encoding"];
	//[theRequest setValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
	[request setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[request setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[request setValue:@"close" forHTTPHeaderField: @"Connection"];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];			// Important?
	[request setTimeoutInterval:10.0];
	return request;
}

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super init];
	delegate_ = [delegate retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(cancel)
												 name:@"kSNDownloaderCancel"
											   object:delegate_];
	return self;
}

- (void)cancel {
	[connection_ cancel];
//	
//	if( [delegate_ respondsToSelector:@selector(didCancelLoadingResponse:)] ) {
//		[delegate_ didCancelLoadingResponse:httpURLResponse_];
//	}
}

- (void)startWithRequest:(NSURLRequest*)request {
	DNSLogMethod
	connection_ = [[SNURLConnection alloc] initWithRequest:request delegate:self];
	[connection_ release];
	request_ = [request retain];
	data_ = [[NSMutableData alloc] init];
	[self startProgressAnimation];
}

#pragma mark for progress animation

- (void) startProgressAnimation {
	DNSLogMethod
	progressView_ = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 150)];
	progressParentView_ = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 100, 10 )];
	progressView_.progressViewStyle = UIProgressViewStyleBar;
	[progressParentView_ addSubview:progressView_];
	UIAppDelegate.navigationController.topViewController.navigationItem.titleView = progressParentView_;
	progressView_.progress = 0.0;
	[progressView_ release];
}

- (void) stopProgressAnimation {
	UIAppDelegate.navigationController.topViewController.navigationItem.titleView = nil;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DNSLogMethod
	httpURLResponse_ = [(NSHTTPURLResponse*)response retain];
	NSDictionary *headerDict = [httpURLResponse_ allHeaderFields];
	NSDictionary *requestDict = [request_ allHTTPHeaderFields];
	
	// check URL between request and response 
	if( ![[[response URL] absoluteString] isEqualToString:[[request_ URL] absoluteString]]) {
		[connection cancel];
		[self stopProgressAnimation];
		if( [delegate_ respondsToSelector:@selector(didDifferenctURLLoading)] ) {
			[delegate_ didDifferenctURLLoading];
		}
	}
	
	// check length between request and response
	NSString* response_length = [headerDict objectForKey:@"Content-Length"];
	NSString* range_source_string = [requestDict objectForKey:@"Range"];
	NSString* request_length = nil;
	if( range_source_string ) {
		NSString* range_source_string = [requestDict objectForKey:@"Range"];
		request_length = [range_source_string substringWithRange:NSMakeRange( 6, [range_source_string length]-7)];
		DNSLog( request_length );
	}
	
	if( [response_length intValue] == [request_length intValue] ) {
		[connection cancel];
		[self stopProgressAnimation];
		if( [delegate_ respondsToSelector:@selector(didCacheURLLoading)] ) {
			[delegate_ didCacheURLLoading];
		}
	}
	
	if( response_length )
		sizeToRecieve_ = [response_length intValue];
	
#ifdef _DEBUG
	DNSLog( @"Request" );
	for( NSString*key in [[request_ allHTTPHeaderFields] allKeys] ) {
		DNSLog( @" %@ = %@", key, [[request_ allHTTPHeaderFields] valueForKey:key] );
	}
	DNSLog( @"Response" );
	for( NSString*key in [headerDict allKeys] ) {
		DNSLog( @" %@ = %@", key, [headerDict valueForKey:key] );
	}
#endif
	

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[data_ appendData:data];
	progressView_.progress = (float)[data_ length] / (float)sizeToRecieve_;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DNSLogMethod
	DNSLog( @"[SNDownloader] %d/%d byte", [data_ length], sizeToRecieve_ );
	[self stopProgressAnimation];
	
	if( [delegate_ respondsToSelector:@selector(didFinishLoading:response:)] ) {
		[delegate_ didFinishLoading:data_ response:httpURLResponse_];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DNSLogMethod
	DNSLog( @"[SNDownloader] Error:%@", [error localizedDescription] );
	[self stopProgressAnimation];
	if( [delegate_ respondsToSelector:@selector(didFailLoadingWithError:)] ) {
		[delegate_ didFailLoadingWithError:error];
	}
}

- (void) dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[httpURLResponse_ release];
	[delegate_ release];
	[data_ release];
	[request_ release];
	[progressParentView_ release];
	[super dealloc];
}

@end
