//
//  HistoryController.m
//  2tch
//
//  Created by sonson on 08/12/02.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryController.h"
#import "DatParser_old.h"

@implementation HistoryController

@synthesize currentDict = currentDict_;

- (id)init {
	self = [super init];
	
	forwardBuffer_ = [[NSMutableArray alloc] init];
	backBuffer_ = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dumpBuffer {
	for( NSDictionary* threadInfo in backBuffer_ ) {
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		NSString* title = [DatParser_old threadTitleWithDat:dat path:path];
		DNSLog( @"Back    - %@", title );
	}
	if( self.currentDict ) {
		NSString* path = [self.currentDict objectForKey:@"path"];
		int dat = [[self.currentDict objectForKey:@"dat"] intValue];
		NSString* title = [DatParser_old threadTitleWithDat:dat path:path];
		DNSLog( @"Current - %@", title );
	}
	for( NSDictionary* threadInfo in forwardBuffer_ ) {
		NSString* path = [threadInfo objectForKey:@"path"];
		int dat = [[threadInfo objectForKey:@"dat"] intValue];
		NSString* title = [DatParser_old threadTitleWithDat:dat path:path];
		DNSLog( @"Forward - %@", title );
	}
}

- (BOOL)canGoBack {
	return ([backBuffer_ count] > 0 );
}

- (BOOL)canGoForward {
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
	// check if it is as same as previous history data
	if( [path isEqualToString:[self.currentDict objectForKey:@"path"]] && dat == [[self.currentDict objectForKey:@"dat"] intValue] )
		return;
	
	if( self.currentDict )
		[backBuffer_ addObject:self.currentDict];
	
	[forwardBuffer_ removeAllObjects];
	self.currentDict = [NSDictionary dictionaryWithObjectsAndKeys:
						path,	@"path",
						[NSNumber numberWithInt:dat], @"dat",nil];
}

- (void)dealloc {
	DNSLogMethod
	[currentDict_ release];
	[forwardBuffer_ release];
	[backBuffer_ release];
	[super dealloc];
}

@end
