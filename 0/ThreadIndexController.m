
#import "ThreadIndexController.h"
#import "DataDecoder.h"

@implementation ThreadIndexController

// override

- (id) init {
	self = [super init];
	if (self != nil) {
		DNSLog( @"ThreadIndexController - init" );
	}
	return self;
}

- (void) dealloc {
	DNSLog( @"ThreadIndexController - dealloc" );
	[title_ release];
	[filename_ release];
	[resnum_ release];
	[titleAndResnum_ release];
	[codeNames_ release];
	free(codes_);
	[super dealloc];
}

// original method

- (NSString*) pullBoardTitles:(NSString*)url {
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	[theRequest setValue:USER_AGENT forHTTPHeaderField: @"User-Agent"];
	
	DNSLog( @"ThreadIndexController - GET" );
	NSData *downloadedData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	
	id decoder = [[[DataDecoder alloc] init] autorelease];
	NSString *str = [NSString stringWithString:[decoder decodeNSData:downloadedData]];
	return str;
}

- (int) hasAPhrase:(NSString*)string withTargetPhrase:(NSString*)target {
	NSMutableArray *resultFileAndTitleArray = [NSMutableArray array];
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:target];
	NSScanner* scanner = [NSScanner scannerWithString:string];
	NSString* scannedPart = nil;
	
	// devide by "<>", made file name and title with res number
	while(![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:chSet intoString:&scannedPart]) {
			[resultFileAndTitleArray addObject:scannedPart];
		}	
		[scanner scanCharactersFromSet:chSet intoString:nil];
	}
	return [resultFileAndTitleArray count];
}

- (NSMutableDictionary*) extractFileName:(NSString*)line {		// this function must be divided into some functions
	NSMutableArray *resultFileAndTitleArray = [NSMutableArray array];
	NSString *firstDelimiter = [NSString stringWithUTF8String:"<>"];
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:firstDelimiter];
	NSScanner* scanner = [NSScanner scannerWithString:line];
	NSString* scannedPart = nil;

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	// devide by "<>", made file name and title with res number
	while(![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:chSet intoString:&scannedPart]) {
			[resultFileAndTitleArray addObject:scannedPart];
		}	
		[scanner scanCharactersFromSet:chSet intoString:nil];
	}
	
	if( [resultFileAndTitleArray count] != 2 ) {
		DNSLog( @"ThreadIndexController - Error:Wrong format can't divide <> -> %@", line );
		//[dict setValue:@"false" forKey:@"dataAvaiable"];
		//[dict setValue:line forKey:@"string"];
		return nil;
	}
	
	//if( [self hasAPhrase:[resultFileAndTitleArray objectAtIndex:0] withTargetPhrase:@".da"] ) {
	//	DNSLog( @"ThreadIndexController - It does have dat." );
	//}
	
	// divide by " (", made title and res number with ")"
	NSMutableArray *resultTitleAndRes = [NSMutableArray array];
	chSet = [NSCharacterSet characterSetWithCharactersInString:@" ("];
	scanner = [NSScanner scannerWithString:[resultFileAndTitleArray objectAtIndex:1]];
	scannedPart = nil;
	while(![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:chSet intoString:&scannedPart]) {
			[resultTitleAndRes addObject:scannedPart];
		}	
		[scanner scanCharactersFromSet:chSet intoString:nil];
	}
	if( [resultTitleAndRes count] != 2 ) {
		//DNSLogWithAData( @"ThreadIndexController - OK:But wrong format can't divide ( -> %@", line );
		[dict setValue:@"false" forKey:@"dataAvaiable"];
		[dict setValue:[NSString stringWithFormat:@"%@",[resultFileAndTitleArray objectAtIndex:0]] forKey:@"path"];
		
	//	DNSLog( @"ThreadIndexController - Extracted path->%@", [resultFileAndTitleArray objectAtIndex:0] );
	//	DNSLog( @"ThreadIndexController - Extracted string->%@", [resultFileAndTitleArray objectAtIndex:1] );
		
		[dict setValue:[resultFileAndTitleArray objectAtIndex:1] forKey:@"string"];
		return dict;
	}
	
	// delete ")" from string which has res number and ")"
	NSMutableString* resNumString = [NSMutableString stringWithString:[resultTitleAndRes objectAtIndex:1]];
	[resNumString replaceOccurrencesOfString:@")" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [resNumString length])];
	
	// make string which includes title and res number 
	//NSString* titleWithResNumString = [NSString stringWithFormat:@"%@-%@",[resultTitleAndRes objectAtIndex:0],resNumString];
	
	// make array which is used as results
	[dict setValue:@"true" forKey:@"dataAvaiable"];
	[dict setValue:[NSString stringWithFormat:@"%@",[resultFileAndTitleArray objectAtIndex:0]] forKey:@"path"];
	[dict setValue:[resultTitleAndRes objectAtIndex:0] forKey:@"string"];
	[dict setValue:resNumString forKey:@"resnum"];
	
	return dict;
}

- (BOOL) doProcess:(NSString*)url {
	NSString *subject_txt_url = [url stringByAppendingString:@"/subject.txt"];
	NSString *str_data = [self pullBoardTitles:subject_txt_url];
	
	if( !str_data ) {
		DNSLog( @"ThreadIndexController - Error:Can't download -> %@", url );
		return NO;
	}
	
	DNSLog( @"ThreadIndexController - OK:Downloaded -> %@", url );
		
	[self extractDataHtmlAndTitle:str_data];
	
	if( [threads_ count] == 0 ) {
		DNSLog( @"ThreadIndexController - Error:Can't extract correctly -> %@", url );
		return NO;
	}
	else {
		DNSLog( @"ThreadIndexController - OK:%d thread titles", [threads_ count] );
		return YES;
	}
}

- (void) extractDataHtmlAndTitle:(NSString*) str_data {
	int i;
	NSArray*lines = [str_data componentsSeparatedByString:@"\n"];
	
	[title_ release];
	[filename_ release];
	[resnum_ release];
	[titleAndResnum_ release];
	
	title_ = [[NSMutableArray array] retain];
	filename_ = [[NSMutableArray array] retain];
	resnum_ = [[NSMutableArray array] retain];
	titleAndResnum_ = [[NSMutableArray array] retain];
	
	[threads_ release];
	threads_ = [[NSMutableArray array] retain];
	
	for( i = 0; i < [lines count]; i++ ) {
		NSString *line = [lines objectAtIndex:i];
		id data = [self extractFileName:line];
		if( data ) {
			[threads_ addObject:data];
		}
		else {
		}
	}
}

- (id) threads {
	return threads_;
}

- (id) titles {
	return title_;
}

- (id) filenames {
	return filename_;
}

- (id) resnums {
	return resnum_;
}

@end