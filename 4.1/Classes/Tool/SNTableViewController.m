//
//  SNTableViewController.m
//  2tch
//
//  Created by sonson on 08/11/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "SNTableViewController.h"


@implementation SNTableViewController

@synthesize tableView = tableView_;

#pragma mark Helper for UITableView

- (void)deselectRow:(BOOL)animated {
	NSIndexPath *path = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:path animated:animated];
}

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

- (void)viewDidAppear:(BOOL)animated {
	[self deselectRow:animated];
}

#pragma mark dealloc

- (void)dealloc {
	[tableView_ release];
    [super dealloc];
}

@end
