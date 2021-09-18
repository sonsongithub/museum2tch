//
//  BookmarkViewController.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

@class Crawler;
@class BookmarkViewToolbarController;
@class SNMiniBadgeView;

@interface BookmarkViewController : SNTableViewController {
	BookmarkViewToolbarController	*toolbarController_;
	NSMutableArray					*unreadCell_;
	NSMutableArray					*currentCell_;
	Crawler							*cralwer_;
	SNMiniBadgeView					*badge_;
}
#pragma mark Original Method
- (void)fetchAllBookmarkData;
- (void)refreshCells;
#pragma mark Controll UINavigationBar Button
- (void)switchToEditingMode;
- (void)switchToNormalMode;
#pragma mark UIButton Push Event
- (void)pushNewFolderButton:(id)sender;
- (void)pushCrawlButton:(id)sender;
- (void)pushDoneButton:(id)sender;
- (void)pushEditButton:(id)sender;
- (void)pushEditDoneButton:(id)sender;
#pragma mark Original UISegment Callback
- (void)segmentChanged:(id)sender;
@end
