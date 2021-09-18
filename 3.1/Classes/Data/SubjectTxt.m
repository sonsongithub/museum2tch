//
//  SubjectTxt.m
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectTxt.h"
#import "global.h"
#import "_tchAppDelegate.h"
#import "html-tool.h"

#pragma mark Global method

NSString* getDat( NSString* dat ) {
	return [dat substringToIndex:([dat length]-4)];
}

NSString* getThreadTitle (NSString* input) {
	int i;
	int head_num = 0;
	int tail_num = 0;
	
	for(i = [input length] - 1; i >= 0; i--) {
		if([input characterAtIndex: i] == ')')
			tail_num = i;
		
		if( tail_num != 0 && [input characterAtIndex: i] == '(') {
			head_num = i;
			break;
		}
	}
	if( head_num == 0 )
		head_num = [input length];
	
	return getConvertedSpecialChar( [input substringWithRange:NSMakeRange( 0, head_num )] );
}

int getThreadResNumber (NSString* input) {
	int i;
	int head_num = 0;
	int tail_num = 0;
	
	for(i = [input length] - 1; i >= 0; i--) {
		if([input characterAtIndex: i] == ')')
			tail_num = i;
		
		if( tail_num != 0 && [input characterAtIndex: i] == '(') {
			head_num = i;
			break;
		}
	}
	return [[input substringWithRange:NSMakeRange( head_num + 1, tail_num - ( head_num + 1 ) )] intValue];
}

BOOL updateSubjectDictionary( NSMutableDictionary* dict ) {
	if( ![dict objectForKey:@"title"] ) {
		NSArray *values = [dict objectForKey:@"source"];
		[dict setObject:getThreadTitle( [values objectAtIndex:1] ) forKey:@"title"];
		
		NSNumber* res = [[NSNumber alloc] initWithInt:getThreadResNumber( [values objectAtIndex:1] )];
		[dict setObject:res forKey:@"res"];
		[res release];
		
		[dict setObject:getDat( [values objectAtIndex:0] ) forKey:@"dat"];
		
#if TARGET_IPHONE_SIMULATOR
		[NSThread sleepForTimeInterval:0.005];
#endif
		
		return NO;
	}
	return YES;
}

@implementation SubjectTxt

@synthesize subjectList = subjectList_;
@synthesize updateDate = updateDate_;
@synthesize path = path_;
@synthesize keyword = keyword_;

#pragma mark Class Method

+ (void) removeEvacuation {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/subject.evacuated", documentsDirectory];
	if( [[NSFileManager defaultManager] fileExistsAtPath:filepath] ) {		
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
	}
}

+ (BOOL) isExistingCache:(NSString*)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filepath = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, path];
	return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

+ (SubjectTxt*) SubjectTxtWithData:(NSData*)data path:(NSString*)path {
	SubjectTxt *obj = [[SubjectTxt alloc] init];
	obj.subjectList = [[NSMutableArray alloc] init];	//[[NSMutableArray array] retain];
	obj.path = [[NSString stringWithString:path] retain];
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
			NSArray*values = [decoded componentsSeparatedByString:@"<>"];
			if( [values count] == 2 ) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:values forKey:@"source"];
				[obj.subjectList addObject:dict];
			}
			head = i + 1;
		}
	}
	obj.updateDate = [[NSDate date] retain];
	obj.keyword = @"";
	
	[obj write];
	return obj;
}

+ (SubjectTxt*) SubjectTxtFromCacheWithBoardPath:(NSString*)path {
	SubjectTxt *obj = [[SubjectTxt alloc] init];
	obj.path = [[NSString stringWithString:path] retain];
	
	// make path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filepath = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, path];
	if( [[NSFileManager defaultManager] fileExistsAtPath:filepath] ) {
		// make dictionary data to write
		
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filepath];
		obj.subjectList = [[NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]] retain];
		obj.updateDate = [[dict objectForKey:@"NSDate"] retain];
		obj.keyword = @"";
		return obj;
	}
	else {
		[obj release];
		return nil;
	}
}

+ (SubjectTxt*) RestoreFromEvacuation {
	SubjectTxt *obj = [[SubjectTxt alloc] init];
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/subject.evacuated", documentsDirectory];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:filepath] ) {
		// make dictionary data to write
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filepath];
		obj.subjectList = [[NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]] retain];
		
		NSDictionary *other = [dict objectForKey:@"NSDictionary"];
		obj.updateDate = [[other objectForKey:@"date"] retain];
		obj.path = [[other objectForKey:@"path"] retain];
		obj.keyword = [[other objectForKey:@"keyword"] retain];
		
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
		return obj;
	}
	else {
		[obj release];
		return nil;
	}
}

#pragma mark Original

- (NSString*) updateDateString {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	return [NSString stringWithFormat:@"%@ %@", NSLocalizedString( @"UpdateDate", nil ), [dateFormatter stringFromDate:updateDate_]];
}

- (BOOL) write {
	if( [subjectList_ count] == 0 )
		return NO;
	//return NO;
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, path_];
	
	// make cache directory
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:path_];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath attributes:nil];
	}
	
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subjectList_, @"NSMutableArray", updateDate_, @"NSDate", path_, @"NSString", nil];
	BOOL result = [dict writeToFile:filepath atomically:NO];
	
	if( result ) {
		DNSLog( @"[SubjectTxt] subject.cache - write OK - %@", filepath );
	}
	else {
		DNSLog( @"[SubjectTxt] subject.cache - write failed - %@", filepath );
	}
	return result;
}

- (BOOL) evacuate:(NSString*)keyword {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/subject.evacuated", documentsDirectory];
	
	// make dict to save the other data
	NSDictionary* other = [NSDictionary dictionaryWithObjectsAndKeys:updateDate_, @"date", path_, @"path", keyword, @"keyword", nil];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subjectList_, @"NSMutableArray", other, @"NSDictionary", nil];
	BOOL result = [dict writeToFile:filepath atomically:NO];
	
	if( result ) {
		DNSLog( @"[SubjectTxt] subject.evacuated - write OK - %@", filepath );
	}
	else {
		DNSLog( @"[SubjectTxt] subject.evacuated - write failed - %@", filepath );
	}
	return result;
}

#pragma mark Override

- (void) dealloc {
	[self write];
	[subjectList_ release];
	[updateDate_ release];
	[path_ release];
	[keyword_ release];
	[super dealloc];
}

@end
