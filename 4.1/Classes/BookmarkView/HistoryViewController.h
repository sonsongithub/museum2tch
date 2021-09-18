//
//  HistoryViewController.h
//  2tch
//
//  Created by sonson on 08/12/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTableViewController.h"

@class HistoryViewToolbarController;

@interface HistoryViewController : SNTableViewController <UIActionSheetDelegate> {
	HistoryViewToolbarController	*toolbarController_;
	NSMutableArray					*cellInfo_;
	UIActionSheet					*deleteAllSheet_;
	UIActionSheet					*deleteAnItemSheet_;
	int								cellToDelete_;
}
@property ( nonatomic, retain ) HistoryViewToolbarController *toolbarController;
#pragma mark Class Method
+ (void)checkCurrentThreadViewWithPath:(NSString*)path dat:(int)dat;
+ (void)checkCurrentThread;
+ (void)deleteAllCache;
+ (void)deleteThreadInfoAndCacheWithPath:(NSString*)path dat:(int)dat;
+ (void)deleteThreadDatDataWithPath:(NSString*)path dat:(int)dat;
+ (void)deleteInvalidHistoryData;
#pragma mark UIButton Push Botton
- (void)pushDeleteButton:(id)sender;
- (void)pushDoneButton:(id)sender;
#pragma mark Fetch all history data
- (void)refreshAllCell;
@end
