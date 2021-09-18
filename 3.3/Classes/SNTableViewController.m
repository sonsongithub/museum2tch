//
//  SNTableViewController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNTableViewController.h"


@implementation SNTableViewController

@synthesize tableView = tableView_;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372) style:style];
		tableView_.delegate = self;
		tableView_.dataSource = self;
		[self.view addSubview:tableView_];
    }
    return self;
}

#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark dealloc

- (void)dealloc {
	[tableView_ release];
    [super dealloc];
}

@end
