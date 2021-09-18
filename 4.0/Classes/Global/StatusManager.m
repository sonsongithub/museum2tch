//
//  StatusManager.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatusManager.h"

int categoryIDOfPath( NSString* path ) {
	DNSLog( @"categoryIDOfPath" );
	const char *sql = "SELECT category_id FROM board where category_id != 2 and path = ?;";
	int category_id = 1;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);
		category_id = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(  statement );
	return category_id;
}

@implementation StatusManager

@synthesize categoryID = categoryID_;
@synthesize categoryTitle = categoryTitle_;

@synthesize boardTitle = boardTitle_;
@synthesize path = path_;

@synthesize threadTitle = threadTitle_;
@synthesize dat = dat_;

#pragma mark accessor, getter, setter

- (void)setPath:(NSString*)newValue {
	DNSLogMethod
	if( path_ != newValue ) {
		[path_ release];
		path_ = [newValue retain];
		self.categoryID = categoryIDOfPath( path_ );
		DNSLog( @"categoryID - %d", self.categoryID );
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTitleNotification object:self];
}

- (void)setDat:(int)newValue {
	dat_ = newValue;
}

#pragma mark for management, pop or push

- (void)popCategoryInfo {
	categoryID_ = 0;
	[self popBoardInfo];
	[self popThreadInfo];
}

- (void)popBoardInfo {
	[path_ release];
	path_ = nil;
}

- (void)popThreadInfo {
	dat_ = 0;
}

#pragma mark Method to save and write

- (void)load {
	DNSLogMethod
	NSString *plistPath = [NSString stringWithFormat:@"%@/status.plist", DocumentFolderPath];
	if( [[NSFileManager defaultManager] fileExistsAtPath:plistPath] ) {
		NSData *data  = [NSData dataWithContentsOfFile:plistPath];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.dat = [decoder decodeIntForKey:@"dat"];
		self.path = [decoder decodeObjectForKey:@"path"];
		self.threadTitle = [decoder decodeObjectForKey:@"threadTitle"];
		self.boardTitle = [decoder decodeObjectForKey:@"boardTitle"];
		self.categoryID = [decoder decodeIntForKey:@"categoryID"];
		self.categoryTitle = [decoder decodeObjectForKey:@"categoryTitle"];
		[decoder finishDecoding];
		[decoder release];
	}
}

- (void)write {
	DNSLogMethod
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	NSString *plistPath = [NSString stringWithFormat:@"%@/status.plist", DocumentFolderPath];
	[encoder encodeObject:self.categoryTitle forKey:@"categoryTitle"];
	[encoder encodeInt:self.categoryID forKey:@"categoryID"];
	[encoder encodeObject:self.boardTitle forKey:@"boardTitle"];
	[encoder encodeObject:self.threadTitle forKey:@"threadTitle"];
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeInt:self.dat forKey:@"dat"];
	[encoder finishEncoding];
	
	[data writeToFile:plistPath atomically:NO];
	[encoder release];
}

#pragma mark Override

- (id)init {
	DNSLogMethod
	self = [super init];
	[self load];
	return self;
}

#pragma mark dealloc

- (void) dealloc {
	DNSLogMethod
	[self write];
	[path_ release];
	[threadTitle_ release];
	[categoryTitle_ release];
	[boardTitle_ release];
	[super dealloc];
}

@end
