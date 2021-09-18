//
//  BBSMenu.m
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBSMenu.h"
#import "_tchAppDelegate.h"
#import "global.h"

#pragma mark For extract or arrange string

NSString* arrangeURL( NSString* input );
NSString* extractBoardID( NSString* input );
NSString* extract2chServerName( NSString* input );
void parseCategory( NSString *string_category, NSMutableArray *categoryList );
void parseBoards( NSString* string_boards, NSMutableArray* categoryList );

NSString* arrangeURL( NSString* input ) {
	NSRange range = [input rangeOfString:@" TARGET=_blank"];
	
	if( range.location != NSNotFound )
		return [input substringWithRange:NSMakeRange( 0, range.location )];
	else
		return input;
	//http://kanto.machi.to/kanto/ TARGET=_blank
}

NSString* extractBoardID( NSString* input ) {
	NSArray *components = [input componentsSeparatedByString:@"/"];
	if( [components count] == 5 ) {
		return [components objectAtIndex:3];
	}
	return nil;
}

NSString* extract2chServerName( NSString* input ) {
	NSArray *components = [input componentsSeparatedByString:@"/"];
	if( [components count] == 5 ) {
#ifdef _ONLY_2CH
		NSRange range = [[components objectAtIndex:2] rangeOfString:@".2ch.net"];
		if( range.location == NSNotFound )
			return nil;
		else
			return [components objectAtIndex:2];
#else
		return [components objectAtIndex:2];
#endif
	}
	return nil;
}

#ifdef _DEBUG

void parseCategory( NSString *string_category, NSMutableArray *categoryList ) {
	NSArray *components = [string_category componentsSeparatedByString:@"</B>】"];
	if( [components count] == 2 ) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[components objectAtIndex:0] forKey:@"title"];
		[dict setObject:[NSMutableArray array] forKey:@"boardList"];
		[categoryList addObject:dict];
		parseBoards( [components objectAtIndex:1], categoryList );
	}
}

#else

void parseCategory( NSString *string_category, NSMutableArray *categoryList ) {
	NSArray *components = [string_category componentsSeparatedByString:@"</B>】"];
	if( [components count] == 2 && ![[components objectAtIndex:0] isEqualToString:@"PINKちゃんねる"] ) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[components objectAtIndex:0] forKey:@"title"];
		[dict setObject:[NSMutableArray array] forKey:@"boardList"];
		[categoryList addObject:dict];
		parseBoards( [components objectAtIndex:1], categoryList );
	}
}

#endif

void parseBoards( NSString* string_boards, NSMutableArray* categoryList ) {
	NSArray *lines = [string_boards componentsSeparatedByString:@"</A>\n"];
	for (NSString* line in lines) {
		NSArray* components = [line componentsSeparatedByString:@"A HREF="];
		if( [components count] > 1 ) {
			NSString* url_title = [components objectAtIndex:1];
			NSArray* components2 = [url_title componentsSeparatedByString:@">"];
			if( [components2 count] == 2 ) {		
				NSString *server = extract2chServerName([components2 objectAtIndex:0]);
				NSString *path = extractBoardID([components2 objectAtIndex:0]);
				NSString *url = arrangeURL([components2 objectAtIndex:0]);
				NSString *name =  [components2 objectAtIndex:1];
				
				NSMutableDictionary *currentCategory = [categoryList lastObject];
				NSMutableArray* boardList = [currentCategory objectForKey:@"boardList"];
				NSMutableDictionary *boardInfo = [NSMutableDictionary dictionary];
				
				if( server && path && url && name ) {
					[boardInfo setObject:server forKey:@"server"];
					[boardInfo setObject:path forKey:@"path"];
					[boardInfo setObject:url forKey:@"url"];
					[boardInfo setObject:name forKey:@"title"];
					[boardList addObject:boardInfo];
				}
			}
		}
	}
}

@implementation BBSMenu

@synthesize categoryList = categoryList_;
@synthesize updateDate = updateDate_;

#pragma mark Class Method

+ (BBSMenu*) BBSMenuWithData:(id)data {
	DNSLog( @"[BBSMenu] BBSMenuWithData:" );
	BBSMenu* obj = [[BBSMenu alloc] init];

	obj.categoryList = [[NSMutableArray alloc] init];	//[[NSMutableArray array] retain];
	
	NSString *string = decodeNSData( data );
	NSArray *categories = [string componentsSeparatedByString:@"【<B>"];	
	obj.updateDate = [[NSDate date] retain];
	
	
	[UIAppDelegate.toolbarController updateMessageSpace:[obj updateDateString]];
	
	for (NSString* object in categories) {
		parseCategory( object, obj.categoryList );
	}
	[obj write];
	return obj;
}

+ (BBSMenu*) BBSMenuWithDataFromCache {
	DNSLog( @"[BBSMenu] BBSMenuWithDataFromCache" );
	BBSMenu* obj = [[BBSMenu alloc] init];
	
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"categoryList.cache"];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		return obj;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	obj.categoryList = [[NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]] retain];
	obj.updateDate = [[dict objectForKey:@"NSDate"] retain];
	
	DNSLog( @"%@", obj.updateDate );
	
	if( obj.categoryList )
		return obj;
	
	return obj;
}

#pragma mark Original

- (NSString*) serverOfBoardPath:(NSString*)boardPath {
	for( NSDictionary* categoryDict in categoryList_ ) {
		for( NSDictionary* boardDict in [categoryDict objectForKey:@"boardList"] ) {
			if(	[[boardDict objectForKey:@"path"] isEqualToString:boardPath] ) {
				return [boardDict objectForKey:@"server"];
			}
		}
	}
	return nil;
}

- (NSString*) serverOfBoardTitle:(NSString*)boardPath {
	for( NSDictionary* categoryDict in categoryList_ ) {
		for( NSDictionary* boardDict in [categoryDict objectForKey:@"boardList"] ) {
			if(	[[boardDict objectForKey:@"path"] isEqualToString:boardPath] ) {
				return [boardDict objectForKey:@"title"];
			}
		}
	}
	return nil;
}

- (BOOL) getCategoryIndex:(int*)categoryIndex andBoardIndex:(int*)boardIndex ofBoardPath:(NSString*)boardPath {
	int i,j;
	for( i = 0; i < [categoryList_ count]; i++ ) {
		NSDictionary* categoryDict = [categoryList_ objectAtIndex:i];
		NSMutableArray* boardList = [categoryDict objectForKey:@"boardList"];
		
		for( j = 0; j < [boardList count]; j++ ) {
			NSDictionary* boardDict = [boardList objectAtIndex:j];
			if(	[[boardDict objectForKey:@"path"] isEqualToString:boardPath] ) {
				*categoryIndex = i;
				*boardIndex = j;
				return YES;
			}
		}
	}
	return NO;
}

- (NSString*) updateDateString {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString* update_string = [dateFormatter stringFromDate:updateDate_];
	if( update_string != nil )
		return [NSString stringWithFormat:@"%@ %@", NSLocalizedString( @"UpdateDate", nil ), update_string];
	else
		return NSLocalizedString( @"PleaseLoadBBSMenu", nil );
}

- (BOOL) write {
	DNSLog( @"[BBSMenu] write" );
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"categoryList.cache"];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:categoryList_, @"NSMutableArray", updateDate_, @"NSDate", nil];
	return [dict writeToFile:path atomically:NO];
}

#pragma mark Override

- (void) dealloc {
	DNSLog( @"[BBSMenu] dealloc" );
	[categoryList_ release];
	[updateDate_ release];
	[super dealloc];
}

@end
