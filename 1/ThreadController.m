
#import "ThreadController.h"
//#import "DataDecoder.h"
//#import "HTMLEliminator.h"

@implementation ThreadController

// override

- (void) dealloc {
	DNSLog( @"ThreadController - dealloc" );
	[dataPath_ release];
	[cachePath_ release];
	[bookmarkPath_ release];
	[url_ release];
	[super dealloc];
}

// original method

- (id) initWithURLString:(NSString*)url {
	DNSLog( @"ThreadController - initWithURLString:" );
	self = [super init];
	NSArray* lines = [url componentsSeparatedByString:@"/"];	 
	NSString* preferencePath = [UIApp preferencePath];
	NSString* threadFileName = [lines objectAtIndex:[lines count]-1];
	NSString* threadDataName = [NSString stringWithFormat:@"%@.data", [lines objectAtIndex:[lines count]-1]];
	NSString* bookmarkFileName = [NSString stringWithFormat:@"%@.bmk", [lines objectAtIndex:[lines count]-1]];
	NSString* directoryName = [lines objectAtIndex:[lines count]-3];
	
	NSString* cacheDirectory = [NSString stringWithFormat:@"%@/%@", preferencePath, directoryName ];
	[[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory attributes:nil];
	
	dataPath_ = [[NSString stringWithFormat:@"%@/%@/%@", preferencePath, directoryName, threadDataName] retain];
	cachePath_ = [[NSString stringWithFormat:@"%@/%@/%@", preferencePath, directoryName, threadFileName] retain];
	bookmarkPath_ = [[NSString stringWithFormat:@"%@/%@/%@", preferencePath, directoryName, bookmarkFileName] retain];
	url_ = [[NSString stringWithString:url] retain];
	
	return self;
}

- (BOOL) updateDatFile {
	// confirm if existing the cache file and data file
	if( [[NSFileManager defaultManager] fileExistsAtPath:dataPath_ isDirectory:nil] && [[NSFileManager defaultManager] fileExistsAtPath:cachePath_ isDirectory:nil] ) {
		return [self reloadCacheFile];
	}
	else {
		return [self downloadNewCacheFile];
	}
}

- (NSMutableURLRequest*) makeRequestForAddtionalDownload {
	NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_] ];
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
	return theRequest;
}

