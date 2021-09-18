//
//  BookmarkViewToolbarController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface BookmarkViewToolbarController : SNToolbarController {
	UISegmentedControl		*segmentControll_;
	UIBarButtonItem			*segmentControllButton_;
}
@property (nonatomic, assign) UISegmentedControl *segmentControll;
#pragma mark Original Method
- (id)initWithDelegate:(id)delegate;
- (void)updateUnreadRemained:(int)remained;
- (void)toggleToEditButton;
- (void)toggleToEditDoneButton;
@end
