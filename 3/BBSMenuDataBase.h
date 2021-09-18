//
//  BBSMenuDataBase.h
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNHUDActivityView.h"

@interface BBSMenuDataBase : NSObject {
	SNHUDActivityView	*hud_;
	NSMutableArray		*categoryList_;
}
@property (nonatomic, assign) NSMutableArray *categoryList;
#pragma mark Override
- (id) init;
- (void) dealloc;
- (BOOL) readCategoryList;
- (BOOL) writeCategoryList;
#pragma mark Original method
- (void) openActivityHUD:(id)obj;
- (void) parseBBSMenuHTML:(id)data;
#pragma mark For extract or arrange string
- (NSString*) arrangeURL:(NSString*)input;
- (NSString*) extractBoardID:(NSString*)input;
- (NSString*) extract2chServerName:(NSString*)input;
#pragma mark For bbsmenu parsing
- (void) parseCategory:(NSString*)string_category categoryList:(NSMutableArray*)categoryList;
- (void) parseBoards:(NSString*)string_boards categoryList:(NSMutableArray*)categoryList;
@end
