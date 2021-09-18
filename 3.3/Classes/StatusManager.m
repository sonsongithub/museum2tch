//
//  StatusManager.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatusManager.h"

int categoryIDOfPath( NSString* path ) {
	const char *sql = "SELECT category_id FROM board where path = ?;";
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

- (void)setPath:(NSString*)newValue {
	if( path_ != newValue ) {
		[path_ release];
		path_ = [newValue retain];
		self.categoryID = categoryIDOfPath( path_ );
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updateTitle" object:self];
}

- (void)setDat:(int)newValue {
	dat_ = newValue;
}

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

- (void) dealloc {
	[path_ release];
	[threadTitle_ release];
	[categoryTitle_ release];
	[boardTitle_ release];
	[super dealloc];
}

@end
