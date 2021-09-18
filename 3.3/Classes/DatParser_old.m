//
//  DatParser.m
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatParser_old.h"
#import "StatusManager.h"
#import "string-private.h"
#import "html-tool.h"
#import "DatParser.h"

@implementation DatParser_old

+ (void)getPreviousRes:(int*)prevRes res:(int*)res withDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	*prevRes = 1;
	*res = 1;
	const char *sql = "select prev_res, res from threadInfo where dat = ? and path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			if( sqlite3_column_int(statement, 0) > 0 )
				*prevRes = sqlite3_column_int(statement, 0);
			if( sqlite3_column_int(statement, 1) > 0 )
				*res = sqlite3_column_int(statement, 1);
		}
	}
	sqlite3_finalize( statement );
}

+ (NSString*)categoryTitleWithPath:(int)category_id {
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

+ (NSString*)boardTitleWithPath:(NSString*)path {
	DNSLogMethod
	NSString* title = nil;
	const char *sql = "select title from board where path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			if( sqlite3_column_text(statement, 0) )
				title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		}
	}
	sqlite3_finalize( statement );
	return title;
}

+ (NSString*)threadTitleFromReadCGIWithDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	NSString *title = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNDownloaderCancel" object:self];
	const char *sql = "select 'http://' || server.address || '/test/read.cgi/' || board.path || '/' || ? || '/l1' from board, server where server.id = board.server_id and board.path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		DNSLog( @"%d-%@", dat, path );
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			NSString* url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			DNSLog( url );
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
			NSURLResponse *response = nil;
			NSError *error = nil;
			NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			NSString* decoded = decodeNSData(data);
			
			NSRange start = [decoded rangeOfString:@"<title>" options:NSCaseInsensitiveSearch];
			NSRange end = [decoded rangeOfString:@"</title>" options:NSCaseInsensitiveSearch];

			if( start.location != NSNotFound && end.location != NSNotFound ) {
				title = [decoded substringWithRange:NSMakeRange( start.location + start.length, end.location - ( start.location + start.length ) )];
			}
			
			[decoded release];
		}
	}
	sqlite3_finalize( statement );
	return title;
}

+ (NSString*)threadTitleFromUntrasedData:(int)dat path:(NSString*)path {
	DNSLogMethod
	return nil;
}

+ (NSString*)threadTitleWithDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	NSString* title = nil;
	const char *sql = "select title from subject where dat = ? and path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			if( sqlite3_column_text(statement, 0) )
				title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		}
	}
	sqlite3_finalize( statement );
	
//	if( title == nil ) {
//		title = [DatParser_old threadTitleFromReadCGIWithDat:dat path:path];
//	}
	return title;
}

+ (void)getBytes:(int*)bytes lastModified:(NSString**)lastModified resRead:(int*)resRead ofPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	const char *sql = "select bytes, res, modified from threadInfo where dat = ? and path = ?";
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, dat );
		sqlite3_bind_text( statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			*bytes = sqlite3_column_int(statement, 0);
			*resRead = sqlite3_column_int(statement, 1) == 0 ? 1 : sqlite3_column_int(statement, 1);
			if( sqlite3_column_text(statement, 2) )
				*lastModified = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
		}
	}
	sqlite3_finalize( statement );
}

