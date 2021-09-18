//
//  BookmarkViewController.h
//  2tch
//
//  Created by sonson on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

#define FIXED_ROW_NUMBER 1

@class SNToolbarController;
@class BookmarkViewToolbarController;
@class BookmarkNavigationController;
@class BookmarkCellData;

@interface BookmarkViewController : SNTableViewController {
	NSMutableArray					*currentCell_;
	NSMutableArray					*cell_;
	NSMutableArray					*newCell_;
	BookmarkViewToolbarController	*toolbarController_;
	BookmarkNavigationController	*parentNavigationController_;
}
+ (void)deleteBookmarkAt:(BookmarkCellData*)atIndex;
- (void)segmentChanged:(id)sender;
- (void)showCloseButton;
- (void)hideCloseButton;
#pragma mark Button Event
- (void)pushCheckButton:(id)sender;
- (void)pushCloseButton:(id)sender;
- (void)pushEditButton:(id)sender;
- (void)pushEditDoneButton:(id)sender;
#pragma mark Reload Cell Data
- (void) readCellData;
- (void) readCellDataOfThread;
- (void) readCellDataOfBoard;
@end
