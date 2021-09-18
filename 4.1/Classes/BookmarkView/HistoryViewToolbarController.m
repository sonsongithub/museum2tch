//
//  HistoryViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/12/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "HistoryViewToolbarController.h"

@implementation HistoryViewToolbarController

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:LocalStr( @"Delete" ) style:UIBarButtonItemStyleBordered target:delegate_ action:@selector(pushDeleteButton:)];
	[items_ addObject:editButton];
	[editButton release];
	
	return self;
}

@end
