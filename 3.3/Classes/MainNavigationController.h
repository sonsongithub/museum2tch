//
//  MainNavigationController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@class SNToolbarController;

@interface MainNavigationController : UINavigationController {
	UIToolbar		*toolbar_;
}
@property (nonatomic, assign) UIToolbar *toolbar;
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
@end
