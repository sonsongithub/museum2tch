//
//  ThreadViewToolbarController.h
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNToolbarController.h"

@interface ThreadViewToolbarController : SNToolbarController {

}
- (id)initWithDelegate:(id)delegate popupMenuControllerView:(UIView*)view;
- (void)updateBackButton:(BOOL)canGoBack forwardButton:(BOOL)canGoForward;
@end
