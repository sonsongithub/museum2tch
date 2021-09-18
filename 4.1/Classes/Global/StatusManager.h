//
//  StatusManager.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 sonson. All rights reserved.
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

@property (nonatomic, retain) NSString* path;
@property (nonatomic, retain) NSString* threadTitle;
@property (nonatomic, assign) int dat;
#pragma mark accessor, getter, setter
- (void)setPath:(NSString*)newValue;
- (void)setDat:(int)newValue;
#pragma mark for management, pop or push
- (void)popCategoryInfo;
- (void)popBoardInfo;
- (void)popThreadInfo;
#pragma mark Method to save and write
- (void)load;
- (void)write;
@end
