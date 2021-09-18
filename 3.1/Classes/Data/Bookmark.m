//
//  Bookmark.m
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"
#import "global.h"

@implementation Bookmark

@synthesize list = list_;

#pragma mark Class Method

+ (Bookmark*) defaultBookmark {
	Bookmark *obj = [[Bookmark alloc] init];
	obj.list = [[NSMutableArray alloc] init];
	
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"bookmark.cache"];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		return obj;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	[obj.list addObjectsFromArray:[dict objectForKey:@"NSMutableArray"]];
	
	return obj;
}

#pragma mark Original Method

- (BOOL) updateTitleOfBookmarkOfBoardPath:(NSString*)boardPath dat:(NSString*)dat title:(NSString*)title {
	for( NSMutableDictionary* element in list_ ) {
		if( [[element objectForKey:@"boardPath"] isEqualToString:boardPath] && [[element objectForKey:@"dat"] isEqualToString:dat] ) {
			[element setObject:title forKey:@"title"];
			return YES;
		}
	}
	return NO;
}

- (BOOL) updateResOfBookmarkOfBoardPath:(NSString*)boardPath dat:(NSString*)dat res:(int)res {
	for( NSMutableDictionary* element in list_ ) {
		if( [[element objectForKey:@"boardPath"] isEqualToString:boardPath] && [[element objectForKey:@"dat"] isEqualToString:dat] ) {
			NSNumber* resValue = [[NSNumber alloc] initWithInt:res];
			[element setObject:resValue forKey:@"res"];
			[resValue release];
			return YES;
		}
	}
	return NO;
}

- (BOOL) addWithDictinary:(NSMutableDictionary*)dict {
	for( NSMutableDictionary* element in list_ ) {
		if( [element isEqualToDictionary:dict] ) {
			return NO;
		}
	}
	[list_ addObject:dict];
	return YES;
}

- (BOOL) write {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"bookmark.cache"];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:list_, @"NSMutableArray", nil];
	BOOL result = [dict writeToFile:path atomically:NO];

	if( result ) {
		DNSLog( @"[Bookmark] bookmark.cache - write OK - %@", path );
	}
	else {
		DNSLog( @"[Bookmark] bookmark.cache - write failed - %@", path );
	}
	return result;
}

#pragma mark Override

- (void) dealloc {
	[self write];
	[list_ release];
	[super dealloc];
}

@end
