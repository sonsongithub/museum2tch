//
//  TitleViewToolbarController.h
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface TitleViewToolbarController : SNToolbarController {
	UISegmentedControl	*segmentControll_;
}
@property (nonatomic, assign) UISegmentedControl *segmentControll;
- (void)setSearchButton;
- (void)setCloseSearchButton;
@end
