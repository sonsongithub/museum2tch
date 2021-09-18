//
//  SearchViewToolbarController.h
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface SearchViewToolbarController : SNToolbarController {
	UIActivityIndicatorView *activityView_;
}
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
- (void)showActivityView;
- (void)hideActivityView;
@end
