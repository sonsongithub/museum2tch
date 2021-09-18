//
//  SubjectDataBase.m
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectDataBase.h"
#import "_tchAppDelegate.h"
#import "global.h"

@implementation SubjectDataBase

@synthesize boardPath = boardPath_;
@synthesize subjectList = subjectList_;
@synthesize parse_progress = parse_progress_;

+ (BOOL) isExistingCache:(NSString*)boardPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, boardPath];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (id) initWithBoardPath:(NSString*)boardPath {
	self = [super init];
	
	boardPath_ = [NSString stringWithString:boardPath];
	[boardPath_ retain];
	
	sheetController_ = [[SNProgressSheetController alloc] init];
	hud_ = [[SNHUDActivityView alloc] init];
	
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:boardPath_];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	return self;
}

- (void) dealloc {
	[hud_ release];
	[sheetController_ release];
	[boardPath_ release];
	[subjectList_ release];
	[super dealloc];
}

- (BOOL) loadCache:(NSMutableArray*)array {
	// make path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, boardPath_];
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		// make dictionary data to write
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
		[array addObjectsFromArray:[dict objectForKey:@"NSMutableArray"]];
		// subjectList_ = [NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]];
		// [subjectList_ retain];
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL) deleteCache {
	// make path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, boardPath_];
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL) write:(NSMutableArray*)array {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@/subject.cache", documentsDirectory, boardPath_];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"NSMutableArray", nil];
	BOOL result = [dict writeToFile:path atomically:NO];
	
	if( result ) {
		DNSLog( @"[SubjectDataBase] subject.cache - write OK - %@", path );
	}
	else {
		DNSLog( @"[SubjectDataBase] subject.cache - write failed - %@", path );
	}
	return result;
}

- (void) openActivityHUD:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		[hud_ setupWithMessage:NSLocalizedString( @"DatFileParserLoadingTitle", nil )];
		[hud_ arrange:app.mainNavigationController.visibleViewController.view.frame];
		[app.mainNavigationController.visibleViewController.view addSubview:hud_];
	}
	[pool release];
	[NSThread exit];
}

- (void) parse:(NSData*)data array:array delegate:(id)delegate{
//	[sheetController_ showSheet];
	
	
	[NSThread detachNewThreadSelector:@selector(openActivityHUD:) toTarget:self withObject:nil];
	
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	
	
	self.parse_progress = 0.0f;
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
			// DNSLog( decoded );
			NSArray*values = [decoded componentsSeparatedByString:@"<>"];
			if( [values count] == 2 ) {
				/*	
				 if( i % 20 == 0 ) {
				 self.parse_progress = (float)(i+1)/length;
				 @synchronized( self ) {	
				 [sheetController_ performSelectorOnMainThread:@selector(setProgressWithFloat:) withObject:self waitUntilDone:YES];
				 }
				 }
				 */	
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:values forKey:@"source"];
				/*
				 [dict setObject:getThreadTitle( [values objectAtIndex:1] ) forKey:@"title"];
				 [dict setObject:getThreadNumber( [values objectAtIndex:1] ) forKey:@"res"];
				 [dict setObject:getDat( [values objectAtIndex:0] ) forKey:@"dat"];
				 */
				[array addObject:dict];
			}
			head = i + 1;
		}
	}
	
	[self write:array];
	[NSThread detachNewThreadSelector:@selector(addCheck) toTarget:hud_ withObject:nil];
	[NSThread sleepForTimeInterval:1.25];
	[hud_ dismiss];
	[delegate finishParseSubjectTxt];
}

#ifdef _PARSE_WITH_MULCHITHREAD

- (void) parse:(NSData*)data array:array delegate:(id)delegate{
	[sheetController_ showSheet];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
										data, @"data",
										array, @"target",
						  delegate, @"delegate",nil];
	[dict retain];
	
	[NSThread detachNewThreadSelector:@selector(doInfoProcess:) toTarget:self withObject:dict];
}

- (void) doInfoProcess:(id)obj {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *data;
	NSMutableArray *array;
	id delegate;
	@synchronized( self ) {	
		[sheetController_ performSelectorOnMainThread:@selector(setTitle:) withObject:NSLocalizedString( @"DatFileParserLoadingTitle", nil ) waitUntilDone:YES];
		data = [obj objectForKey:@"data"];
		array = [obj objectForKey:@"target"];
		delegate = [obj objectForKey:@"delegate"];
		[obj release];
	}
	
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
//	NSNumber *num = [NSNumber numberWithFloat:(float)(i+1)/length];
	self.parse_progress = 0.0f;
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
			// DNSLog( decoded );
			NSArray*values = [decoded componentsSeparatedByString:@"<>"];
			if( [values count] == 2 ) {
			/*	
				if( i % 20 == 0 ) {
					self.parse_progress = (float)(i+1)/length;
					@synchronized( self ) {	
						[sheetController_ performSelectorOnMainThread:@selector(setProgressWithFloat:) withObject:self waitUntilDone:YES];
					}
				}
			*/	
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:values forKey:@"source"];
			/*
				[dict setObject:getThreadTitle( [values objectAtIndex:1] ) forKey:@"title"];
				[dict setObject:getThreadNumber( [values objectAtIndex:1] ) forKey:@"res"];
				[dict setObject:getDat( [values objectAtIndex:0] ) forKey:@"dat"];
			*/
				@synchronized( self ) {
					[array addObject:dict];
				}
			}
			head = i + 1;
		}
	}
	
	@synchronized( self ) {
		[self write:array];
	}
	
	[sheetController_ performSelectorOnMainThread:@selector(setTitle:) withObject:NSLocalizedString(@"DatFileParserCompleteTitle",nil) waitUntilDone:YES];
	[NSThread sleepForTimeInterval:0.25];
	
	[sheetController_ performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
	
	[delegate performSelectorOnMainThread:@selector(finishParseSubjectTxt) withObject:nil waitUntilDone:YES];
	
	[pool release];
	[NSThread exit];
}

#endif

@end
