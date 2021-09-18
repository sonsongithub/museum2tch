//
//  BBSMenu.h
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BBSMenu : NSObject {
	NSMutableArray	*categoryList_;
	NSDate			*updateDate_;
}
@property (nonatomic, assign) NSMutableArray *categoryList;
@property (nonatomic, assign) NSDate *updateDate;

#pragma mark Class Method
+ (BBSMenu*) BBSMenuWithData:(id)data;
+ (BBSMenu*) BBSMenuWithDataFromCache;

#pragma mark Original
- (NSString*) serverOfBoardPath:(NSString*)boardPath;
- (NSString*) serverOfBoardTitle:(NSString*)boardPath;
- (BOOL) getCategoryIndex:(int*)categoryIndex andBoardIndex:(int*)boardIndex ofBoardPath:(NSString*)boardPath;
- (NSString*) updateDateString;
- (BOOL) write;
@end
