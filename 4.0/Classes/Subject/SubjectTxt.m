//
//  SubjectTxt.m
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectTxt.h"
#import "SubjectData.h"

@implementation SubjectTxt

@synthesize source = source_;
@synthesize cache = cache_;
@synthesize newComming = newComming_;
@synthesize path = path_;

@synthesize sourceLimited = sourceLimited_;
@synthesize cacheLimited = cacheLimited_;
@synthesize newCommingLimited = newCommingLimited_;

#pragma mark Class Method

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

+ (void)makeDirectoryOfPath:(NSString*)path {
	NSString* folder_path = [NSString stringWithFormat:@"%@/%@", DocumentFolderPath, path];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:folder_path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:folder_path attributes:nil];
	}
}

#pragma mark Original Method

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

- (BOOL)hasData {
	return ( [source_ count] > 0 );
}

- (id)initWithPath:(NSString*)path {
	DNSLogMethod
	self = [super init];
	self.path = [[NSString alloc] initWithString:path];
	self.source = [[NSMutableArray alloc] init];
	self.cache = [[NSMutableArray alloc] init];
	self.newComming = [[NSMutableArray alloc] init];
	self.sourceLimited = [[NSMutableArray alloc] init];
	self.cacheLimited = [[NSMutableArray alloc] init];
	self.newCommingLimited = [[NSMutableArray alloc] init];
	
	[self.path release];
	[self.source release];
	[self.cache release];
	[self.newComming release];
	[self.sourceLimited release];
	[self.cacheLimited release];
	[self.newCommingLimited release];
	
	[self load];
	[self makeCacheAndNewCommingData];
	return self;
}

- (void)makeCacheAndNewCommingData {
	DNSLogMethod
	const char *sql = "SELECT dat, res, res_read, title FROM threadInfo where path = ? order by id desc";
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
				
				dataToUpdate.read = sqlite3_column_int( statement, 2 );
				dataToUpdate.readString = [NSString stringWithFormat:@"%03d", dataToUpdate.read];
				
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
				threadNotAppearedInSubject.read = sqlite3_column_int( statement, 2 );
				threadNotAppearedInSubject.resString = [NSString stringWithFormat:@"%03d", threadNotAppearedInSubject.res];
				threadNotAppearedInSubject.readString = [NSString stringWithFormat:@"%03d", threadNotAppearedInSubject.read];
				if( sqlite3_column_text(statement, 3) )
					threadNotAppearedInSubject.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				[cache_ addObject:threadNotAppearedInSubject];
				[threadNotAppearedInSubject release];
			}
		}
	}
	sqlite3_finalize(  statement );
}

- (void)load {
	DNSLogMethod
	[SubjectTxt makeDirectoryOfPath:path_];
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/subject.plist", DocumentFolderPath, path_];
	if( [[NSFileManager defaultManager] fileExistsAtPath:plistPath] ) {
		NSData *data  = [NSData dataWithContentsOfFile:plistPath];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[source_ addObjectsFromArray:[decoder decodeObjectForKey:@"subject"]];
		[decoder finishDecoding];
		[decoder release];
	}
}

- (void)write {
	DNSLogMethod
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[SubjectTxt makeDirectoryOfPath:path_];
	NSString *plistPath = [NSString stringWithFormat:@"%@/%@/subject.plist", DocumentFolderPath, path_];
	[encoder encodeObject:source_ forKey:@"subject"];
	[encoder finishEncoding];
	
	[data writeToFile:plistPath atomically:NO];
	[encoder release];	
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	// [self write];
	[sourceLimited_ release];
	[cacheLimited_ release];
	[newCommingLimited_ release];
	[source_ release];
	[cache_ release];
	[newComming_ release];
	[path_ release];
	[super dealloc];
}

@end
