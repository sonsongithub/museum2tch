//
//  AnchorPopupViewController.h
//  2tch
//
//  Created by sonson on 08/12/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupViewController.h"

@class ThreadViewController;

@interface AnchorPopupViewController : PopupViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView				*tableView_;
	
	ThreadViewController	*delegate_;
	int						historyCounter_;
	
	NSMutableArray			*source_;
	NSMutableArray			*cell_;
}
@property (nonatomic, assign) ThreadViewController* delegate;
@property (nonatomic, assign) NSMutableArray* source;
- (void)showInView:(UIView*)view withNumbers:(NSArray*)numbers;
@end
