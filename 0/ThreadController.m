#import "ThreadController.h"
#import "DataDecoder.h"
#import "HTMLEliminator.h"

@implementation ThreadController

// override

- (void) dealloc {
	[entries_ release];
	DNSLog( @"ThreadController - dealloc" );
	[super dealloc];
}

// original method

- (BOOL) convertTheDayFromJapaneseToEnglish:(NSMutableString*)str {
	int i;
	NSMutableArray *before = [NSMutableArray array];		
	NSMutableArray *after = [NSMutableArray array];
	
	[before addObject:[NSString stringWithCString:"日" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"月" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"火" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"水" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"木" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"金" encoding:NSUTF8StringEncoding]];
	[before addObject:[NSString stringWithCString:"土" encoding:NSUTF8StringEncoding]];
	
	[after addObject:[NSString stringWithCString:"Sun" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Mon" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Tue" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Wed" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Thu" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Fri" encoding:NSUTF8StringEncoding]];
	[after addObject:[NSString stringWithCString:"Sat" encoding:NSUTF8StringEncoding]];
	
	for( i = 0; i < DAY_OF_THE_WEEK; i++ ) {
		if( [str replaceOccurrencesOfString:[before objectAtIndex:i] withString:[after objectAtIndex:i] options:NSLiteralSearch range:NSMakeRange(0, [str length])] )
			break;
	}
}

- (BOOL) extractEntries:(NSData*)data {
	int i;
	
	// decoding NSData into NSString
	id decoder = [[[DataDecoder alloc] init] autorelease];
	NSString *decoded_strings = [NSString stringWithString:[decoder decodeNSData:data]];
	
	if( !decoded_strings )
		return NO;

	// devide by line breaks
	NSArray *lines= [decoded_strings componentsSeparatedByString:@"\n"];
	
	// for check the Abone.
	NSString *abone = [NSString stringWithUTF8String:"あぼーん"];
	
	// for eliminating html tag and special characters.
	id eliminator = [[[HTMLEliminator alloc] init] autorelease];	
	
	for( i = 0; i < [lines count] - 1 ; i++ ) {
		if( i == 1000 )	// stop at 1001
			break;
			
		NSString *line = [lines objectAtIndex:i];
		NSArray *values = [line componentsSeparatedByString:@"<>"];
		
		if( [values count] != 5 ) {
			DNSLog( @"ThreadController - %d line - can't divide with<>", i ); 
			continue;
		}
		
		if( [[values objectAtIndex:0] isEqualToString:abone] ) {
			DNSLog( @"ThreadController - %d line - %@<>", i, abone );
			//[entries_ addObject:aboneDict];
			continue;
		}
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];

		// string of res number
		NSString *number = [NSString stringWithFormat:@"%03d",([entries_ count]+1)];
		[dict setValue:number forKey:@"number"];
		
		// set value for key, name
		
		NSString* nameStr = [eliminator eliminate:[values objectAtIndex:0]];
		[dict setValue:nameStr forKey:@"name"];

		// set value for key, mail
		[dict setValue:[values objectAtIndex:1] forKey:@"mail"];

		// check ID and date
		NSArray* subValues = [[values objectAtIndex:2] componentsSeparatedByString:@"ID:"];
		NSMutableString *date = [NSMutableString stringWithString:[subValues objectAtIndex:0]];
				
		[self convertTheDayFromJapaneseToEnglish:date];
		if( [subValues count] == 2 )
			[dict setValue:[subValues objectAtIndex:1] forKey:@"id"];
		else	// some boarads don't have IDs.
			[dict setValue:@"none" forKey:@"id"];
		
		//2007/10/20(Sat) 03:57:03.13 -> %Y/%m/%d(%a) %H:%M:%S.
		id date_this_entry = [[[NSCalendarDate alloc] initWithString:date calendarFormat:@"%Y/%m/%d(%a) %H:%M:%S"] autorelease];
		// DNSLog( @"ThreadController - date %@", date );
		// DNSLog( @"ThreadController - %@", [date_this_entry description] );
		//id earierDate = [date_this_entry earlierDate:datedata];
		
		[dict setValue:date_this_entry forKey:@"date"];
		
		NSString* bodyStr = [eliminator eliminate:[values objectAtIndex:3]];
		[dict setValue:bodyStr forKey:@"body"];

		[entries_ addObject:dict];
	}
	DNSLog( @"-->%d entries added.", [entries_ count] );

	return YES;
}

- (BOOL) download:(NSString*)url startBytes:(int)bytes {
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSDictionary *requestDict = nil;
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setValue:USER_AGENT forHTTPHeaderField: @"User-Agent"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Cache-Control"];
	[theRequest setValue:@"no-cache" forHTTPHeaderField: @"Pragma"];
	[theRequest setValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
	[theRequest setValue:@"ja" forHTTPHeaderField: @"Accept-Language"];
	[theRequest setValue:@"text/plain" forHTTPHeaderField: @"Accept"];
	[theRequest setValue:@"close" forHTTPHeaderField: @"Connection"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];			// Important?
	[theRequest setTimeoutInterval:10.0];

#ifdef _DEBUG
	int i;
	requestDict = [theRequest allHTTPHeaderFields];
	NSArray			*values = [requestDict allValues];
	NSArray			*keys = [requestDict allKeys];
	DNSLog( @"--------------------------------------------------------------------" );
	for( i = 0; i < [keys count]; i++ ) {
		DNSLog( @"%@ = %@", [keys objectAtIndex:i], [values objectAtIndex:i] );
	}
	DNSLog( @"--------------------------------------------------------------------" );
#endif

	NSData *data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	requestDict = [(NSHTTPURLResponse *)response allHeaderFields];
	
#ifdef _DEBUG
	DNSLog( @"--------------------------------------------------------------------" );
	values = [requestDict allValues];
	keys = [requestDict allKeys];
	for( i = 0; i < [keys count]; i++ ) {
		id str = [NSString stringWithFormat:@"%@ = %@", [keys objectAtIndex:i], [values objectAtIndex:i]];
		DNSLog( str );
	}
	DNSLog( @"--------------------------------------------------------------------" );
#endif
		
	if( ![[[response URL] absoluteString] isEqualToString: url] ) {
		DNSLog( @"Error - Error page." );
		return NO;
	}
	
	if( [data length] == 0) {
		DNSLog( @"Error - Not update or unknown error." );
		return NO;
	}

	if( ![self extractEntries:data] ) {
		DNSLog( @"Error - Bad Data?" );
		return NO;
	}

	DNSLog( @"ThreadController - update lastDateDownload" );
	
	return YES;
}

- (BOOL) loadURL:(NSString*)url {
	entries_ = [[NSMutableArray alloc] init];
	return [self download:url startBytes:0];
}

- (id) getEntries {
	return entries_;
}

#ifdef _DEBUG
- (BOOL) checkHead:(NSString*)url {
	int i;
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
	[theRequest setHTTPMethod:@"HEAD"];
	[theRequest setValue:USER_AGENT forHTTPHeaderField: @"User-Agent"];
	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	//
	NSDictionary	*requestDict = [(NSHTTPURLResponse *) response allHeaderFields]; 
	NSArray			*values = [requestDict allValues];
	NSArray			*keys = [requestDict allKeys];
	DNSLog( @"Response------------------------------------------------------------" );
	for( i = 0; i < [keys count]; i++ )
		DNSLog( @"%@ = %@", [keys objectAtIndex:i], [values objectAtIndex:i] );
	DNSLog( @"--------------------------------------------------------------------" );
}
#endif

@end
