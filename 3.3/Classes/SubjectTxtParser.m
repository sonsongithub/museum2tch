//
//  SubjectTxtParser.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectTxtParser.h"
#import "string-private.h"
#import "StatusManager.h"

@implementation SubjectTxtParser

+ (BOOL) writeSubjectTxt:(NSData*)data withPath:(NSString*)path {
	NSString* file_path = [[NSString alloc] initWithFormat:@"%@/%@/subject.cache", DocumentFolderPath, path];
	NSString* folder_path = [[NSString alloc] initWithFormat:@"%@/%@/", DocumentFolderPath];

	if( ![[NSFileManager defaultManager] fileExistsAtPath:folder_path] )
		[[NSFileManager defaultManager] createDirectoryAtPath:folder_path attributes:nil];
	
	BOOL result = [data writeToFile:file_path atomically:NO];
	[file_path release];
	[folder_path release];
	return result;
}

- (void) deletePreviousData {
	DNSLogMethod
	const char *sql = "delete from subject where subject.path = ?;";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text( statement, 2, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
		/*int success = */sqlite3_step(statement);
	}
	sqlite3_finalize(  statement );
}

- (void) parse:(NSData*)data {
	DNSLogMethod
	[self deletePreviousData];

	// DNSLog( @"try to vacuum" );
	// sqlite3_exec( UIAppDelegate.database, "VACUUM", NULL, NULL, NULL );
	
	int test_counter = 0;
	
	sqlite3_exec( UIAppDelegate.database, "BEGIN", NULL, NULL, NULL );
	sqlite3_stmt *statement;
	static char *sql = "INSERT INTO subject (id, number, source, path ) VALUES(NULL, ?, ?, ?)";
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
		//	DNSLog( decoded );
			sqlite3_bind_int( statement, 1, test_counter );
			sqlite3_bind_text( statement, 2, [decoded UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text( statement, 3, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
			/*int success = */sqlite3_step( statement );
			sqlite3_reset( statement );
			test_counter++;
			head = i + 1;
			[decoded release];
		}
	}
	sqlite3_exec( UIAppDelegate.database, "COMMIT", NULL, NULL, NULL );
	sqlite3_finalize(  statement );
}

@end