+ (void)insertSubjectWithBytes:(int)bytes lastModified:(NSString*)lastModified resRead:(int)resRead title:(NSString*)title ofPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	static char *sql = "INSERT INTO threadInfo (id, bytes, modified, dat, path, res, title, res_read, prev_res ) VALUES(NULL, ?, ?, ?, ?, ?, ?, 1, 1 )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bytes );
		sqlite3_bind_text(statement, 2, [lastModified UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 3, dat );
		sqlite3_bind_text( statement, 4, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 5, resRead );
		sqlite3_bind_text( statement, 6, [title UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

+ (void)updateReadRes:(int)resRead path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	static char *sql = "update threadInfo set res_read = ? where dat = ? and path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, resRead );
		sqlite3_bind_int( statement, 2, dat );
		sqlite3_bind_text( statement, 3, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
			DNSLog( @"%d", sqlite3_changes( UIAppDelegate.database ) );
		}
	}
	sqlite3_finalize( statement );
}

+ (void)updateSubjectWithBytes:(int)bytes lastModified:(NSString*)lastModified resRead:(int)resRead previousRes:(int)previousRes ofPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	static char *sql = "update threadInfo set bytes = ?, modified = ?, res = ?, prev_res = ? where dat = ? and path = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, bytes );
		sqlite3_bind_text(statement, 2, [lastModified UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 3, resRead );
		sqlite3_bind_int( statement, 4, previousRes );
		sqlite3_bind_int( statement, 5, dat );
		sqlite3_bind_text( statement, 6, [path UTF8String], -1, SQLITE_TRANSIENT);
		int success = sqlite3_step(statement);		
		if (success != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

+ (void)makeDirectoryOfPath:(NSString*)path {
	NSString* folder_path = [NSString stringWithFormat:@"%@/%@", DocumentFolderPath, path];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:folder_path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:folder_path attributes:nil];
	}
}

+ (void) append:(NSData*)data toArray:(NSMutableArray*)array {
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];	
	int	new_res = 0;
	
	DNSLog( @"%d byte",[data length] );
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
			NSArray*values = [decoded componentsSeparatedByString:@"<>"];
			if( [values count] == 5 ) {
				NSString *name = [values objectAtIndex:0];
				NSString *email = [values objectAtIndex:1];
				NSString *date_id = [values objectAtIndex:2];
				NSString *body = [values objectAtIndex:3];
				
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  eliminateHTMLTag(name),		@"name",
									  email,						@"email",
									  eliminateHTMLTag(date_id),	@"date_id",
									  extractLink(body),			@"body",
									  nil];
				[array addObject:dict];
				new_res++;
			}
			[decoded release];
			head = i + 1;
		}
	}
}

+ (BOOL) write:(NSMutableArray*)array path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	NSString *cachepath =[NSString stringWithFormat:@"%@/%@/%d.dat", DocumentFolderPath, path, dat];
	[DatParser_old makeDirectoryOfPath:path];
	
	// make dictionary data to
	if( [array count] > 0 ) {
		DNSLog( @"%d res is wrote.", [array count] );
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"NSMutableArray", nil];
		return [dict writeToFile:cachepath atomically:NO];
	}
	else {
		return [[NSFileManager defaultManager] removeItemAtPath:cachepath error:nil];
	}
}

+ (NSMutableArray*)resListOfPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	NSString *cachepath =[NSString stringWithFormat:@"%@/%@/%d.dat", DocumentFolderPath, path, dat];
	[DatParser_old makeDirectoryOfPath:path];
	if( [[NSFileManager defaultManager] fileExistsAtPath:cachepath] ) {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:cachepath];
		return [NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]];
	}
	else {
		return nil;
	}
}

+ (int)appendNewThreadData:(NSData*)data path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	// read cache
	NSString *cachepath =[NSString stringWithFormat:@"%@/%@/%d.dat", DocumentFolderPath, path, dat];
	NSMutableArray *list = nil;
	int previous_res = 0;
	int comming_res = 0;
	int all_res = 0;
	
	[DatParser_old makeDirectoryOfPath:path];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:cachepath] ) {
		list = [[NSMutableArray alloc] init];
		DNSLog( @"make new dat data" );
	}
	else {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:cachepath];
		list = [[NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]] retain];
		DNSLog( @"load exsting dat data - %d res exists", [list count] );
	}
	
	previous_res = [list count];
	
	CFAbsoluteTime start_time, end_time;
	start_time = CFAbsoluteTimeGetCurrent();
	[DatParser parse:data toArray:list];
	end_time = CFAbsoluteTimeGetCurrent();
	NSLog(@"[floating] %f seconds", end_time - start_time );
	
	[DatParser_old write:list path:path dat:dat];
	
	comming_res = [list count] - previous_res;
	all_res = [list count];
	
	[list release];
	return all_res;
}

@end
