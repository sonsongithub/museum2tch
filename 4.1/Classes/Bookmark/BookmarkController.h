//
//  BookmarkController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarkController : NSObject {
	NSMutableArray		*list_;
}
@property (nonatomic, retain) NSMutableArray *list;
+ (BookmarkController*)defaultBookmark;
- (void)clear;
- (void)addBookmarkOfThreadWithPath:(NSString*)path dat:(int)dat title:(NSString*)title;
- (void)addBookmarkOfBoardWithPath:(NSString*)path title:(NSString*)title;
- (void)loadWithEncoder;
- (void)writeWithEncoder;
@end
