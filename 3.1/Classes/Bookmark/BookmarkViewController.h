//
//  BookmarkViewController.h
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView*	tableView_;
}
@property (nonatomic, assign) UITableView	*tableView;

#pragma mark Class Method
+ (BookmarkViewController*) defaultController;

#pragma mark Original Method to Correspond Button Events
- (void) pushEdit:(id)sender;
- (void) pushDone:(id)sender;

@end
