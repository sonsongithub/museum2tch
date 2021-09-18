//
//  BookmarkNaviController.h
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* kNotificationSuccessOpenThreadFromBookmark;
extern NSString* kNotificationFailedOpenThreadFromBookmark;

@interface BookmarkNaviController : UINavigationController {
	UIToolbar*			toolbar_;
	id					delegate_;
	BOOL				isNeedUpdate_;
}
@property (nonatomic, assign) UIToolbar		*toolbar;
@property (nonatomic, assign) id			delegate;
@property (nonatomic, assign) BOOL	isNeedUpdate;

#pragma mark Class Method
+ (BookmarkNaviController*) defaultController;

#pragma mark Original Method to Controll Toolbar
- (void) toolbarOfBookmarkViewWithDelegate:(id)delegate editingFlag:(BOOL)flag;
- (void) toolbarOfHistoryViewWithDelegate:(id)delegate;
//- (void) toolbarOfHistoryViewWithDelegate:(id)delegate segmentControl:(UISegmentedControl*)segmentControl;

#pragma mark Original Method
- (void) open:(NSDictionary*)dict;
- (void)close;
- (void)success;
- (void)failed;

@end
