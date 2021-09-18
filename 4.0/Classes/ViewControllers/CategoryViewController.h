//
//  CategoryViewController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

@class CategoryViewToolbarController;

@interface CategoryData : NSObject {
	NSString	*title_;
	int			categoryID_;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int categoryID;
@end

@interface CategoryViewController : SNTableViewController {
	NSMutableArray					*cellData_;
	CategoryViewToolbarController	*toolbarController_;
}
#pragma mark Navigationbar Apperance Controller
- (void)showReloadButton;
- (void)showStopButton;
#pragma mark Push Button Selector
- (void)pushBookmarkButton:(id)sender;
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
#pragma mark Original method
- (void)readCellData;
@end
