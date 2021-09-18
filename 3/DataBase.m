//
//  DataBase.m
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"
#import "global.h"

@implementation DataBase

@synthesize categoryList = categoryList_;
@synthesize boardList = boardList_;
@synthesize subjectList = subjectList_;
@synthesize dat = dat_;
@synthesize resList = resList_;

- (id) init {
	self = [super init];
	
	if( self != nil ) {
		BBSMenuDataBase *bbsmenu = [[BBSMenuDataBase alloc] init];
		categoryList_ = bbsmenu.categoryList;
		[categoryList_ retain];
		[bbsmenu release];
		
		subjectList_= [[NSMutableArray array] retain];
	}
	
	return self;
}

- (void) dealloc {
	[categoryList_ release];
	[subjectList_ release];
	[super dealloc];
}

#pragma mark BBSMenu - category and board

- (void) parseBBSMenu:(NSData*)data {
	BBSMenuDataBase *bbsmenu = [[BBSMenuDataBase alloc] init];
	[bbsmenu parseBBSMenuHTML:data];
	
	[categoryList_ release];
	categoryList_ = bbsmenu.categoryList;
	[categoryList_ retain];
	[bbsmenu release];
}

- (void) setCurrentCategory:(int)category_id {
	self.boardList = [[categoryList_ objectAtIndex:category_id] objectForKey:@"boardList"];
}

#pragma mark access bbsmenu data

- (NSString*) serverOfBoardPath:(NSString*)boardPath {
	for( NSDictionary* dict in self.boardList ) {
		if(	[[dict objectForKey:@"path"] isEqualToString:boardPath] ) {
			return [dict objectForKey:@"server"];
		}
	}
	return nil;
}

#pragma mark subject.txt

- (BOOL) loadSubjectTxtCache:(NSString*)boardPath {
	SubjectDataBase* obj = [[SubjectDataBase alloc] initWithBoardPath:boardPath];
	[subjectList_ removeAllObjects];
	BOOL result = [obj loadCache:subjectList_];
	[obj release];
	return result;
}

- (BOOL) parseSubjectTxt:(NSData*)data ofBoardPath:(NSString*)path delegate:(id)delegate{	
	SubjectDataBase* obj = [[SubjectDataBase alloc] initWithBoardPath:path];
	[subjectList_ removeAllObjects];
	[obj parse:data array:subjectList_ delegate:delegate];
	[obj release];
	return NO;
}

- (BOOL) deleteSubjectTxtOfBoardPath:(NSString*)path delegate:(id)delegate{	
	SubjectDataBase* obj = [[SubjectDataBase alloc] initWithBoardPath:path];
	[obj deleteCache];
	[obj release];
	return NO;
}

#pragma mark dat

- (void) setContentLength:(NSString*)contentLength lastModified:(NSString*)lastModified ofDat:(NSString*)dat atBoardPath:(NSString*)boardPath {
	
	DatInfoDataBase* obj = [[DatInfoDataBase alloc] initWithBoardPath:boardPath];
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:contentLength, @"Content-Length", lastModified, @"Last-Modified", nil];
	
	DNSLog( @"%@ - %@ - %@", dat, contentLength, lastModified );
	
	[obj.infoList setObject:dict forKey:dat];
	[obj release];	
}

- (NSMutableDictionary*) contentLengthAndLastModifiedDictOfDat:(NSString*)dat atBoardPath:(NSString*)boardPath {
	DNSLog( @"[DataBase] contentLengthAndLastModifiedDictOfDat:atBoardPath" );
	
	DatInfoDataBase* obj = [[DatInfoDataBase alloc] initWithBoardPath:boardPath];
	NSArray *keys = [obj.infoList allKeys];
	for( NSString* key in keys ) {
#ifdef _DEBUG
		NSDictionary *dict = [obj.infoList objectForKey:key];
#endif
		DNSLog( @"Dat:%@ -> %@,%@", key, [dict objectForKey:@"Content-Length"], [dict objectForKey:@"Last-Modified"] );
	}
	NSMutableDictionary*dict;
	
	if( [obj.infoList objectForKey:dat] == nil ) {
		dict = nil;
	}
	else {
		dict = [NSMutableDictionary dictionaryWithDictionary:[obj.infoList objectForKey:dat]];
	}
	[obj release];
	return dict;
}

- (BOOL) loadCurrentDat:(NSString*)boardPath dat:(NSString*)dat {
	DNSLog( @"[DataBase] setCurrentDat:dat" );
	DNSLog( dat );
	
	ThreadDataBase *obj = [[ThreadDataBase alloc] initWithBoardPath:boardPath dat:dat];
	[resList_ release];
	resList_ = [obj.resList retain];
	[obj release];
	return YES;
}

- (BOOL) readRes:(NSString*)boardPath dat:(NSString*)dat data:(NSData*)data {
	DNSLog( @"[DataBase] readRes:dat:data" );
	
	ThreadDataBase *obj = [[ThreadDataBase alloc] initWithBoardPath:boardPath dat:dat];
	BOOL result = [obj append:data];
	[resList_ release];
	resList_ = [obj.resList retain];
	[obj release];
	return result;
}


@end
