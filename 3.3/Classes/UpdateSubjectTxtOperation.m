//
//  UpdateSubjectTxtOperation.m
//  2tch
//
//  Created by sonson on 08/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UpdateSubjectTxtOperation.h"
#import "TitleViewController.h"
#import "html-tool.h"
#import "StatusManager.h"

NSString* getDat( NSString* dat ) {
	return [dat substringToIndex:([dat length]-4)];
}

NSString* getThreadTitle (NSString* input) {
	int i;
	int head_num = 0;
	int tail_num = 0;
	
	for(i = [input length] - 1; i >= 0; i--) {
		if([input characterAtIndex: i] == ')')
			tail_num = i;
		
		if( tail_num != 0 && [input characterAtIndex: i] == '(') {
			head_num = i;
			break;
		}
	}
	if( head_num == 0 )
		head_num = [input length];
	
	return getConvertedSpecialChar( [input substringWithRange:NSMakeRange( 0, head_num )] );
}

NSString* getThreadResNumber (NSString* input) {
	int i;
	int head_num = 0;
	int tail_num = 0;
	
	for(i = [input length] - 1; i >= 0; i--) {
		if([input characterAtIndex: i] == ')')
			tail_num = i;
		
		if( tail_num != 0 && [input characterAtIndex: i] == '(') {
			head_num = i;
			break;
		}
	}
	return [input substringWithRange:NSMakeRange( head_num + 1, tail_num - ( head_num + 1 ) )];
}

void updateSubjectDictionary( NSString* source, NSString** dat, NSString** title, NSString** res ) {
	NSArray*values = [source componentsSeparatedByString:@".dat<>"];
	
	*title = getThreadTitle( [values objectAtIndex:1] );
	*res = getThreadResNumber( [values objectAtIndex:1] );	
	*dat = [values objectAtIndex:0];
	
#if TARGET_IPHONE_SIMULATOR
//	[NSThread sleepForTimeInterval:0.075];
#endif
}

@implementation UpdateSubjectTxtOperation

- (id)initWithMutableArray:(NSMutableArray*)input delegate:(TitleViewController*)delegate queue:(NSOperationQueue*)qq {
	DNSLogMethod
	self = [super init];
	
	delegate_ = [delegate retain];
	cellData_ = input;
	queue_ = [qq retain];
	
	return self;
}

- (void) dealloc {
	DNSLogMethod
	[delegate_ release];
	[queue_ release];
	[super dealloc];
}

- (void)insertNewDataWithStatement:(sqlite3_stmt*)statement_new path:(NSString*)path dat:(NSString*)dat title:(NSString*)title res:(NSString*)res number:(int)number {
	// DNSLogMethod
	sqlite3_bind_int( statement_new, 1, [dat intValue] );									// dat
	sqlite3_bind_text(statement_new, 2, [title UTF8String], -1, SQLITE_TRANSIENT);			// title
	sqlite3_bind_int( statement_new, 3, [res intValue] );									// res_got
	sqlite3_bind_int( statement_new, 4, number );											// number
	sqlite3_bind_text( statement_new, 5, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_step( statement_new );
	sqlite3_reset( statement_new );
}

- (NSDictionary*)updateASubjectDataWithSelectStatement:(sqlite3_stmt*)statement_select deleteStatement:(sqlite3_stmt*)statement_delete insertStatement:(sqlite3_stmt*)statement_new {
	// DNSLogMethod
	NSNumber* number = [NSNumber numberWithInt:sqlite3_column_int(statement_select, 0)];
	NSString* source = [NSString stringWithUTF8String:(char *)sqlite3_column_text( statement_select, 1)];
	NSString* dat = nil;
	NSString* title = nil;
	NSString* res = nil;
	updateSubjectDictionary( source, &dat, &title, &res );
	
	if( number && dat && title &&  res ) {
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
				number, @"number",
				dat,	@"dat",
				title,	@"title",
				res,	@"res",
						  nil];
		return dict;
	}
	return nil;
}

