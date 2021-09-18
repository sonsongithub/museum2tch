//
//  HistoryController.m
//  2tch
//
//  Created by sonson on 08/12/02.
//  Copyright 2008 sonson. All rights reserved.
//

#import "HistoryController.h"

@implementation HistoryController

@synthesize currentDict = currentDict_;

+ (NSString*)threadTitleWithDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	NSString* title = nil;
	const char *sql = "select title from threadInfo where dat = ? and path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			if( sqlite3_column_text(statement, 0) )
				title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		}
	}
	sqlite3_finalize( statement );
	return title;
}

- (BOOL)deleteEntry:(NSString*)pathInput dat:(int)datInput {
	int i;
	BOOL result = NO;
	for( i = 0; i < [forwardBuffer_ count]; i++ ) {
		NSDictionary* threadInfo = [forwardBuffer_ objectAtIndex:i];
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		if( [pathInput isEqualToString:path] && datInput == dat ) {
			result = YES;
			[forwardBuffer_ removeObjectAtIndex:i];
		}
	}
	for( i = 0; i < [backBuffer_ count]; i++ ) {
		NSDictionary* threadInfo = [backBuffer_ objectAtIndex:i];
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		if( [pathInput isEqualToString:path] && datInput == dat ) {
			result = YES;
			[backBuffer_ removeObjectAtIndex:i];
		}
	}
	return result;
}

- (BOOL)clearEntries {
	self.currentDict = nil;
	[forwardBuffer_ removeAllObjects];
	[backBuffer_ removeAllObjects];
	return YES;
}

- (id)init {
	DNSLogMethod
	self = [super init];
	
	forwardBuffer_ = [[NSMutableArray alloc] init];
	backBuffer_ = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dumpBuffer {
	for( NSDictionary* threadInfo in backBuffer_ ) {
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		//DNSLog( @"back    %@ - %d", path, dat);
		/*NSString* title = */[HistoryController threadTitleWithDat:dat path:path];
//		DNSLog( @"Back    - %@", title );
	}
	if( self.currentDict ) {
		NSString* path = [self.currentDict objectForKey:@"path"];
		int dat = [[self.currentDict objectForKey:@"dat"] intValue];
//		DNSLog( @"current %@ - %d", path, dat);
		/*NSString* title = */[HistoryController threadTitleWithDat:dat path:path];
//		DNSLog( @"Current - %@", title );
	}
	for( NSDictionary* threadInfo in forwardBuffer_ ) {
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		/*NSString* title = */[HistoryController threadTitleWithDat:dat path:path];
//		DNSLog( @"Forward - %@", title );
//		DNSLog( @"forward %@ - %d", path, dat);
	}
}

- (BOOL)canGoBack {
	DNSLogMethod
	return ([backBuffer_ count] > 0 );
}

- (BOOL)canGoForward {
	DNSLogMethod
	return ([forwardBuffer_ count] > 0 );
}

- (NSDictionary*) goBack {
	DNSLogMethod
#ifdef _DEBUG
	[self dumpBuffer];
#endif
	if( ![self canGoBack] )
		return nil;
	[forwardBuffer_ addObject:self.currentDict];
	self.currentDict = [backBuffer_ lastObject];
	[backBuffer_ removeLastObject];
	return self.currentDict;
}

- (NSDictionary*) goForward {
	DNSLogMethod
#ifdef _DEBUG
	[self dumpBuffer];
#endif
	if( ![self canGoForward] )
		return nil;
	[backBuffer_ addObject:self.currentDict];
	self.currentDict = [forwardBuffer_ lastObject];
	[forwardBuffer_ removeLastObject];
	return self.currentDict;
}

- (void)insertNewThreadInfoWithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	// check if it is as same as previous history data
	if( [path isEqualToString:[self.currentDict objectForKey:@"path"]] && dat == [[self.currentDict objectForKey:@"dat"] intValue] )
		return;
	
	if( self.currentDict )
		[backBuffer_ addObject:self.currentDict];
	
	[forwardBuffer_ removeAllObjects];
	self.currentDict = [NSDictionary dictionaryWithObjectsAndKeys:
						path,	@"path",
						[NSNumber numberWithInt:dat], @"dat",nil];
	[self dumpBuffer];
}

- (void)dealloc {
	DNSLogMethod
	[currentDict_ release];
	[forwardBuffer_ release];
	[backBuffer_ release];
	[super dealloc];
}

@end
