//
//  BBSMenuParser.m
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBSMenuParser.h"
#import "StringDecoder.h"

static sqlite3_stmt *category_insert_statement = nil;
static sqlite3_stmt *board_insert_statement = nil;
static sqlite3_stmt *server_check_statement = nil;
static sqlite3_stmt *server_insert_statement = nil;

typedef enum {
	kBBSMenuSearching,
	kBBSMenuSearchCaetgory,
	kBBSMenuSearchHref
}kBBSMenuSearch;

int searchBoardTitleHead( char*p, int head, int tail ) {
	int i;
	const char* template = ">";
	if( tail - head < 1 )
		return -1;
	for( i = head; i < tail - 1; i++ ) {
		if( !strncmp( p + i, template, 1 ) ) {
			return i;
		}
	}
	return -1;
}

BOOL searchURLDivider( char*p, int head, int tail, int *position ) {
	int i;
	int counter = 0;
	const char* template = "/";
	if( tail - head < 1 )
		return NO;
	for( i = head; i < tail - 1; i++ ) {
		if( !strncmp( p + i, template, 1 ) ) {
			*(position++) = i;
			counter++;
			if( counter > 2 )
				return NO;
		}
	}
	if( counter == 2 )
		return YES;
	return NO;
}

void deleteDataArroundBBSMenu() {
	sqlite3_exec( UIAppDelegate.database, "delete from category", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "delete from board", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "delete from server", NULL, NULL, NULL );
	//	sqlite3_exec( UIAppDelegate.database, "VACUUM", NULL, NULL, NULL );
}