- (void)alreadyLoadedWithStatement:(sqlite3_stmt*)statement_delete from:(int)from to:(int)to {
	sqlite3_bind_int( statement_delete, 1, from );
	sqlite3_bind_int( statement_delete, 2, to );
	sqlite3_bind_text( statement_delete, 3, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_step( statement_delete );
	sqlite3_reset( statement_delete );
}

- (void)doSomething {
	DNSLogMethod
	const char *sql_select = "SELECT number, source FROM subject where title is null and subject.path = ? limit 50;";
	static char *sql_delete_old = "delete from subject where number >= ? and number <= ? and title is null and subject.path = ?";
	static char *sql_new = "INSERT INTO subject (id, dat, title, res, number, path ) VALUES(NULL, ?, ?, ?, ?, ?)";
	static sqlite3_stmt *statement_select = nil;
	static sqlite3_stmt *statement_delete = nil;
	static sqlite3_stmt *statement_new = nil;
	
	@synchronized(delegate_) {
		delegate_.isLoading = YES;
	}
	
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql_select, -1, &statement_select, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql_delete_old, -1, &statement_delete, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	if (sqlite3_prepare_v2( UIAppDelegate.database, sql_new, -1, &statement_new, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( UIAppDelegate.database ));
		return;
	}
	while(1) {
		sqlite3_bind_text( statement_select, 1, [UIAppDelegate.status.path UTF8String], -1, SQLITE_TRANSIENT);
		
		if( [self isCancelled] )
			goto finished;

		if( sqlite3_step( statement_select ) != SQLITE_ROW ) {
			@synchronized(delegate_) {
				delegate_.isLoading = NO;
			}
			break;
		}
		
		NSMutableArray *ary = [[NSMutableArray alloc] init];
		NSDictionary *dict = [self updateASubjectDataWithSelectStatement:statement_select deleteStatement:statement_delete insertStatement:statement_new];
		[ary addObject:dict];
		
		while( sqlite3_step( statement_select ) == SQLITE_ROW ) {
			if( [self isCancelled] ) {
				[ary release];
				goto finished;
			}
			NSDictionary *dict = [self updateASubjectDataWithSelectStatement:statement_select deleteStatement:statement_delete insertStatement:statement_new];
			[ary addObject:dict];
		}
		
		sqlite3_exec( UIAppDelegate.database, "BEGIN", NULL, NULL, NULL );
		for( NSDictionary* dict in ary ) {
			[self insertNewDataWithStatement:statement_new 
										path:UIAppDelegate.status.path
										 dat:[dict objectForKey:@"dat"]
									   title:[dict objectForKey:@"title"] 
										 res:[dict objectForKey:@"res"] 
									  number:[[dict objectForKey:@"number"] intValue]];
		}
		sqlite3_exec( UIAppDelegate.database, "COMMIT", NULL, NULL, NULL );
		
		int head = [[[ary objectAtIndex:0] objectForKey:@"number"] intValue];
		int tail = [[[ary lastObject] objectForKey:@"number"] intValue];
		[self alreadyLoadedWithStatement:statement_delete from:head to:tail];
		
		[ary release];
		sqlite3_reset( statement_select );
		if( [self isCancelled] )
			goto finished;
		
		@synchronized(delegate_) {
			[(TitleViewController*)delegate_ reloadCell];
			[delegate_ performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
		}
	}
	// sqlite3_exec( UIAppDelegate.database, "VACUUM", NULL, NULL, NULL );
finished:
	sqlite3_finalize( statement_new );
	sqlite3_finalize( statement_delete );
	sqlite3_finalize( statement_select );
	@synchronized( delegate_ ) {
		[delegate_ setFinished];
	}
	[delegate_ performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
}

- (void) main {
	DNSLogMethod
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self doSomething];
	DNSLog( @"thread title update is finished" );
	[pool release];
}

@end