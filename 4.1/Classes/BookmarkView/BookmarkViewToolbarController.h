//
//  BookmarkViewToolbarController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface BookmarkViewToolbarController : SNToolbarController {
	UISegmentedControl		*segmentControl_;
	UIBarButtonItem			*segmentControlBarButtonItem_;
}
@property (nonatomic, retain) UIBarButtonItem *segmentControlBarButtonItem;
@property (nonatomic, assign, readonly) UISegmentedControl *segmentControl;
#pragma mark Initialize toolbar
- (void)initializeToolbar;
#pragma mark Toggle toolbar
- (void)setupToolbarWhileNotEditing;
- (void)setupToolbarWhileEditing;
#pragma mark Control hidden/shown  buttons on under UIToolbar
- (void)updateUnreadRemained:(int)remained;
- (void)toggleToEditButton;
- (void)toggleToEditDoneButton;
@end
