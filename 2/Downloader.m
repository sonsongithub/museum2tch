
#import "Downloader.h"
#import "global.h"

@implementation Downloader

// for debug
- (BOOL) respondsToSelector:(SEL) selector {
	DNSLog(@"[Downloader] respondsToSelector: %s", selector);
	return [super respondsToSelector:selector];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DNSLog( @"Downloader - dealloc" );
	[self cancel];
	[super dealloc];
}

- (id) initWithDelegate:(id)fp{
	DNSLog( @"Downloader - initWithDelegate:" );
	self = [super init];
	isDownloading_ = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(cancel)
			name:@"wiilBackToView"
			object:nil];
	delegate_ = fp;	
	return self;
}

- (void) startWithURL:(NSString*)url {
	//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	[url_ release];
	url_ = [[NSString stringWithString:url] retain];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:@"Monazilla/1.00 (iphone/0.00)" forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
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
	[UIApp setStatusBarShowsProgress:YES];
}

- (void) startWithURL:(NSString*)url andLastModifiedDataAndSize:(id)dict {
	
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
	
	NSString* rangeStr = [NSString stringWithFormat:@"bytes=%@-", [dict objectForKey:@"size"]];
	[theRequest setValue:rangeStr forHTTPHeaderField: @"Range"];
	[theRequest setValue:[dict objectForKey:@"Last-Modified"] forHTTPHeaderField: @"If-Modified-Since"];

	// alloc NSMutableData to save the downloaded data
	data_ = [[NSMutableData data] retain];
	
	// start downloading
	connection_ = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	isDownloading_ = YES;
	[UIApp setStatusBarShowsProgress:YES];
}

- (void) cancel {
	if( isDownloading_ ) {
		DNSLog( @"Downloader - cancel" );
		[connection_ cancel];
		[data_ release];
		isDownloading_ = NO;
		[UIApp setStatusBarShowsProgress:NO];
	}
}

- (void)outputResponse:(NSURLResponse *)response {
	int i;
	NSDictionary	*requestDict = [(NSHTTPURLResponse *) response allHeaderFields]; 
	NSArray			*values = [requestDict allValues];
	NSArray			*keys = [requestDict allKeys];
	DNSLog( @"Response------------------------------------------------------------" );
	for( i = 0; i < [values count]; i++ ) {
		NSString* key = [keys objectAtIndex:i];
		DNSLog( @"%@ = %@", key, [requestDict valueForKey:key] );
	}
	DNSLog( @"--------------------------------------------------------------------" );
}

- (int)getContentLength:(NSURLResponse *)response {
	NSDictionary*requestDict = [(NSHTTPURLResponse *) response allHeaderFields];
	return [[requestDict valueForKey:@"Content-Length"] intValue]; 
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	response_ = response;
	
	if( ![[[response URL] absoluteString] isEqualToString: url_] ) {
		[UIApp hideProgressHUD];
		[connection_ cancel];
		[data_ release];
		[UIApp setStatusBarShowsProgress:NO];
		isDownloading_ = NO;
		if( [delegate_ respondsToSelector:@selector(didFailLoadging:)] )
			[delegate_ didFailLoadging:@"Error redirect other page"];

		id alertButton = [NSArray arrayWithObjects:@"Close",nil];
		id alert = [[UIAlertSheet alloc] initWithTitle:@"2tch" buttons:alertButton defaultButtonIndex:0 delegate:UIApp context:nil];
		[alert setBodyText:NSLocalizedString( @"downloadFailMessage", nil )];
		[alert popupAlertAnimated: TRUE];
	
	}
	
//	[self outputResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[data_ appendData:data];
	DNSLog( @"Already downloaded - %dbyte", [data_ length] );
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DNSLog( @"Finish loading - %dbyte", [data_ length] );
	
	if( [delegate_ respondsToSelector:@selector(didFinishLoadging:)] ) {
		[self outputResponse:response_];
		[delegate_ didFinishLoadging:self];
	}

	[data_ release];
	[UIApp setStatusBarShowsProgress:NO];
	isDownloading_ = NO;
}

- (id) data {
	return data_;
}

- (id) response {
	return response_;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DNSLog( @"Fail loadgin - %@", [error localizedDescription] );
	
	[data_ release];
	[UIApp setStatusBarShowsProgress:NO];
	isDownloading_ = NO;
	
	if( [delegate_ respondsToSelector:@selector(didFailLoadging:)] )
		[delegate_ didFailLoadging:[error localizedDescription]];
}

@end
