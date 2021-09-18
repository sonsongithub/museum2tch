//
//  CategoryViewController.h
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Downloader.h"

@interface CategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DownloaderDelegate> {
	UITableView*	tableView_;
}
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushInfoView:(id)sender;
#pragma mark Setting UIBarButtonItem
- (void) toggleReloadButton;
- (void) toggleStopButton;
- (void) toggleInfoViewButton;
@end
