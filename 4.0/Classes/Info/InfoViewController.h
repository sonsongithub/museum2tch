//
//  InfoViewController.h
//  2tch
//
//  Created by sonson on 08/08/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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
@property (nonatomic, assign) UITableView *tableView;

#pragma mark Class method
+ (InfoViewController*) defaultController;
- (void)makeCells;
@end
