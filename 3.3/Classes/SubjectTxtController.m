//
//  SubjectTxtController.m
//  2tch
//
//  Created by sonson on 08/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectTxtController.h"
#import "SubjectParser.h"
#import "DatParser_old.h"

@implementation SubjectTxtController

@synthesize source = source_;
@synthesize cache = cache_;
@synthesize newComming = newComming_;
@synthesize path = path_;

@synthesize sourceLimited = sourceLimited_;
@synthesize cacheLimited = cacheLimited_;
@synthesize newCommingLimited = newCommingLimited_;

- (SubjectData*) searchDataWithDat:(int)dat {
	for( SubjectData* data in source_ ) {
		if( data.dat == dat )
			return data;
	}
	return nil;
}

- (void)limitWithKeyword:(NSString*)keyword {
	[sourceLimited_ removeAllObjects];
	[cacheLimited_ removeAllObjects];
	[newCommingLimited_ removeAllObjects];
	
	for( SubjectData *data in source_ ) {
		if( [data.title rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[sourceLimited_ addObject:data];
		}
	}
	for( SubjectData *data in cache_ ) {
		if( [data.title rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[cacheLimited_ addObject:data];
		}
	}
	for( SubjectData *data in newComming_ ) {
		if( [data.title rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[newCommingLimited_ addObject:data];
		}
	}
}

- (id)initWithPath:(NSString*)path {
	DNSLogMethod
	self = [super init];
	path_ = [[NSString alloc] initWithString:path];
	source_ = [[NSMutableArray alloc] init];
	cache_ = [[NSMutableArray alloc] init];
	newComming_ = [[NSMutableArray alloc] init];
	
	sourceLimited_ = [[NSMutableArray alloc] init];
	cacheLimited_ = [[NSMutableArray alloc] init];
	newCommingLimited_ = [[NSMutableArray alloc] init];
	
	[DatParser_old makeDirectoryOfPath:path];
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/subject.plist", DocumentFolderPath, path];
	NSData *data  = [NSData dataWithContentsOfFile:plistPath];
	NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	[source_ addObjectsFromArray:[decoder decodeObjectForKey:@"subject"]];
	[decoder finishDecoding];
	[decoder release];
	
	[self makeCacheAndNewCommingData];
	
	return self;
}

- (void)makeCacheAndNewCommingData {
	const char *sql = "SELECT dat, res, prev_res, res_read, title FROM threadInfo where path = ? order by id desc";
	[cache_ removeAllObjects];
	[newComming_ removeAllObjects];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"[MainViewController] Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
	}	
	else {
		sqlite3_bind_text( statement, 1, [path_ UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int dat = sqlite3_column_int( statement, 0 );
			SubjectData* dataToUpdate = [self searchDataWithDat:dat];
			if( dataToUpdate != nil ) {
				if( dataToUpdate.res > sqlite3_column_int( statement, 1 ) ) {
					[cache_ addObject:dataToUpdate];
					[newComming_ addObject:dataToUpdate];
				}
				else {
					dataToUpdate.res = sqlite3_column_int( statement, 1 );
					[cache_ addObject:dataToUpdate];
				}
			}
			else {
				SubjectData* threadNotAppearedInSubject = [[SubjectData alloc] init];
				threadNotAppearedInSubject.dat = dat;
				threadNotAppearedInSubject.res = sqlite3_column_int( statement, 1 );
				if( sqlite3_column_text(statement, 4) )
					threadNotAppearedInSubject.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
				[cache_ addObject:threadNotAppearedInSubject];
			}
		}
	}
	sqlite3_finalize(  statement );
}

- (void)write {
	DNSLogMethod
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[DatParser_old makeDirectoryOfPath:path_];
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/subject.plist", DocumentFolderPath, path_];
	[encoder encodeObject:source_ forKey:@"subject"];
	[encoder finishEncoding];
	
	[data writeToFile:plistPath atomically:YES];
	[encoder release];	
}

- (void)dealloc {
	DNSLogMethod
	[self write];
	[sourceLimited_ release];
	[cacheLimited_ release];
	[newCommingLimited_ release];
	[source_ release];
	[cache_ release];
	[newComming_ release];
	[super dealloc];
}

@end
