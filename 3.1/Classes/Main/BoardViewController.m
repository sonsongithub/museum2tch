//
//  BoardViewController.m
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardViewController.h"
#import "BookmarkNaviController.h"
#import "TitleViewController.h"
#import "SubjectTxt.h"
#import "_tchAppDelegate.h"
#import "global.h"

NSString *kBoardViewBBSMenuDownload = @"BoardViewBBSMenuDownload";
NSString *kBoardViewSubjectDownload = @"BoardViewSubjectDownload";
NSString *kBoardViewCell = @"BoardTitleCell_ID";

@implementation BoardViewController

#pragma mark Original method

#pragma mark Button Event

- (void) pushBookmarkButton:(id)sender {
	[UIAppDelegate.downloder cancel];
	[[self navigationController] presentModalViewController:UIAppDelegate.bookmarkNaviController animated:YES];
}

- (void)pushReloadButton:(id)sender {
	UIAppDelegate.downloder.delegate = self;
	[UIAppDelegate.downloder startWithURL:@"http://menu.2ch.net/bbstable.html" identifier:kBoardViewBBSMenuDownload];
	[self toggleStopButton];
}

- (void)pushStopButton:(id)sender {
	[UIAppDelegate.downloder cancel];
	[self toggleReloadButton];
}

#pragma mark Setting UIBarButtonItem

- (void) toggleReloadButton {	
	UIBarButtonItem*	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pushReloadButton:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
}

- (void) toggleStopButton {	
	UIBarButtonItem*	stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pushStopButton:)];
	self.navigationItem.rightBarButtonItem = stopButton;
	[stopButton release];
}

- (void) toggleInfoViewButton {	
	UIBarButtonItem*	infoButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Info", nil) style:UIBarButtonItemStylePlain target:self action:@selector(pushInfoView:)];
	self.navigationItem.leftBarButtonItem = infoButton;
	[infoButton release];
}

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372 )];
		[self.view addSubview:tableView_];
		tableView_.delegate = self;
		tableView_.dataSource = self;
		[tableView_ reloadData];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	DNSLog( @"[BoardViewController] didReceiveMemoryWarning" );
}

- (void)dealloc {
	NSLog( @"[BoardViewController] dealloc" );
	[tableView_ release];
    [super dealloc];
}

#pragma mark UIViewControllerDelegate

- (void) viewWillAppear:(BOOL)animated {
	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	boardList_  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	self.title = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"title"];
	[tableView_ reloadData];
	[self toggleReloadButton];
	[UIAppDelegate.toolbarController setBoardViewMode:self];
	UIAppDelegate.toolbarController.centerMessage.text = [UIAppDelegate.bbsmenu updateDateString];
	
	[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[UIAppDelegate.savedThread removeAllObjects];
}

- (void) viewWillDisappear:(BOOL)animated {
	[UIAppDelegate.downloder cancel];
}

#pragma mark DownloaderDelegate

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[CategoryViewController] didFinishLoading: - %@", identifier );
	[self toggleReloadButton];
	
	if( [identifier isEqualToString:kBoardViewBBSMenuDownload] ) {
		[self.navigationController popViewControllerAnimated:YES];
		[UIAppDelegate.bbsmenu release];
		UIAppDelegate.bbsmenu = [BBSMenu BBSMenuWithData:data];
	}
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
	[alert show];
	[alert release];
	[self toggleReloadButton];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [boardList_ count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dict = [boardList_ objectAtIndex:indexPath.row];
	[UIAppDelegate.subjectTxt release];
	UIAppDelegate.subjectTxt = [SubjectTxt SubjectTxtFromCacheWithBoardPath:[dict objectForKey:@"path"]];
	[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:indexPath.row]];
	TitleViewController* viewCon = [[TitleViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewCon animated:YES];
	[viewCon release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kBoardViewCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBoardViewCell] autorelease];
	}
	NSString* title = [[boardList_ objectAtIndex:[indexPath row]] objectForKey:@"title"];
	[cell setText:title];
	return cell;
}

@end
