//
//  SearchViewToolbarController.m
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import "SearchViewToolbarController.h"

@implementation SearchViewToolbarController

@synthesize activityView = activityView_;

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	self = [super initWithDelegate:delegate];
		
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 320, 44 )];
	label.text = LocalStr( @"find.2chProducedByBrazil" );
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:13];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake( 0, -0.5 );
	CGRect labelRect = [label textRectForBounds:CGRectMake(0,0,320,44) limitedToNumberOfLines:1];
	
	UIBarButtonItem *message = [[UIBarButtonItem alloc] initWithCustomView:label];
	[items_ addObject:message];
	[message release];
	[label release];
	
	[items_ addObject:flexibleSpace];
	
	self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	[label addSubview:self.activityView];
	self.activityView.center = CGPointMake( ( 320 - labelRect.size.width - self.activityView.frame.size.width - 10 ) / 2 , 22 );
	[self.activityView startAnimating];
	
	return self;
}

#pragma mark -
#pragma mark Control UIActivityIndicatorView

- (void)showActivityView {
	[self.activityView startAnimating];
	self.activityView.hidden = NO;
}

- (void)hideActivityView {
	[self.activityView stopAnimating];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	DNSLogMethod
	[activityView_ release];
	[super dealloc];
}

@end