- (NSMutableURLRequest*) makeRequestForNewDownload {
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:@"Monazilla/1.00 (iphone/0.00)" forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
	[theRequest setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[theRequest setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[theRequest setValue:@"close" forHTTPHeaderField: @"Connection"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[theRequest setTimeoutInterval:10.0];
	return theRequest;
}

- (NSDictionary*) readDatFileFromLocal {
	// read data file
	NSData *dataFromDataFile = [NSData dataWithContentsOfFile:dataPath_];
	// decode
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *stringFromDataFile = [decoder decodeNSData:dataFromDataFile];
	NSString *stringFromDataFile = decodeNSData(dataFromDataFile);
	// divide lines
	NSArray *values = [stringFromDataFile componentsSeparatedByString:@"\n"];
	
	if( [values count] != 2 ) {
		DNSLog( @"ThreadController - confirm number of lines" );
		return nil;
	}
	
	int cacheSize = [[values objectAtIndex:0] intValue];
	NSString *lastModifiedDate = [values objectAtIndex:1];
	
	// check data
	if( cacheSize <= 0 || !lastModifiedDate )
		return nil;

	// read values
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
					[values objectAtIndex:0],		@"cache",
					[values objectAtIndex:1],		@"lastModifiedDate",
					nil];
	return dict;
}

- (BOOL) checkDownloadedData:(NSData*)data {
	// decode NSData into NSString
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *decodedString = [decoder decodeNSData:data];
	NSString *decodedString = decodeNSData(data);
	
	// check available NSString
	if( decodedString == nil ) {
		DNSLog( @"ThreadController - decoding was failed" );
		return NO;
	}
		
	// check download data is available
	if( ![self checkHTMLHeader:decodedString] ) {
		DNSLog( @"ThreadController - maybe subject.txt file isn't correct" );
		return NO;
	}
	return YES;
}

- (BOOL) checkHTMLHeader:(NSString*)str {
	DNSLog( @"ThreadController - checkHTMLHeader:" );
	if( [str length] < 6 ) {
		DNSLog( @"ThreadController - %@", str );
		return NO;
	}
	NSString *first4Chars = [str substringWithRange:NSMakeRange( 0, 6 )];
	DNSLog( @"ThreadController - %@", first4Chars );
	if( [first4Chars isEqualToString:@"<html>"] )
		return NO;
	if( [first4Chars isEqualToString:@"<HTML>"] )
		return NO;
	if( [first4Chars isEqualToString:@"<head>"] )
		return NO;
	if( [first4Chars isEqualToString:@"<!DOCT"] )
		return NO;
	return YES;
}

- (BOOL) reloadCacheFile {
	DNSLog( @"ThreadController - reloadCacheFile" );
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = nil;
	
	// read data file
	NSDictionary* data_dict = [self readDatFileFromLocal];
	if( data_dict == nil ) {
		DNSLog( @"ThreadController - data file is wrong" );
		return NO;
	}
	
	// make request
	NSMutableURLRequest *theRequest = [self makeRequestForAddtionalDownload];
	NSString* rangeStr = [NSString stringWithFormat:@"bytes=%@-", [data_dict objectForKey:@"cache"]];
	[theRequest setValue:rangeStr forHTTPHeaderField: @"Range"];
	[theRequest setValue:[data_dict objectForKey:@"lastModifiedDate"] forHTTPHeaderField: @"If-Modified-Since"];
	
	DNSLog( rangeStr );
	
	// download
	if( [UIApp isOfflineMode] )
		data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	else
		data = [NSData data];
	// check result of download
	if( [data length] <= 0 || ![[[response URL] absoluteString] isEqualToString: url_] )
		return NO;
		
	if( ![self checkDownloadedData:data] )
		return NO;
	
	[self saveData:data andInformation:response];
	
	return YES;
}

- (BOOL) saveData:(NSData*)data andInformation:(NSURLResponse*)response {
	// conbine and save cache file
	NSMutableData *previousData = [NSMutableData dataWithContentsOfFile:cachePath_];
	[previousData appendData:data];
	[previousData writeToFile:cachePath_ atomically:NO];
	// save information of thread data
	NSDictionary *requestDict = [(NSHTTPURLResponse *)response allHeaderFields];
	NSString *Last_Modified = [requestDict objectForKey:@"Last-Modified"];
	NSString *buffToSaveFile = [NSString stringWithFormat:@"%d\n%@", [previousData length], Last_Modified];
	[buffToSaveFile writeToFile:dataPath_ atomically:NO encoding:NSUTF8StringEncoding error:nil];
	return YES;
}

- (BOOL) downloadNewCacheFile {
	DNSLog( @"ThreadController - downloadNewCacheFile" );
	NSData *data = nil;
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSDictionary *requestDict = nil;
	NSMutableURLRequest *theRequest = [self makeRequestForNewDownload];
	
	if( [UIApp isOfflineMode] )
		data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	else
		data = [NSData data];

	if( ![[[response URL] absoluteString] isEqualToString: url_] || [data length] == 0)
		return NO;
	
	if( ![self checkDownloadedData:data] )
		return NO;
		
	// write cache file
	[data writeToFile:cachePath_ atomically:NO];
	// write data file which contains last modified day and file size.
	requestDict = [(NSHTTPURLResponse *)response allHeaderFields];
	NSString *Last_Modified = [requestDict objectForKey:@"Last-Modified"];
	NSString *buffToSaveFile = [NSString stringWithFormat:@"%d\n%@", [data length], Last_Modified];
	[buffToSaveFile writeToFile:dataPath_ atomically:NO encoding:NSUTF8StringEncoding error:nil];
	return YES;
}

- (int) res {
	NSData *cacheData = [NSData dataWithContentsOfFile:cachePath_];
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *cacheStr = [NSString stringWithString:[decoder decodeNSData:cacheData]];
	NSString *cacheStr = decodeNSData(cacheData);//[decoder decodeNSData:cacheData];
	NSArray*lines = [cacheStr componentsSeparatedByString:@"\n"];
	return [lines count];
}

- (NSMutableArray*) getDataFrom:(int)from To:(int)to {
	int i;
	NSData *cacheData = [NSData dataWithContentsOfFile:cachePath_];
	
	DNSLog( @"cache->%@", cachePath_ );
	
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *cacheStr = [NSString stringWithString:[decoder decodeNSData:cacheData]];
	NSString *cacheStr = decodeNSData(cacheData);//[decoder decodeNSData:cacheData];
	
	NSArray*lines = [cacheStr componentsSeparatedByString:@"\n"];
	NSMutableArray *result = [NSMutableArray array];
	
//	id eliminator = [[[HTMLEliminator alloc] init] autorelease];
	
	for( i = from; i < to; i++ ) {
		if( i > [lines count] - 1 )
			break;
		NSString *line = [lines objectAtIndex:i];
		NSArray*values = [line componentsSeparatedByString:@"<>"];

		if( [values count] < 4 ) {
			values = [line componentsSeparatedByString:@","];
			if( [values count] < 4 ) {
				continue;
			}
		}
	
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[values objectAtIndex:0],		@"name",
				[values objectAtIndex:1],		@"mail",
				[values objectAtIndex:2],		@"date_id",
//				[eliminator eliminate:[values objectAtIndex:3]],
				eliminate( [values objectAtIndex:3] ),
												@"body",
				[NSString stringWithFormat:@"%03d",	i+1],	
												@"number",
				nil];
		[result addObject:dict];
	}
	return result;
}

- (NSString*) bookmarkPath{
	return bookmarkPath_;
}

@end

/*
- (void) printURLResponse:(NSURLResponse*)response {
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
*/