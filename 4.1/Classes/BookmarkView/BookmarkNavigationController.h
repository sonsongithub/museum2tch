//
//  BookmarkNavigationController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UINavigationController+SNToolbarController.h"

@class SNToolbarController;

@interface BookmarkNavigationController : UINavigationController {
	UIToolbar		*toolbar_;
}
@property (nonatomic, retain) UIToolbar *toolbar;
#pragma mark Class method
+ (BookmarkNavigationController*) defaultController;
- (void)pushSearchViewController;
#pragma mark Control ToolbarController
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
@end
