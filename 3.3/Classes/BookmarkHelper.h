//
//  BookmarkHelper.h
//  2tch
//
//  Created by sonson on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarkHelper : NSObject {
}
+ (void)insertThreadIntoBookmarkOfDat:(int)dat path:(NSString*)path;
+ (int)threadInfoOfDat:(int)dat path:(NSString*)path;
+ (BOOL)isInsertedThreadToBookmark:(int)bookmark_key;
+ (void)insertBoardIntoBookmarkOfPath:(NSString*)path;
+ (int)boardOfPath:(NSString*)path;
+ (BOOL)isInsertedBoardToBookmark:(int)bookmark_key;
@end
