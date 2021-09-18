//
//  BookmarkHelper.m
//  2tch
//
//  Created by sonson on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkHelper.h"

@implementation BookmarkHelper

+ (void)insertThreadIntoBookmarkOfDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	
	int bookmark_key = [BookmarkHelper threadInfoOfDat:dat path:path];
	if( [BookmarkHelper isInsertedThreadToBookmark:bookmark_key] )
		return;
	
	static char *sql = "INSERT INTO bookmark (id, bookmark_key, bookmark_kind ) VALUES(NULL, ?, ? )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bookmark_key );
		sqlite3_bind_int( statement, 2, 2 );
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

+ (int)threadInfoOfDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	int bookmark_id = 0;
	const char *sql = "select id from threadInfo where dat = ? and path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		/*int success = */sqlite3_step(statement);
		bookmark_id = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize( statement );
	return bookmark_id;
}

+ (BOOL)isInsertedThreadToBookmark:(int)bookmark_key {
	DNSLogMethod
	int results = 0;
	const char *sql = "select count(*) from bookmark where bookmark_key = ? and bookmark_kind = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bookmark_key );
		sqlite3_bind_int( statement, 2, 2 );
		/*int success = */sqlite3_step(statement);
		results = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize( statement );
	return ( results > 0 );
}

#pragma mark for board adding

+ (void)insertBoardIntoBookmarkOfPath:(NSString*)path {
	DNSLogMethod
	
	int bookmark_key = [BookmarkHelper boardOfPath:path];
	if( [BookmarkHelper isInsertedBoardToBookmark:bookmark_key] )
		return;
	
	static char *sql = "INSERT INTO bookmark (id, bookmark_key, bookmark_kind ) VALUES(NULL, ?, ? )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bookmark_key );
		sqlite3_bind_int( statement, 2, 1 );
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

+ (int)boardOfPath:(NSString*)path {
	DNSLogMethod
	int bookmark_id = 0;
	const char *sql = "select id from board where path = ?";
	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
		/*int success = */sqlite3_step(statement);
		bookmark_id = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize( statement );
	return bookmark_id;
}

+ (BOOL)isInsertedBoardToBookmark:(int)bookmark_key {
	DNSLogMethod
	int results = 0;
	const char *sql = "select count(*) from bookmark where bookmark_key = ? and bookmark_kind = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bookmark_key );
		sqlite3_bind_int( statement, 2, 1 );
		/*int success = */sqlite3_step(statement);
		results = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize( statement );
	return ( results > 0 );
}

@end
