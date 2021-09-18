//
//  HistoryViewController.h
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface HistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	UITableView			*tableView_;
	NSMutableArray		*cellList_;
}
@property (nonatomic, assign) UITableView	*tableView;

#pragma mark Class Method
+ (HistoryViewController*) defaultController;
#pragma mark Original Method
- (void) pushEdit:(id)sender;

@end
