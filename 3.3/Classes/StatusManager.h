//
//  StatusManager.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StatusManager : NSObject {
	int			categoryID_;
	
	NSString	*categoryTitle_;
	NSString	*boardTitle_;
	NSString	*path_;
	NSString	*threadTitle_;
	int			dat_;
}
@property (nonatomic, assign) int categoryID;

@property (nonatomic, retain) NSString* categoryTitle;
@property (nonatomic, retain) NSString* boardTitle;

@property (nonatomic, assign) NSString* path;
@property (nonatomic, retain) NSString* threadTitle;
@property (nonatomic, assign) int dat;

- (void)popCategoryInfo;
- (void)popBoardInfo;
- (void)popThreadInfo;
@end
