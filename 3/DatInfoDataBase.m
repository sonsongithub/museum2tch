//
//  DatInfoDataBase.m
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatInfoDataBase.h"
#import "global.h"

@implementation DatInfoDataBase

@synthesize infoList = infoList_;

- (id) initWithBoardPath:(NSString*)boardPath {
	self = [super init];
	
	boardPath_ = [[NSString stringWithString:boardPath] retain];
	
	[self load];
	
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:boardPath_];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	
	return self;
}

- (BOOL) load {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@/info.cache", documentsDirectory, boardPath_];
	
	// confirm path
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		infoList_ = [[NSMutableDictionary dictionary] retain];
		return NO;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	infoList_ = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"NSMutableDictionary"]];
	[infoList_ retain];
	
	NSArray *keys = [infoList_ allKeys];
	
	DNSLog( @"[DatInfoDataBase] load" );
	for( NSString* key in keys ) {
		NSDictionary *dict = [infoList_ objectForKey:key];
		DNSLog( @"Dat:%@ -> %@,%@", key, [dict objectForKey:@"Content-Length"], [dict objectForKey:@"Last-Modified"] );
	}
	
	return YES;
}

- (BOOL) write {
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@/info.cache", documentsDirectory, boardPath_];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:infoList_, @"NSMutableDictionary", nil];
	return [dict writeToFile:path atomically:NO];
}

- (void) dealloc {
	[self write];
	[infoList_ release];
	[super dealloc];
}


@end
