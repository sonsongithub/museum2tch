//
//  ThreadViewToolbarController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewToolbarController.h"

@implementation ThreadViewToolbarController

- (id)initWithDelegate:(id)delegate {
	DNSLogMethod
	UIBarButtonItem *flexibleSpace = nil;
	self = [super initWithDelegate:delegate];
	
	UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:delegate_ action:@selector(pushBookmarkButton:)];
	[items_ addObject:bookmark];
	[bookmark release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate_ action:@selector(pushAddButton:)];
	[items_ addObject:add];
	[add release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate_ action:@selector(pushSearchButton:)];
	[items_ addObject:search];
	[search release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStylePlain target:delegate_ action:@selector(pushBackButton:)];
	[items_ addObject:back];
	[back release];
	
	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Forward.png"] style:UIBarButtonItemStylePlain target:delegate_ action:@selector(pushForwardButton:)];
	[items_ addObject:forward];
	[forward release];

	flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items_ addObject:flexibleSpace];
	[flexibleSpace release];
	
	UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:delegate_ action:@selector(pushComposeButton:)];
	[items_ addObject:compose];
	[compose release];
	
	back.enabled = NO;
	forward.enabled = NO;
	
	return self;
}

- (void)setSearchButton {
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:delegate_ action:@selector(pushSearchButton:)];
	[items_ replaceObjectAtIndex:4 withObject:search];
	[search release];
	[self update];
}

- (void)setCloseSearchButton {
	UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:delegate_ action:@selector(pushCloseSearchButton:)];
	[items_ replaceObjectAtIndex:4 withObject:stop];
	[stop release];
	[self update];
}

- (void)updateBackButton:(BOOL)canGoBack forwardButton:(BOOL)canGoForward {

	UIBarButtonItem *back = [items_ objectAtIndex:6];
	back.enabled = canGoBack;
	
	UIBarButtonItem *forward = [items_ objectAtIndex:8];
	forward.enabled = canGoForward;

	[self update];
}

@end
