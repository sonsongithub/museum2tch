//
//  ThreadDat.m
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "ThreadDat.h"
#import "global.h"
#import "html-tool.h"
#import "DatInfo.h"
#import "SubjectTxt.h"

@implementation ThreadDat

@synthesize dat = dat_;
@synthesize boardPath = boardPath_;
@synthesize resList = resList_;
@synthesize newResNumber = newResNumber_;

#pragma mark Class method

+ (void) removeEvacuation {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/thread.evacuated", documentsDirectory];
	if( [[NSFileManager defaultManager] fileExistsAtPath:filepath] ) {		
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
	}
}

+ (ThreadDat*) ThreadDatWithBoardPath:boardPath dat:(NSString*)dat {
	ThreadDat* obj = [[ThreadDat alloc] init];
	
	obj.boardPath = [[NSString stringWithString:boardPath] retain];
	obj.dat = [[NSString stringWithString:dat] retain];
	
	DatInfo*datObj = [DatInfo DatInfoWithBoardPath:obj.boardPath];
	NSMutableDictionary *datInfoDict = [datObj dictOfDat:obj.dat];
	int previous_size = [[datInfoDict objectForKey:@"PreviousRes"] intValue];
	obj.newResNumber = previous_size + 1;
	[datObj release];
	
	// make cache directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:obj.boardPath];
	if(	![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	
	// read cache
	NSString *cachepath =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, obj.boardPath, obj.dat];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:cachepath] ) {
		DNSLog( @"[ThreadDat] make a new cache file" );
		obj.resList = [[NSMutableArray alloc] init]; //[[NSMutableArray array] retain];
	}
	else {
		DNSLog( @"[ThreadDat] load existing cache file" );
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:cachepath];
		obj.resList = [NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]];
		[obj.resList retain];
	}
	return obj;
}

+ (ThreadDat*) ThreadDatFromEvacuation {
	ThreadDat *obj = [[ThreadDat alloc] init];
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/thread.evacuated", documentsDirectory];
	
	DatInfo*datObj = [DatInfo DatInfoWithBoardPath:obj.boardPath];
	NSMutableDictionary *datInfoDict = [datObj dictOfDat:obj.dat];
	int previous_size = [[datInfoDict objectForKey:@"PreviousRes"] intValue];
	obj.newResNumber = previous_size + 1;
	[datObj release];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:filepath] ) {
		// make dictionary data to write
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filepath];
		obj.resList = [[NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]] retain];
		
		NSDictionary *otherData = [dict objectForKey:@"NSDictionary"];
		
		obj.boardPath = [[otherData objectForKey:@"Path"] retain];
		obj.dat = [[otherData objectForKey:@"Dat"] retain];
		
		DNSLog( @"res-%d",[obj.resList count] );
		DNSLog( @"path-%@", obj.boardPath );
		DNSLog( @"dat-%@", obj.dat );
		
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
	}
	else {
		[obj release];
		return nil;
	}
	return obj;
}

#pragma mark Original method

- (BOOL) evacuate {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/thread.evacuated", documentsDirectory];
	
	// make dictionary data to write
	NSDictionary *otherData = [NSDictionary dictionaryWithObjectsAndKeys:boardPath_, @"Path", dat_, @"Dat", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:resList_, @"NSMutableArray", otherData, @"NSDictionary", nil];
	BOOL result = [dict writeToFile:filepath atomically:NO];
	
	if( result ) {
		DNSLog( @"[ThreadDat] thread.evacuated - write OK - %@", filepath );
	}
	else {
		DNSLog( @"[ThreadDat] thread.evacuated - write failed - %@", filepath );
	}
	return result;
}

- (NSString*) resDescription {
	return [NSString stringWithFormat:@"%@ %d",NSLocalizedString( @"Res", nil ), [resList_ count]];
}

- (BOOL) write {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, boardPath_, dat_];
	
	NSString *directorypath = [documentsDirectory stringByAppendingPathComponent:boardPath_];
	if(	![[NSFileManager defaultManager] fileExistsAtPath:directorypath] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:directorypath attributes:nil];
	}
	
	// make dictionary data to
	
	if( [resList_ count] > 0 ) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:resList_, @"NSMutableArray", nil];
		return [dict writeToFile:path atomically:NO];
	}
	else {
		return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
}

