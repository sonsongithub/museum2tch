//
//  BoardViewController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNTableViewController.h"

@class BoardViewToolbarController;

@interface BoardData : NSObject {
	NSString	*title_;
	NSString	*path_;
	int			boardID_;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) int boardID;
@end


@interface BoardViewController : SNTableViewController {
	NSMutableArray				*cellData_;
	BoardViewToolbarController	*toolbarController_;
}
#pragma mark Original
- (void)updateTitle;
- (void) readCellData;
#pragma mark Push Button Selector
- (void)pushBookmarkButton:(id)sender;
@end
