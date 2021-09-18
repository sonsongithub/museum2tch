//
//  Dat.m
//  2tch
//
//  Created by sonson on 08/12/21.
//  Copyright 2008 sonson. All rights reserved.
//

#import "Dat.h"
#import "DatParser.h"
#import "ThreadResData.h"
#import "ThreadLayoutComponent.h"
/*
void layout(NSMutableArray* array ) {
	CGRect rect;
	float line = HeightThreadFont;
	for( ThreadResData* ro in array ) {
		float height = HeightThreadInfoFont * 2 + 4 + 5;
		for( ThreadLayoutComponent* sr in ro.body ) {
			if( sr.textInfo != kThreadLayoutNewLine ) {
				rect.origin.x = 5;
				rect.origin.y = height;
				rect.size.width = width - 15;
				rect.size = [sr.text sizeWithFont:threadFont constrainedToSize:CGSizeMake(rect.size.width, 1300) lineBreakMode:UILineBreakModeWordWrap];
				height += rect.size.height;
				sr.rect = rect;
			}
			else {
				height += line;
			}
		}
		ro.height = height;
	}
}
*/

void layout(NSMutableArray* array, int width ) {
	CGRect rect;
	for( ThreadResData* ro in array ) {
		float height = THREAD_BODY_TOP_MARGIN + HeightThreadInfoFont * 2;
		for( ThreadLayoutComponent* sr in ro.body ) {
			if( sr.textInfo == kThreadLayoutText ) {
				rect.origin.x = 5;
				rect.origin.y = height;
				rect.size.width = width - 15;
				rect.size = [sr.text sizeWithFont:threadFont constrainedToSize:CGSizeMake(rect.size.width, 1300) lineBreakMode:UILineBreakModeWordWrap];
				height += rect.size.height;
				sr.rect = rect;
			}
			else {
				rect.origin.x = 5;
				rect.origin.y = height;
				rect.size.width = width - 15;
				rect.size = [sr.text sizeWithFont:threadFont constrainedToSize:CGSizeMake(rect.size.width, 1300) lineBreakMode:UILineBreakModeWordWrap];
				rect.size.width += ANCHOR_OFFSET_X * 2;
				rect.size.height += ANCHOR_OFFSET_Y * 2;
				height += rect.size.height;
				sr.rect = rect;
			}
		}
		ro.height = height + THREAD_BODY_BOTTOM_MARGIN;
	}
}

void loadNSString( FILE *fp, NSString **string ) {
#ifdef _UNICHAR
	unichar *p = NULL;
	int length = 0;
	fread( &length, sizeof(length), 1, fp );
	p = (unichar*)malloc( sizeof(unichar) * ( length ) );
	fread( p, sizeof(unichar), length, fp );
	
	*string = [[NSString alloc] initWithCharacters:p length:length];
	
	free( p );
#else
	int byteLength = 0;
	char* p = NULL;
	fread( &byteLength, sizeof(byteLength), 1, fp );
	p = (char*)malloc( sizeof(char) * ( byteLength + 1 ) );
	fread( p, sizeof(char), byteLength, fp );
	p[byteLength] = '\0';
	*string = [[NSString alloc] initWithBytes:p length:byteLength encoding:NSUTF8StringEncoding];
	// *string = [NSString stringWithUTF8String:p];
	free( p );
#endif
}

void loadInt( FILE *fp, int *value ) {
	fread( value, sizeof(int), 1, fp );
}

void writeNSString( FILE *fp, NSString *string ) {
#ifdef _UNICHAR
	unichar *p = NULL;
	int length = [string length];
	p = (unichar*)malloc( sizeof(unichar) * ( length ) );
	[string getCharacters:p];
	fwrite( &length, sizeof(length), 1, fp);
	fwrite( p, sizeof(unichar), length, fp);
	free( p );
#else
	char *p = (char*)[string cStringUsingEncoding:NSUTF8StringEncoding];
	int byteLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	fwrite( &byteLength, sizeof(byteLength), 1, fp);
	fwrite( p, sizeof(char), byteLength, fp);
#endif
}

void writeInt( FILE *fp, int input ) {
	fwrite( &input, sizeof(input), 1, fp);
}

@implementation Dat