- (int) updateNewComming:(int)previous_res {
	DatInfo*obj = [DatInfo DatInfoWithBoardPath:boardPath_];
	NSMutableDictionary *datInfoDict = [obj dictOfDat:dat_];	
	if(  previous_res != [resList_ count] ) {
		[self updateSubjectTxtResNumber];
		[self updateBookmarkResNumber];
		NSNumber *previous_resObjC = [[NSNumber alloc] initWithInt:previous_res];
		[datInfoDict setObject:previous_resObjC forKey:@"PreviousRes"];
		[previous_resObjC release];
		[UIAppDelegate.bookmark updateResOfBookmarkOfBoardPath:boardPath_ dat:dat_ res:[resList_ count]];
	}
	int result = [[datInfoDict objectForKey:@"PreviousRes"] intValue] + 1;
	[obj release];
	return result;
}

- (BOOL) updateBookmarkResNumber {
	for( NSMutableDictionary *dict in UIAppDelegate.bookmark.list  ) {
		if( [[dict objectForKey:@"boardPath"] isEqualToString:boardPath_] && [[dict objectForKey:@"dat"] isEqualToString:dat_] ) {
			NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
			[dict setObject:res forKey:@"res"];
			[res release];
			return YES;
		}
	}
	return NO;
}

- (BOOL) updateSubjectTxtResNumber {
	NSMutableArray *subjectList = nil;
	SubjectTxt *subjectTxt = nil;
	
	// check the target path is as same as the pass of the current opend subject.txt
	subjectTxt = [SubjectTxt RestoreFromEvacuation];
	if( subjectTxt != nil ) {
		subjectList = subjectTxt.subjectList;
		for( NSMutableDictionary *dict in subjectList  ) {
			if( [[dict objectForKey:@"dat"] isEqualToString:dat_] ) {
				NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
				[dict setObject:res forKey:@"res"];
				[res release];
				DNSLog( @"Use evacuate" );
				break;
			}
		}
		[subjectTxt evacuate:subjectTxt.keyword];
		[subjectTxt release];
	}
	else if( [UIAppDelegate.subjectTxt.path isEqualToString:boardPath_] ) {		
		subjectList = UIAppDelegate.subjectTxt.subjectList;
		subjectList = subjectTxt.subjectList;
		for( NSMutableDictionary *dict in subjectList  ) {
			if( [[dict objectForKey:@"dat"] isEqualToString:dat_] ) {
				NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
				[dict setObject:res forKey:@"res"];
				[res release];
				DNSLog( @"Already open shared subjecttxt" );
				break;
			}
		}
	}
	else {
		subjectTxt = [SubjectTxt SubjectTxtFromCacheWithBoardPath:boardPath_];
		subjectList = subjectTxt.subjectList;
		for( NSMutableDictionary *dict in subjectList  ) {
			if( [[dict objectForKey:@"dat"] isEqualToString:dat_] ) {
				NSNumber* res = [[NSNumber alloc] initWithInt:[UIAppDelegate.threadDat.resList count]];
				[dict setObject:res forKey:@"res"];
				[res release];
				DNSLog( @"SubjectTxtFromCacheWithBoardPath" );
				break;
			}
		}
		[subjectTxt release];
		DNSLog( @"2" );
	}
	
	return NO;
}

- (BOOL) append:(NSData*) data {
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];	
	int	new_res = 0;
	int previous_res = [resList_ count];
	
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
				[resList_ addObject:dict];
				new_res++;
			}
			head = i + 1;
		}
	}
	[self write];
	
	newResNumber_ = [self updateNewComming:previous_res];
	
	if( new_res > 0 )
		return YES;
	else
		return NO;
}

- (void) clearOldData {
	[resList_ removeAllObjects];
}

#pragma mark Override

- (void) dealloc {
	[self write];
	[dat_ release];
	[boardPath_ release];
	[resList_ release];
	[super dealloc];
}


@end
