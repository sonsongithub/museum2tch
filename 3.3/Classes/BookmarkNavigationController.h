//
//  BookmarkNavigationController.h
//  2tch
//
//  Created by sonson on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNToolbarController;

@interface BookmarkNavigationController : UINavigationController {
	UIToolbar		*toolbar_;
}
@property (nonatomic, assign) UIToolbar *toolbar;
+ (BookmarkNavigationController*) defaultController;
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
@end
