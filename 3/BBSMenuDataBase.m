//
//  BBSMenuDataBase.m
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBSMenuDataBase.h"
#import "_tchAppDelegate.h"
#import "global.h"

@implementation BBSMenuDataBase

@synthesize categoryList = categoryList_;

#pragma mark Override

- (id) init {
	self = [super init];
	if (self != nil) {
		hud_ = [[SNHUDActivityView alloc] init];
		if( ![self readCategoryList] ) {
			NSURLResponse *response = nil;
			NSError *error = nil;	
			NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://menu.2ch.net/bbstable.html"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
			NSData *data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
			[self parseBBSMenuHTML:data];
		}
	}
	return self;
}

- (void) dealloc {
	[categoryList_ release];
	[hud_ release];
	[super dealloc];
}

- (BOOL) readCategoryList {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"categoryList.cache"];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		return NO;
	}
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[categoryList_ release];
	categoryList_ = [NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]];
	[categoryList_ retain];
	return YES;
}

- (BOOL) writeCategoryList {
	// make path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"categoryList.cache"];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:categoryList_, @"NSMutableArray", nil];
	return [dict writeToFile:path atomically:NO];
}

#pragma mark Original method

- (void) openActivityHUD:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		[hud_ setupWithMessage:NSLocalizedString( @"BBSMenuHUDMessage", nil )];
		[hud_ arrange:app.mainNavigationController.visibleViewController.view.frame];
		[app.mainNavigationController.visibleViewController.view addSubview:hud_];
	}
	[pool release];
	[NSThread exit];
}

- (void) parseBBSMenuHTML:(id)data {
	[NSThread detachNewThreadSelector:@selector(openActivityHUD:) toTarget:self withObject:nil];

	NSString *string = decodeNSData( data );
	NSArray *categories = [string componentsSeparatedByString:@"【<B>"];	
	
	[categoryList_ release];
	categoryList_ = [NSMutableArray array];
	[categoryList_ retain];
	
	for (NSString* object in categories) {
		[self parseCategory:object categoryList:self.categoryList];
	}
	[self writeCategoryList];
	[NSThread detachNewThreadSelector:@selector(addCheck) toTarget:hud_ withObject:nil];
	[NSThread sleepForTimeInterval:0.5];
	[hud_ dismiss];
}

#pragma mark For extract or arrange string

- (NSString*) arrangeURL:(NSString*)input {
	NSRange range = [input rangeOfString:@" TARGET=_blank"];
	
	if( range.location != NSNotFound )
		return [input substringWithRange:NSMakeRange( 0, range.location )];
	else
		return input;
	//http://kanto.machi.to/kanto/ TARGET=_blank
}

- (NSString*) extractBoardID:(NSString*)input {
	NSArray *components = [input componentsSeparatedByString:@"/"];
	if( [components count] == 5 ) {
		return [components objectAtIndex:3];
	}
	return nil;
}

- (NSString*) extract2chServerName:(NSString*)input {
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

#pragma mark For bbsmenu parsing

#ifdef _DEBUG

- (void) parseCategory:(NSString*)string_category categoryList:(NSMutableArray*)categoryList {
	NSArray *components = [string_category componentsSeparatedByString:@"</B>】"];
	if( [components count] == 2 ) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[components objectAtIndex:0] forKey:@"title"];
		[dict setObject:[NSMutableArray array] forKey:@"boardList"];
		[categoryList addObject:dict];
		[self parseBoards:[components objectAtIndex:1] categoryList:categoryList];
	}
}

#else

- (void) parseCategory:(NSString*)string_category categoryList:(NSMutableArray*)categoryList {
	NSArray *components = [string_category componentsSeparatedByString:@"</B>】"];
	if( [components count] == 2 && ![[components objectAtIndex:0] isEqualToString:@"PINKちゃんねる"] ) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[components objectAtIndex:0] forKey:@"title"];
		[dict setObject:[NSMutableArray array] forKey:@"boardList"];
		[categoryList addObject:dict];
		[self parseBoards:[components objectAtIndex:1] categoryList:categoryList];
	}
}

#endif

- (void) parseBoards:(NSString*)string_boards categoryList:(NSMutableArray*)categoryList {
	NSArray *lines = [string_boards componentsSeparatedByString:@"</A>\n"];
	for (NSString* line in lines) {
		NSArray* components = [line componentsSeparatedByString:@"A HREF="];
		if( [components count] > 1 ) {
			NSString* url_title = [components objectAtIndex:1];
			NSArray* components2 = [url_title componentsSeparatedByString:@">"];
			if( [components2 count] == 2 ) {		
				NSString *server = [self extract2chServerName:[components2 objectAtIndex:0]];
				NSString *path = [self extractBoardID:[components2 objectAtIndex:0]];
				NSString *url = [self arrangeURL:[components2 objectAtIndex:0]];
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

@end
