//
//  SNToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNToolbarController.h"

@implementation UISegmentedControl(StopToggle)
- (BOOL) toggleWhenTwoSegments {
	return ( _segmentedControlFlags.dontAlwaysToggleForTwoSegments == 0 );
}
- (void) setToggleWhenTwoSegments: (BOOL) flag {
	_segmentedControlFlags.dontAlwaysToggleForTwoSegments = (flag ? 0 : 1);
}
@end

@implementation SNToolbarController

@synthesize items = items_;
@synthesize parentToolbar = parentToolbar_;

- (id)initWithDelegate:(id)delegate {
	self = [super init];
	self.items = [[NSMutableArray alloc] init];
	[self.items release];
	delegate_ = delegate;
	return self;
}

- (void)update {
	[parentToolbar_ setItems:items_ animated:YES];
}

- (void)dealloc {
	[parentToolbar_ release];
	[items_ release];
	[super dealloc];
}

@end
