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

@interface CategoryViewController : SNTableViewController {
	NSMutableArray					*cellData_;
	CategoryViewToolbarController	*toolbarController_;
}

@end