@synthesize title = title_;
@synthesize resList = resList_;
@synthesize path = path_;
@synthesize dat = dat_;
@synthesize bytes = bytes_;
@synthesize savedScroll = savedScroll_;
@synthesize lastModified = lastModified_;

#pragma mark Function for writing

+ (void)makeDirectoryOfPath:(NSString*)path {
	NSString* folder_path = [NSString stringWithFormat:@"%@/%@", DocumentFolderPath, path];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:folder_path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:folder_path attributes:nil];
	}
}

#pragma mark Update res, res_read, title of threadInfo where path, dat

+ (BOOL)updateThreadInfoWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat {
	BOOL isUpdateSuccessful = [Dat updateSubjectWithRes:res resRead:res_read title:title path:path dat:dat];
	if( !isUpdateSuccessful ) {
		// insert new record
		[Dat insertSubjectWithRes:res resRead:res_read title:title path:path dat:dat];
	}
	return YES;
}

+ (void)insertSubjectWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	static char *sql = "INSERT INTO threadInfo (id, res, res_read, title, path, dat ) VALUES(NULL, ?, ?, ?, ?, ? )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, res );
		sqlite3_bind_int( statement, 2, res_read );
		sqlite3_bind_text( statement, 3, [title UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text( statement, 4, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 5, dat );
		sqlite3_step(statement);
	}
	sqlite3_finalize( statement );
}

+ (BOOL)updateSubjectWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	int changes = 0;
	static char *sql = "update threadInfo set res = ?, res_read = ? where path = ? and dat = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, res );
		sqlite3_bind_int( statement, 2, res_read );
		sqlite3_bind_text(statement, 3, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 4, dat );
		sqlite3_step( statement );
		changes = sqlite3_changes( UIAppDelegate.database );
	}
	sqlite3_finalize( statement );
	return ( changes > 0 );
}

#pragma mark Update res, title, path, dat of threadInfo

+ (BOOL)updateThreadInfoWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat {
	BOOL isUpdateSuccessful = [Dat updateSubjectWithoutResReadWithRes:res title:title path:path dat:dat];
	if( !isUpdateSuccessful ) {
		// insert new record
		[Dat insertSubjectWithoutResReadWithRes:res title:title path:path dat:dat];
	}
	return YES;
}

+ (void)insertSubjectWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	static char *sql = "INSERT INTO threadInfo (id, res, title, path, dat ) VALUES(NULL, ?, ?, ?, ?, ? )";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, res );
		sqlite3_bind_text( statement, 2, [title UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text( statement, 3, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 4, dat );
		sqlite3_step(statement);
	}
	sqlite3_finalize( statement );
}

+ (BOOL)updateSubjectWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat {
	DNSLogMethod
	int changes = 0;
	static char *sql = "update threadInfo set res = ? where path = ? and dat = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_int( statement, 1, res );
		sqlite3_bind_text(statement, 2, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 3, dat );
		sqlite3_step( statement );
		changes = sqlite3_changes( UIAppDelegate.database );
	}
	sqlite3_finalize( statement );
	return ( changes > 0 );
}

#pragma mark Update lastOffset, date, res_read Of threadInfo where path, dat

+ (BOOL)updateLastOffset:(float)offset path:(NSString*)path dat:(int)dat res_read:(int)res_read {
	DNSLogMethod
	int changes = 0;
	static char *sql = "update threadInfo set lastOffset = ?, date = ?, res_read = ? where path = ? and dat = ?";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		CFAbsoluteTime current_time = CFAbsoluteTimeGetCurrent();
		sqlite3_bind_double( statement, 1, offset);
		sqlite3_bind_double( statement, 2, current_time);
		sqlite3_bind_int( statement, 3, res_read);
		sqlite3_bind_text(statement, 4, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 5, dat );
		sqlite3_step( statement );
		changes = sqlite3_changes( UIAppDelegate.database );
	}
	sqlite3_finalize( statement );
	return ( changes > 0 );
}

#pragma mark return lastOffset of path and dat

+ (float)lastOffsetWithPath:(NSString*)path dat:(int)dat {
	DNSLogMethod
	float lastOffset = 0;
	const char *sql = "SELECT lastOffset FROM threadInfo where path = ? and dat = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [path UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int( statement, 2, dat );
		sqlite3_step( statement );
		lastOffset = sqlite3_column_double( statement, 0 );
		sqlite3_finalize(  statement );
	}
	return lastOffset;
}

