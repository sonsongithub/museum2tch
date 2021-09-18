//
//  Bookmark.h
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Bookmark : NSObject {
	NSMutableArray		*list_;
}

@property (nonatomic, assign) NSMutableArray *list;

#pragma mark Class Method
+ (Bookmark*) defaultBookmark;
#pragma mark Original Method
- (BOOL) updateTitleOfBookmarkOfBoardPath:(NSString*)boardPath dat:(NSString*)dat title:(NSString*)title;
- (BOOL) updateResOfBookmarkOfBoardPath:(NSString*)boardPath dat:(NSString*)dat res:(int)res;
- (BOOL) addWithDictinary:(NSMutableDictionary*)dict;
- (BOOL) write;

@end