int parseCategory( NSString *categoryTitle ) {
	if (category_insert_statement == nil) {
		static char *sql = "INSERT INTO category (id, title) VALUES(NULL, ?)";
		if (sqlite3_prepare_v2(UIAppDelegate.database, sql, -1, &category_insert_statement, NULL) != SQLITE_OK) {
			DNSLog( @"[BBSMenuParser] Error: failed to prepare insert category statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
			return -1;
		}
	}
	sqlite3_bind_text(category_insert_statement, 1, [categoryTitle UTF8String], -1, SQLITE_TRANSIENT);
	int success = sqlite3_step(category_insert_statement);
	sqlite3_reset(category_insert_statement);
	
	if( success != SQLITE_ERROR )
		return sqlite3_last_insert_rowid(UIAppDelegate.database);
	else
		return -1;
}

int getServerID( NSString* serverName ) {
	if (server_check_statement == nil) {
		static char *sql = "select id from server where address = ?";
		if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &server_check_statement, NULL) != SQLITE_OK) {
			DNSLog( @"[BBSMenuParser] Error: failed to prepare select id from server statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
			return -1;
		}
	}
	sqlite3_bind_text(server_check_statement, 1, [serverName UTF8String], -1, SQLITE_TRANSIENT);
	int success = sqlite3_step(server_check_statement);
	int primaryKey = sqlite3_column_int(server_check_statement, 0);
	sqlite3_reset(server_check_statement);
	
	if( success != SQLITE_ERROR ) {
		if( primaryKey )
			return primaryKey;
		else {
			if( server_insert_statement == nil ) {
				static char *sql2 = "INSERT INTO server (id, address) VALUES(NULL, ?)";
				if (sqlite3_prepare_v2(UIAppDelegate.database, sql2, -1, &server_insert_statement, NULL) != SQLITE_OK) {
					DNSLog( @"[BBSMenuParser] Error: failed to prepare insert id, address statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
					return -1;
				}
			}
			sqlite3_bind_text(server_insert_statement, 1, [serverName UTF8String], -1, SQLITE_TRANSIENT);
			int success = sqlite3_step( server_insert_statement );
			sqlite3_reset( server_insert_statement );
			if (success != SQLITE_ERROR) {
				return sqlite3_last_insert_rowid( UIAppDelegate.database );
			}
			else{
				DNSLog( @"[BBSMenuParser] Error: failed to select id from server statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
				return -1;
			}
		}
	}
	return -1;
}

void insertBoardData( int categoryID, int serverID, NSString* title, NSString* path ) {
	if ( board_insert_statement == nil) {
		static char *sql = "INSERT INTO board (id, server_id, category_id, path, title) VALUES( NULL, ?, ?, ?, ? )";
		if (sqlite3_prepare_v2(UIAppDelegate.database, sql, -1, &board_insert_statement, NULL) != SQLITE_OK) {
			DNSLog( @"[BBSMenuParser] Error: failed to insert board statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
		}
	}
	sqlite3_bind_int( board_insert_statement, 1, serverID );
	sqlite3_bind_int( board_insert_statement, 2, categoryID );
	sqlite3_bind_text( board_insert_statement, 3, [path UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text( board_insert_statement, 4, [title UTF8String], -1, SQLITE_TRANSIENT);
	
	int success = sqlite3_step(board_insert_statement);
	if (success != SQLITE_ERROR) {
	}
	else{
		DNSLog( @"[BBSMenuParser] Error: failed to insert board statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(UIAppDelegate.database));
	}
	sqlite3_reset( board_insert_statement );
}

int get_categoryID_PINKBBS() {
	DNSLog( @"get_categoryID_PINKBBS()" );
	int category_id = 0;
	const char *sql = "select id from category where category.title = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}
	else {
		sqlite3_bind_text( statement, 1, [@"PINKちゃんねる" UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step( statement );
		category_id = sqlite3_column_int( statement, 0 );
		DNSLog( @"%d", category_id );
	}
	sqlite3_finalize( statement );
	return category_id;
}

void deleteBoardOfCategoryID( int categoryID ) {
	DNSLog( @"deleteBoardOfCategoryID()" );
	const char *sql = "delete from board where category_id = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}
	else {
		sqlite3_bind_int( statement, 1, categoryID );
		sqlite3_step( statement );
	}
	sqlite3_finalize( statement );
}

void deleteCategoryOfCategoryID( int categoryID ) {
	DNSLog( @"deleteCategoryOfCategoryID()" );
	const char *sql = "delete from category where id = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}
	else {
		sqlite3_bind_int( statement, 1, categoryID );
		sqlite3_step( statement );
	}
	sqlite3_finalize( statement );
}

void deletePINKBBS() {
	int categoryID_PINKBBS = get_categoryID_PINKBBS();
	deleteBoardOfCategoryID( categoryID_PINKBBS );
	deleteCategoryOfCategoryID( categoryID_PINKBBS );
}

@implementation BBSMenuParser

+ (NSString*)categoryTitleWithCategoryID:(int)category_id {
	DNSLogMethod
	NSString* title = nil;
	const char *sql = "select title from category where id = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, category_id );
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			if( sqlite3_column_text(statement, 0) )
				title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		}
	}
	sqlite3_finalize( statement );
	return title;
}

+ (void)parse:(NSData*)data {
	DNSLogMethod
	sqlite3_exec( UIAppDelegate.database, "BEGIN", NULL, NULL, NULL );
	deleteDataArroundBBSMenu();
	
	int categoryID = 0;
	int i = 0;
	int mode = kBBSMenuSearching;
	char *p = (char*)[data bytes];
	int length = [data length];
	
	const char* category_prefix = "<B>";
	const char* category_suffix = "</B>";
	const char* href_prefix = "<A HREF=http://";
	int start = 0;
	
	for( i = 0; i < length; i++ ) {
		if( mode == kBBSMenuSearching ) {
			if( !strncmp( p+i, category_prefix, 3 ) ){
				mode = kBBSMenuSearchCaetgory;
				start = i;
				i+=3;
			}
			else if( !strncmp( p+i, href_prefix, 15 ) ){
				mode = kBBSMenuSearchHref;
				start = i;
				i+=15;
			}
		}
		else if( mode == kBBSMenuSearchCaetgory ) {
			if( !strncmp( p+i, category_suffix, 4 ) ) {
				NSString* category_name = [StringDecoder decodeBytes:p from:start+3 to:i];
				categoryID = parseCategory( category_name );
				[category_name release];
				mode = kBBSMenuSearching;
			}
		}
		else if( mode == kBBSMenuSearchHref ) {
			if( !strncmp( p+i, "</A>", 4 ) ) {
				int positions[4];
				BOOL r = searchURLDivider( p, start+15, i, positions );
				if( r ) {
					NSString* server = [StringDecoder decodeBytes:p from:start+15 to:positions[0]];
					NSString* path = [StringDecoder decodeBytes:p from:positions[0]+1 to:positions[1]];
					int title_start = searchBoardTitleHead( p, positions[1], i );
					NSString* title = [StringDecoder decodeBytes:p from:title_start+1 to:i];
					
					int serverID = getServerID( server );
					insertBoardData( categoryID, serverID, title, path );
					
					[title release];
					[server release];
					[path release];
				}
				mode = kBBSMenuSearching;
			}
		}
	}
	sqlite3_finalize( category_insert_statement );
	sqlite3_finalize( board_insert_statement );
	sqlite3_finalize( server_insert_statement );
	sqlite3_finalize( server_check_statement );
	category_insert_statement = NULL;
	board_insert_statement = NULL;
	server_check_statement = NULL;
	server_insert_statement = NULL;

	// for avoid adult content
#ifdef _DEBUG
#else
	deletePINKBBS();
#endif
	
	sqlite3_exec( UIAppDelegate.database, "COMMIT", NULL, NULL, NULL );
	sqlite3_exec( UIAppDelegate.database, "END", NULL, NULL, NULL );
}
@end
