//
//  BoardViewController.h
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Downloader.h"

@interface BoardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DownloaderDelegate> {
	UITableView		*tableView_;
	NSMutableArray	*boardList_;
}
#pragma mark Button Event
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;

#pragma mark Setting UIBarButtonItem
- (void) toggleReloadButton;
- (void) toggleStopButton;
- (void) toggleInfoViewButton;
@end
