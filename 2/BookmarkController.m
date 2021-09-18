//
//  BookmarkController.m
//  2tch
//
//  Created by sonson on 08/03/09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkController.h"
#import "global.h"

@implementation BookmarkController

- (id) initWithDelegate:(id) fp {
	self = [super init];
	delegate_ = fp;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(addBookmark:)
			name:@"addBookmark"
			object:nil];
			
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(save:)
			name:@"save"
			object:nil];
	
	NSString *path = [NSString stringWithFormat:@"%@/bookmark.plist", [UIApp applicationDirectory]];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		NSData *data = [NSData dataWithContentsOfFile:path];
		NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		id ary = [[str propertyList] objectForKey:@"NSArray"];
		bookmarkArray_ = [[NSMutableArray arrayWithArray:ary] retain];
		[self debugaa];
	}
	else
		bookmarkArray_ = [[NSMutableArray array] retain];
	
	return self;
}

- (void) debugaa {
	int i;
	for( i = 0; i < [bookmarkArray_ count]; i++ ) {
		id obj = [bookmarkArray_ objectAtIndex:i];
		DNSLog( @"%@, %d", [obj objectForKey:@"threadTitle"], [[obj objectForKey:@"threadLength"] intValue] );
	}
}

- (void) save:(NSNotification *)notification {	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:bookmarkArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/bookmark.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (void) dealloc {
	[bookmarkArray_ release];
	[super dealloc];
}

- (void) addBookmark:(NSNotification *)notification {
	int i;
	id dict = [notification object];
	
	for( i = 0; i < [bookmarkArray_ count]; i++ ) {
		id obj = [bookmarkArray_ objectAtIndex:i];
		id input_boardID = [dict objectForKey:@"boardID"];
		id temp_boardID = [obj objectForKey:@"boardID"];
		id input_datFile = [dict objectForKey:@"datFile"];
		id temp_datFile = [obj objectForKey:@"datFile"];
		if( [input_boardID isEqualToString:temp_boardID] && [input_datFile isEqualToString:temp_datFile] ) {
			return;
		}
	}
	[bookmarkArray_ insertObject:dict atIndex:0];
#ifdef _DEBUG
	dict = [NSDictionary dictionaryWithObjectsAndKeys:bookmarkArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/bookmark.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
#endif
}

- (id) clear {
	[bookmarkArray_ removeAllObjects];
#ifdef _DEBUG
	id dict = [NSDictionary dictionaryWithObjectsAndKeys:bookmarkArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/bookmark.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
#endif
}

- (id) bookmark {
	return bookmarkArray_;
}

@end