#pragma mark Original method

- (BOOL)hasData {
	return ( [resList_ count] > 0 );
}

- (id)initWithDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	self = [super init];

	self.dat = dat;
	self.path = path;
	self.resList = [[NSMutableArray alloc] init];
	[self.resList release];
	
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%d.plist", DocumentFolderPath, path_, dat_];
	if( [[NSFileManager defaultManager] fileExistsAtPath:plistPath] ) {
		[self loadWithFILE];
	}
	layout( self.resList, 300 );
	
	return self;
}

- (void)loadWithFILE {
	int i,j;
	DNSLogMethod
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%d.plist", DocumentFolderPath, path_, dat_];
	FILE *fp = fopen( [plistPath UTF8String], "rb" );
	
	NSString* test = nil;
	int value = 0;
	int counter, body_counter;
	int textInfo = 0;
	
	loadNSString( fp, &test );
	self.title = test;
	[test release];
		
	loadNSString( fp, &test );
	self.path = test;
	[test release];
	
	loadNSString( fp, &test );
	self.lastModified = test;
	[test release];
	
	loadInt( fp, &value );
	self.bytes = value;
	
	loadInt( fp, &value );
	self.savedScroll = value;
	
	loadInt( fp, &value );
	self.dat = value;
	
	loadInt( fp, &counter );
	
	self.resList = [[NSMutableArray alloc] init];
	[self.resList release];
	
	for( i = 0; i < counter; i++ ) {
		ThreadResData* data = [[ThreadResData alloc] init];
		loadNSString( fp, &test );	// date
		data.date = test;
		[test release];
		loadNSString( fp, &test );	// email
		data.email = test;
		[test release];
		loadNSString( fp, &test );	// name
		data.name = test;
		[test release];
		loadNSString( fp, &test );	// numberString
		data.numberString = test;
		[test release];
	
		data.body = [[NSMutableArray alloc] init];
		[data.body release];

		loadInt( fp, &body_counter );
		for( j = 0; j < body_counter; j++ ) {
			ThreadLayoutComponent* component = [[ThreadLayoutComponent alloc] init];
			loadNSString( fp, &test );
			component.text = test;
			[test release];
			loadInt( fp, &textInfo );
			component.textInfo = textInfo;
			[data.body addObject:component];
			[component release];
		}
		[self.resList addObject:data];
		[data release];
	}
#ifdef _DEBUG
	int result = fclose( fp );
	DNSLog( @"fclose - %d", result );
#else
	fclose( fp );
#endif
}

- (void)writeWithFILE {
	DNSLogMethod
	[Dat makeDirectoryOfPath:path_];
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%d.plist", DocumentFolderPath, path_, dat_];
	DNSLog( @"%@", plistPath );
	FILE *fp = fopen( [plistPath UTF8String], "wb" );
	
	int i,j;
	int counter = 0;
	int body_counter = 0;
	
	DNSLog( @"write bytes - %d", self.bytes );

	writeNSString( fp, title_ );
	writeNSString( fp, path_ );
	writeNSString( fp, lastModified_ );
	writeInt( fp, bytes_ );
	writeInt( fp, savedScroll_ );
	writeInt( fp, dat_ );
	
	counter = [resList_ count];
	writeInt( fp, counter );
	
	for( i = 0; i < counter; i++ ) {
		ThreadResData* data = [resList_ objectAtIndex:i];
		writeNSString( fp, data.date );
		writeNSString( fp, data.email );
		writeNSString( fp, data.name );
		writeNSString( fp, data.numberString );
		NSMutableArray* body = data.body;
		body_counter = [body count];
		writeInt( fp, body_counter );
		for( j = 0; j < body_counter; j++ ) {
			ThreadLayoutComponent* component = [body objectAtIndex:j];
			writeNSString( fp, component.text );
			writeInt( fp, component.textInfo );
		}
	}
#ifdef _DEBUG
	int result = fclose( fp );
	DNSLog( @"fclose - %d", result );
#else
	fclose( fp );
#endif
}

- (void)write {
	DNSLogMethod
	[self writeWithFILE];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[path_ release];
	[title_ release];
	[resList_ release];
	[lastModified_ release];
	[super dealloc];
}

@end
