//
//  UINavigationController+SNToolbarController.h
//  2tch
//
//  Created by sonson on 09/02/14.
//  Copyright 2009 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNToolbarController;

@interface UINavigationController(SNToolbarController)
- (void)updateToolbarWithController:(SNToolbarController*)controller animated:(BOOL)animated;
@end
