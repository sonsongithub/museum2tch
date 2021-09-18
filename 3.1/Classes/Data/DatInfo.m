//
//  DatInfo.m
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatInfo.h"
#import "global.h"

@implementation DatInfo

@synthesize infoDict = infoDict_;
@synthesize filepath = filepath_;

+ (DatInfo*) DatInfoWithBoardPath:(NSString*)path {
	DatInfo* obj = [[DatInfo alloc] init];
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	obj.filepath = [[NSString stringWithFormat:@"%@/%@/info.cache", documentsDirectory, path] retain];
	
	// make cache directory
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:path];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath attributes:nil];
	}
	
	// confirm path
	if( ![[NSFileManager defaultManager] fileExistsAtPath:obj.filepath] ) {
		obj.infoDict = [[NSMutableDictionary dictionary] retain];
		DNSLog( @"[DatInfo] make new dat info file." );
		return obj;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:obj.filepath];
	obj.infoDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"NSMutableDictionary"]];
	[obj.infoDict retain];

	return obj;
}

- (BOOL) write {
	if( [infoDict_ count] == 0 )
		return NO;

	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:infoDict_, @"NSMutableDictionary", nil];
	return [dict writeToFile:filepath_ atomically:NO];
}

- (void) setLength:(NSString*)length lastModified:(NSString*)lastModified ofDat:(NSString*)dat {
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:length, @"Content-Length", lastModified, @"Last-Modified", nil];
	[infoDict_ setObject:dict forKey:dat];
}

- (void) removeInfoOfDat:(NSString*)dat {
	[infoDict_ removeObjectForKey:dat];
}

- (NSMutableDictionary*) dictOfDat:(NSString*) dat {
	return [infoDict_ objectForKey:dat];
}

- (void) dealloc {
	DNSLog( @"[DatInfo] dealloc" );
	[self write];
	[infoDict_ release];
	[filepath_ release];
	[super dealloc];
}


@end
