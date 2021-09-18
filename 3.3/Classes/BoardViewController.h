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

@interface BoardViewController : SNTableViewController {
	NSMutableArray				*cellData_;
	BoardViewToolbarController	*toolbarController_;
}

@end
