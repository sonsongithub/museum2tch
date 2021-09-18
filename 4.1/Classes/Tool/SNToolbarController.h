//
//  SNToolbarController.h
//  2tch
//
//  Created by sonson on 08/11/27.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UISegmentedControl(StopToggle)
- (BOOL) toggleWhenTwoSegments;
- (void) setToggleWhenTwoSegments: (BOOL) flag;
@end

@interface SNToolbarController : NSObject {
	NSMutableArray	*items_;
	UIToolbar		*parentToolbar_;
	id				delegate_;
}
@property (nonatomic, retain) NSMutableArray	*items;
@property (nonatomic, retain) UIToolbar			*parentToolbar;
- (id)initWithDelegate:(id)delegate;
- (void)update;
@end
