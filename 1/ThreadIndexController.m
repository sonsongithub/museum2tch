
#import "ThreadIndexController.h"
//#import "DataDecoder.h"
//#import "HTMLEliminator.h"

@implementation ThreadIndexController

// override

- (void) dealloc {
	DNSLog( @"ThreadIndexController - dealloc" );
	[url_ release];
	[cacheDirectoryPath_ release];
	[cachePath_ release];
	[cacheURL_ release];
	[super dealloc];
}

// original method

- (id) initWithURLString:(NSString*)url {
	DNSLog( @"ThreadIndexController - initWithURLString:" );
	self = [super init];
	if (self != nil) {
		url_ = [[NSString stringWithString:url] retain];
		cacheDirectoryPath_ = [[NSString stringWithString:[UIApp makeCacheDirectroy:url]] retain];
		cachePath_ = [[NSString stringWithFormat:@"%@subject.txt", cacheDirectoryPath_] retain];
		cacheURL_ = [[NSString stringWithFormat:@"%@subject.txt", url] retain];
		DNSLog( @"ThreadIndexController - initWithURLString" );
	}
	return self;
}

- (BOOL) reloadSubjectTxt {
	DNSLog( @"ThreadIndexController - reloadSubjectTxt" );
	NSData *data = [self downloadSubjectTxt];
	
	// decode NSData into NSString
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *decodedString = [decoder decodeNSData:data];
	NSString *decodedString = decodeNSData(data);
	
	// check available NSString
	if( !decodedString )
		return NO;
		
	// check download data is available
	if( ![self checkHTMLHeader:decodedString] ) {
		DNSLog( @"ThreadIndexController - maybe subject.txt file isn't correct" );
		return NO;
	}
	
	// finally save subject.txt as cache
	[data writeToFile:cachePath_ atomically:NO];
	return YES;
}

- (BOOL) getSubjectTxt {
	DNSLog( @"ThreadIndexController - getSubjectTxt" );
	NSData *data = [NSData dataWithContentsOfFile:cachePath_];
	if( !data || [data length] == 0 ) {
		data = [self downloadSubjectTxt];
	}
	
	// decode NSData into NSString
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//NSString *decodedString = [decoder decodeNSData:data];
	NSString *decodedString = decodeNSData(data);

	
	// check available NSString
	if( decodedString == nil ) {
		DNSLog( @"ThreadIndexController - decoding was failed" );
		return NO;
	}
		
	// check download data is available
	if( ![self checkHTMLHeader:decodedString] ) {
		DNSLog( @"ThreadIndexController - maybe subject.txt file isn't correct" );
		return NO;
	}
	
	// finally save subject.txt as cache
	[data writeToFile:cachePath_ atomically:NO];
	return YES;
}

- (BOOL) checkHTMLHeader:(NSString*)str {
	DNSLog( @"ThreadIndexController - checkHTMLHeader:" );
	if( [str length] < 6 ) {
		DNSLog( @"ThreadIndexController - %@", str );
		return NO;
	}
	NSString *first4Chars = [str substringWithRange:NSMakeRange( 0, 6 )];
	DNSLog( @"ThreadIndexController - %@", first4Chars );
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

- (NSData*) downloadSubjectTxt {
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:cacheURL_] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	[theRequest setValue:USER_AGENT forHTTPHeaderField: @"User-Agent"];
	
	DNSLog( @"ThreadIndexController - downloadSubjectTxt - %@", [NSURL URLWithString:cacheURL_] );
	NSData* downloadData = nil;
	if( [UIApp isOfflineMode] )
		downloadData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	else
		downloadData = [NSData data];
			
	if( ![downloadData length] )
		return nil;
	
	return downloadData;
}

- (NSString*) readSubjectTxtFromLocalFile {
	DNSLog( @"ThreadIndexController - readSubjectTxtFromLocalFile" );
	NSData* dataFromRemote = [NSData dataWithContentsOfFile:cachePath_];
	//id decoder = [[[DataDecoder alloc] init] autorelease];
	//return [NSString stringWithString:[decoder decodeNSData:dataFromRemote]];
	//return [decoder decodeNSData:dataFromRemote];
	return decodeNSData(dataFromRemote);
}

- (int) res {
	NSString *data = [self readSubjectTxtFromLocalFile];
	NSArray*lines = [data componentsSeparatedByString:@"\n"];
	DNSLog( @"ThreadIndexController - subject.txt has %d lines", [lines count] );
	return [lines count];
}

- (NSDictionary*) extractResNumber:(NSString*)str {
	int i;
	int strIndex = [str length] - 1;
	int	delimiter = 0;
	int numberFlag = NO;
	int startFlag = NO;
	NSMutableString *numberStr = [NSMutableString string];
	NSMutableString *titleStr = [NSMutableString string];
	NSMutableArray*	ary = [NSMutableArray array];
	
	// extract character between '(' and ')'
	while( strIndex >= 0 ) {
		unichar c = [str characterAtIndex: strIndex];
		if( c == 41 ) {			// ')'
			numberFlag = YES;
		}
		else if( c==40 ) {		// '('
			startFlag = YES;
			delimiter = strIndex;
			break;
		}
		else if( numberFlag ) {
			[ary addObject:[NSString stringWithFormat:@"%C", c]];
		}
		strIndex--;
	}
	if( [ary count] >= 1 )		// use final characters as number
		for( i = 0; i < [ary count]; i++ )
			[numberStr appendString:[ary objectAtIndex:[ary count]-1-i]];
	// extract title
	strIndex = 0;
	while( strIndex < [str length] ) {
		unichar c = [str characterAtIndex: strIndex];
		[titleStr appendFormat:@"%C", c];
		if( delimiter-1 == strIndex )
			break;
		strIndex++;
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:titleStr, @"title", numberStr, @"number", nil];
}

- (NSMutableArray*) getDataFrom:(int)from To:(int)to {
	int i;
	NSString *file = [self readSubjectTxtFromLocalFile];
	
	if( file == nil ) {
		DNSLog( @"ThreadIndexController - Local file is invalid." );
		return nil;
	}
	
	NSArray*lines = [file componentsSeparatedByString:@"\n"];
	NSMutableArray *result = [NSMutableArray array];
		
//	id eliminator = [[[HTMLEliminator alloc] init] autorelease];
	
	for( i = from; i < to; i++ ) {
		if( i > [lines count] - 1 )
			break;
		NSString *line = [lines objectAtIndex:i];
		NSArray*values = [line componentsSeparatedByString:@"<>"];
		if( [values count] < 2 ) {
			values = [line componentsSeparatedByString:@","];
			if( [values count] < 2 ) {
				continue;
			}
		}
		NSDictionary *title_number_dict = [self extractResNumber:[values objectAtIndex:1]];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"%@dat/%@", url_,[values objectAtIndex:0]],			@"url",
				[title_number_dict objectForKey:@"title"],										@"rawTitle",
//				[eliminator eliminate:[title_number_dict objectForKey:@"title"]],				@"title",
				eliminate( [title_number_dict objectForKey:@"title"] ),							@"title",
				[title_number_dict objectForKey:@"number"],										@"resnum",
				[NSString stringWithFormat:@"%03d", i+1],										@"number",
				nil];
		[result addObject:dict];
	}
	return result;
}

@end