//
//  CategoryViewController.m
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "BoardViewController.h"
#import "BookmarkNaviController.h"
#import "_tchAppDelegate.h"
#import "InfoNaviController.h"
#import "BBSMenu.h"
#import "global.h"


NSString *kCategoryViewCell = @"CategoryTitleCell_ID";
NSString *kMainViewBBSMenu = @"BBSMenuHTMLDownload_ID";

@implementation CategoryViewController

#pragma mark Original method

#pragma mark Button Event

- (void) pushBookmarkButton:(id)sender {
	[UIAppDelegate.downloder cancel];
	[[self navigationController] presentModalViewController:UIAppDelegate.bookmarkNaviController animated:YES];
}

- (void)pushReloadButton:(id)sender {
	UIAppDelegate.downloder.delegate = self;
	[UIAppDelegate.downloder startWithURL:@"http://menu.2ch.net/bbstable.html" identifier:kMainViewBBSMenu];
	[self toggleStopButton];
}

- (void)pushStopButton:(id)sender {
	[UIAppDelegate.downloder cancel];
	[self toggleReloadButton];
}

- (void)pushInfoView:(id)sender {
	InfoNaviController *con = [InfoNaviController defaultController];
	[[self navigationController] presentModalViewController:con animated:YES];
	[con release];
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

- (void)viewDidLoad {
	[UIAppDelegate.bbsmenu release];
	UIAppDelegate.bbsmenu = [BBSMenu BBSMenuWithDataFromCache];
	
	self.title = NSLocalizedString( @"Category", nil );
	
	tableView_ = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372 )];
	[self.view addSubview:tableView_];
	tableView_.delegate = self;
	tableView_.dataSource = self;
	[tableView_ reloadData];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self toggleInfoViewButton];
	[self toggleReloadButton];
	[tableView_ reloadData];
	[UIAppDelegate.toolbarController setCategoryViewMode:self];
	UIAppDelegate.toolbarController.centerMessage.text = [UIAppDelegate.bbsmenu updateDateString];
		
	[UIAppDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
	[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[UIAppDelegate.savedThread removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DNSLog( @"[CategoryViewController] didReceiveMemoryWarning" );
}

- (void)dealloc {
	NSLog( @"[CategoryViewController] dealloc" );
	[tableView_ release];
    [super dealloc];
}

#pragma mark DownloaderDelegate

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[CategoryViewController] didFinishLoading: - %@", identifier );
	[self toggleReloadButton];
	
	[UIAppDelegate.bbsmenu release];
	UIAppDelegate.bbsmenu = [BBSMenu BBSMenuWithData:data];
	[tableView_ reloadData];
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
	[alert show];
	[alert release];
	
	[self toggleStopButton];
}

#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [UIAppDelegate.bbsmenu.categoryList count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DNSLog( @"%d", indexPath.row );
	[UIAppDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:indexPath.row]];
	[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	
	BoardViewController* viewCon = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewCon animated:YES]; 
	[viewCon release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCategoryViewCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCategoryViewCell] autorelease];
	}
	NSString *title = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:[indexPath row]] objectForKey:@"title"];
	[cell setText:title];
	return cell;
}

@end
