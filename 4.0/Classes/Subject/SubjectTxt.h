//
//  SubjectTxt.h
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SubjectData;

@interface SubjectTxt : NSObject {
	// original sources
	NSMutableArray	*source_;
	NSMutableArray	*cache_;
	NSMutableArray	*newComming_;
	
	// sources limited by keywords
	NSMutableArray	*sourceLimited_;
	NSMutableArray	*cacheLimited_;
	NSMutableArray	*newCommingLimited_;
	
	NSString		*path_;
}

@property (nonatomic, retain) NSMutableArray* source;
@property (nonatomic, retain) NSMutableArray* cache;
@property (nonatomic, retain) NSMutableArray* newComming;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, retain) NSMutableArray* sourceLimited;
@property (nonatomic, retain) NSMutableArray* cacheLimited;
@property (nonatomic, retain) NSMutableArray* newCommingLimited;
#pragma mark Class Method
+ (NSString*)boardTitleWithPath:(NSString*)path;
+ (void)makeDirectoryOfPath:(NSString*)path;
#pragma mark Original Method
- (SubjectData*) searchDataWithDat:(int)dat;
- (void)limitWithKeyword:(NSString*)keyword;
- (BOOL)hasData;
- (id)initWithPath:(NSString*)path;
- (void)makeCacheAndNewCommingData;
- (void)load;
- (void)write;
@end
