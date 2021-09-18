//
//  SNToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNToolbarController.h"

@implementation SNToolbarController

@synthesize items = items_;
@synthesize parentToolbar = parentToolbar_;

- (id)initWithDelegate:(id)delegate {
	self = [super init];
	items_ = [[NSMutableArray alloc] init];
	delegate_ = delegate;
	return self;
}

- (void)update {
	[parentToolbar_ setItems:items_ animated:YES];
}

- (void)dealloc {
	[items_ release];
	[super dealloc];
}

@end
