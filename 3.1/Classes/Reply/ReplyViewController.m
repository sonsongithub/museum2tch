//
//  ReplyViewController.m
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewController.h"
#import "_tchAppDelegate.h"
#import "global.h"

#pragma mark Cell Identifier String

NSString* kReplyViewCell1 = @"kReplyViewCell1";
NSString* kReplyViewCell2 = @"kReplyViewCell2";

@implementation ReplyViewController

@synthesize tableView = tableView_;

#pragma mark Class method

+ (ReplyViewController*) defaultController {
	ReplyViewController* obj = [[ReplyViewController alloc] initWithNibName:nil bundle:nil];
	
	[obj makeCells];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 416) style:UITableViewStyleGrouped];
	tableView.delegate = obj;
	tableView.dataSource = obj;
	
	obj.tableView = tableView;
	[obj.view addSubview:obj.tableView];
	[obj.tableView reloadData];
	
	obj.title = NSLocalizedString( @"Write", nil );
	
	return obj;
}

#pragma mark Original

- (void) setAnchor:(int)anchor_number {
	bodyCell_.textView.text = [NSString stringWithFormat:@">>%d\n", anchor_number];
}

- (void) makeCells {
	nameCell_ = [[ReplyViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kReplyViewCell1];
	nameCell_.field.placeholder = NSLocalizedString( @"Name", nil );
	
	emailCell_ = [[ReplyViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kReplyViewCell1];
	emailCell_.field.placeholder = NSLocalizedString( @"E-Mail", nil );
	emailCell_.field.text = @"sage";
	
	bodyCell_ = [[BodyCell alloc] initWithFrame:CGRectZero reuseIdentifier:kReplyViewCell2];
	bodyHeight_ = 200;
}

- (void)pushCloseButton:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)pushSendButton:(id)sender {
	// initialize ReplyController
	[replyCon_ release];
	replyCon_ = [ReplyController defaultController];
	
	replyCon_.name = nameCell_.field.text;
	replyCon_.email = emailCell_.field.text;
	replyCon_.body = bodyCell_.textView.text;
	
	replyCon_.boardPath = [UIAppDelegate.savedThread objectForKey:@"boardPath"];
	replyCon_.dat = [UIAppDelegate.savedThread objectForKey:@"dat"];
	replyCon_.server = [UIAppDelegate.bbsmenu serverOfBoardPath:replyCon_.boardPath];
	
	replyCon_.delegate = self.navigationController;
	
	[replyCon_ send];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row == 2 )
		return bodyHeight_;
	return 44.0f;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row == 0 ) {
		return nameCell_;
	}
	else if( indexPath.row == 1 ) {
		return emailCell_;
	}
	else if( indexPath.row == 2 ) {
		return bodyCell_;
	}
	return nil;
}

#pragma mark Override

- (void) viewWillAppear:(BOOL)animated {
	
	UIBarButtonItem*	closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
	self.navigationItem.leftBarButtonItem = closeButton;
	[closeButton release];
	
	UIBarButtonItem*	sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Write", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(pushSendButton:)];
	self.navigationItem.rightBarButtonItem = sendButton;
	[sendButton release];

	CGRect rect =tableView_.frame;
	rect.size.height = 200.0f;
	tableView_.frame = rect;
	[bodyCell_.textView becomeFirstResponder];
	[tableView_ reloadData];

}

- (void) viewWillDisappear:(BOOL)animated {
	bodyCell_.textView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	DNSLog( @"[ReplyViewController] dealloc" );
	[nameCell_ release];
	[emailCell_ release];
	[bodyCell_ release];
	[tableView_ release];
	[replyCon_ release];
    [super dealloc];
}

@end
