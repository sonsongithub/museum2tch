//
//  SNTableViewController.h
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView*	tableView_;
}
@property (nonatomic, readonly) UITableView *tableView;
- (void)deselectRow:(BOOL)animated;
- (id)initWithStyle:(UITableViewStyle)style;
@end
