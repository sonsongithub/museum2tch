//
//  BookmarkNavigationController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNToolbarController;

@interface BookmarkNavigationController : UINavigationController {
	UIToolbar		*toolbar_;
}
@property (nonatomic, retain) UIToolbar *toolbar;
+ (BookmarkNavigationController*) defaultController;
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
- (id)initWithRootViewController:(UIViewController*)viewController;
@end
