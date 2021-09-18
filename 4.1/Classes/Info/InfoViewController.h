//
//  InfoViewController.h
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
	UITableView				*tableView_;
	NSMutableDictionary		*cells_;
	volatile BOOL			isFinishedCheckSize_;
	volatile BOOL			isTryingToStopCheckSize_;
	UIActionSheet			*deleteCacheSheet_;
	UIActionSheet			*deleteCookieSheet_;
}
@property (nonatomic, retain) UITableView *tableView;
#pragma mark For get application bundle infomation
- (id)infoValueForKey:(NSString*)key;
#pragma mark Original method
- (void)pushCloseButton:(id)sender;
- (void) makeCells;
#pragma mark For user action, such as getting cache size, deleting cache
- (BOOL) stopBackgroundCheckSize;
- (void) checkSize;
- (void) deleteCookies;
- (void) delaeteAllCacheFilesAndQuit;
@end
