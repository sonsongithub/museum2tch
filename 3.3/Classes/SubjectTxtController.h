//
//  SubjectTxtController.h
//  2tch
//
//  Created by sonson on 08/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SubjectTxtController : NSObject {
	NSMutableArray	*source_;
	NSMutableArray	*cache_;
	NSMutableArray	*newComming_;
	NSString		*path_;
	
	NSMutableArray	*sourceLimited_;
	NSMutableArray	*cacheLimited_;
	NSMutableArray	*newCommingLimited_;
}
@property (nonatomic, assign) NSMutableArray* source;
@property (nonatomic, assign) NSMutableArray* cache;
@property (nonatomic, assign) NSMutableArray* newComming;
@property (nonatomic, assign) NSString* path;
@property (nonatomic, assign) NSMutableArray* sourceLimited;
@property (nonatomic, assign) NSMutableArray* cacheLimited;
@property (nonatomic, assign) NSMutableArray* newCommingLimited;
@end
