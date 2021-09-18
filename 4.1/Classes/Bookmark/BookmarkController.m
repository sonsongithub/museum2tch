//
//  BookmarkController.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BookmarkController.h"
#import "BookmarkCellInfo.h"
#import "SubjectTxt.h"

@implementation BookmarkController

@synthesize list = list_;

+ (BookmarkController*) defaultBookmark {
	BookmarkController *obj = [[BookmarkController alloc] init];
	[obj loadWithEncoder];
	return obj;
}

- (void)clear {
	[list_ removeAllObjects];
}

- (BOOL)isThreadAlreadAddedWithPath:(NSString*)path dat:(int)dat title:(NSString*)title {
	for( BookmarkCellInfo* info in list_ ) {
		if( [info.path isEqualToString:path] && [info.title isEqualToString:title] && info.dat == dat ) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)isBoardAlreadAddedWithPath:(NSString*)path title:(NSString*)title {
	for( BookmarkCellInfo* info in list_ ) {
		if( [info.path isEqualToString:path] && [info.title isEqualToString:title] && info.dat == 0 ) {
			return NO;
		}
	}
	return YES;
}

- (void)addBookmarkOfThreadWithPath:(NSString*)path dat:(int)dat title:(NSString*)title {
	if( path  && dat && title ) {
		if( [self isThreadAlreadAddedWithPath:path dat:dat title:title] ) {
			BookmarkCellInfo *data = [[BookmarkCellInfo alloc] init];
			data.title = title;
			data.path = path;
			data.dat = dat;
			data.boardTitle = [SubjectTxt boardTitleWithPath:path];
			[list_ addObject:data];
			[data release];
		}
	}
}

- (void)addBookmarkOfBoardWithPath:(NSString*)path title:(NSString*)title {
	if( path && title ) {
		if( [self isBoardAlreadAddedWithPath:path title:title] ) {
			BookmarkCellInfo *data = [[BookmarkCellInfo alloc] init];
			data.title = title;
			data.path = path;
			data.dat = 0;
			[list_ addObject:data];
			[data release];
		}
	}
}

- (void)loadWithEncoder {
	DNSLogMethod
	NSString *plistPath = [NSString stringWithFormat:@"%@/bookmark.plist", DocumentFolderPath ];
	if( [[NSFileManager defaultManager] fileExistsAtPath:plistPath] ) {
		NSData *data  = [NSData dataWithContentsOfFile:plistPath];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[list_ addObjectsFromArray:[decoder decodeObjectForKey:@"bookmarkList"]];
		[decoder finishDecoding];
		[decoder release];
	}
}

- (void)writeWithEncoder {
	DNSLogMethod
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[encoder encodeObject:list_ forKey:@"bookmarkList"];
	[encoder finishEncoding];
	[encoder release];
	NSString *plistPath = [NSString stringWithFormat:@"%@/bookmark.plist", DocumentFolderPath ];
	
	[data writeToFile:plistPath atomically:NO];
	[data release];
}

- (id)init {
	self = [super init];
	
	self.list = [[NSMutableArray alloc] init];
	[self.list release];
	
	return self;
}

- (void)dealloc {
	[self writeWithEncoder];
	[list_ release];
	[super dealloc];
}

@end
