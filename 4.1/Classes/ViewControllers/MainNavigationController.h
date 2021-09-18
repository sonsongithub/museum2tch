//
//  MainNavigationController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 sonson. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "UINavigationController+SNToolbarController.h"

@class SNToolbarController;

@interface MainNavigationController : UINavigationController {
	UIToolbar		*toolbar_;
}
@property (nonatomic, retain) UIToolbar *toolbar;
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
@end
