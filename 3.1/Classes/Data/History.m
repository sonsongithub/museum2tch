//
//  History.m
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "History.h"
#import "global.h"

@implementation History

@synthesize list = list_;

#pragma mark Class Method

+ (History*) defaultHistory {
	History *obj = [[History alloc] init];
	obj.list = [[NSMutableArray alloc] init];
	
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"history.cache"];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		return obj;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	[obj.list addObjectsFromArray:[dict objectForKey:@"NSMutableArray"]];
	
	return obj;
}

#pragma mark Original Method

- (BOOL) addWithDictinary:(NSMutableDictionary*)dict {
	int i;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[dict setObject:[NSDate date] forKey:@"date"];
	//	[dict setObject:[gregorian components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:[NSDate date]] forKey:@"dateComponents"];
	[gregorian release];
	for( i = 0; i < [list_ count]; i++ ) {
		NSMutableDictionary* element = (NSMutableDictionary*)[list_ objectAtIndex:i];		
		if( [[element objectForKey:@"dat"] isEqualToString:[dict objectForKey:@"dat"]] && [[element objectForKey:@"boardPath"] isEqualToString:[dict objectForKey:@"boardPath"]] ) {
			[list_ removeObjectAtIndex:i];
			[list_ insertObject:dict atIndex:0];
			return YES;
		}
	}
	[list_ insertObject:dict atIndex:0];
	if( [list_ count] > 200 ) {
		[list_ removeLastObject];
	}
	return YES;
}

- (void) clear {
	[list_ removeAllObjects];
}

- (BOOL) write {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"history.cache"];
	
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
