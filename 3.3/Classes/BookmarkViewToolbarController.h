//
//  BookmarkViewToolbarController.h
//  2tch
//
//  Created by sonson on 08/12/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface BookmarkViewToolbarController : SNToolbarController {
	UISegmentedControl* segmentController_;
}
- (id)initWithDelegate:(id)delegate;
- (void)setEditEnabled:(BOOL)enabled;
- (void)setNormalMode;
- (void)setBookmarkEditinglMode;
@end
