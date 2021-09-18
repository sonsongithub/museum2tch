//
//  MainViewController.m
//  2tch
//
//  Created by sonson on 08/05/15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "global.h"
#import "_tchAppDelegate.h"
#import "MainViewController.h"
#import "ThreadTitleViewController.h"
#import "BaseInfoViewController.h"
#import "BaseBookmarkViewController.h"
#import "BoardViewController.h"

NSString *kCategoryViewCell = @"CategoryTitleCell_ID";
NSString *kBBSMenuHTMLURL = @"http://menu.2ch.net/bbsmenu.html";
NSString *kMainViewBBSMenu = @"BBSMenuHTMLDownload_ID";

@implementation MainViewController

#pragma mark Override

- (void) awakeFromNib {
	DNSLog( @"[MainViewController] awakeFromNib" );
	self.title = NSLocalizedString( @"CategoryViewTitle", nil );
	
	openInfoViewButton_.title = NSLocalizedString( @"InfoViewOpen", nil );
	categories_ = [[NSMutableArray array] retain];
	
	downloader_ = [[Downloader alloc] initWithDelegate:self];
	downloader_.navitaionItemDelegate = self.navigationItem;
	tableView_.delegate = self;
	tableView_.dataSource = self;
	[tableView_ reloadData];
}

- (void) viewDidLoad {
}

- (void)dealloc {
	[downloader_ release];
	[categories_ release];
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[app.savedThread removeAllObjects];
}


- (void)viewWillDisappear:(BOOL)animated {
	[downloader_ cancel];
	[self setUIToolbarReload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark original method

- (void)reloadTable {
	[tableView_ reloadData];
}

- (void)restoreWithSelectionArray:(NSArray *)selectionArray {
	DNSLog( @"[MainViewController] restorWithSelectionArray:" );
	
	// move in level 2 and restore its content (not animated since the user should not see the restore process)
	
	// get the level 2 content
	NSInteger itemIdx = [[selectionArray objectAtIndex:0] integerValue];
	
	if( itemIdx == -1 )
		return;
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSMutableDictionary *dict = [db.categoryList objectAtIndex:itemIdx];
	[db setCurrentCategory:itemIdx];
	
	app.currentCategory = [dict objectForKey:@"title"];
	app.boardViewController.title = [dict objectForKey:@"title"];
	[[self navigationController] pushViewController:app.boardViewController animated:NO];
	
	// narrow down the selection array for level 2
	NSArray *newSelectionArray = [selectionArray subarrayWithRange:NSMakeRange(1, [selectionArray count]-1)];
	// restore that level
	[app.boardViewController restoreWithSelectionArray:newSelectionArray];
}

- (void) setUIToolbarReload {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	[items removeLastObject];
    UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startLoading:)] autorelease];
	[items addObject:systemItem];
	[underToolbar_ setItems:items animated:NO];
}

- (void) setUIToolbarStop {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	[items removeLastObject];
    UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLoading:)] autorelease];
	[items addObject:systemItem];
	[underToolbar_ setItems:items animated:NO];
}

#pragma mark IBAction

- (IBAction) startLoading:(id)sender {
	DNSLog( @"[MainViewController] startLoading:" );
	[downloader_ startWithURL:@"http://menu.2ch.net/bbstable.html" identifier:kMainViewBBSMenu];
	DNSLog( kBBSMenuHTMLURL );
	[self setUIToolbarStop];
}

- (IBAction) cancelLoading:(id)sender {
	DNSLog( @"[MainViewController] cancelLoading:" );
	[downloader_ cancel];
	[self setUIToolbarReload];
}

- (IBAction) openSettingAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[[self navigationController] presentModalViewController:app.baseInfoViewController animated:YES];
//	BaseInfoViewController *viewCon = [[BaseInfoViewController alloc] initWithNibName:@"BaseInfoViewController" bundle:nil];
//	[[self navigationController] presentModalViewController:viewCon animated:YES];
//	[viewCon release];
}

- (IBAction)openBookmarkAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[self presentModalViewController:app.baseBookmarkViewController animated:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

#pragma mark Downloader delegates

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[MainViewController] didFinishLoading: - %@", identifier );
	[self setUIToolbarReload];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	[db parseBBSMenu:data];
	[tableView_ reloadData];
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	DNSLog( @"[MainViewController] didFailLoadging - %@", identifier );
	[self setUIToolbarReload];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"DownloaderNetworkErrorMsg", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	return [db.categoryList count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSMutableDictionary *dict = [db.categoryList objectAtIndex:indexPath.row];
	[db setCurrentCategory:indexPath.row];
	
	[app.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:indexPath.row]];
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	
	app.currentCategory = [dict objectForKey:@"title"];
	app.boardViewController.title = [dict objectForKey:@"title"];
	[app.boardViewController reloadTableView];
	[[self navigationController] pushViewController:app.boardViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCategoryViewCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCategoryViewCell] autorelease];
	}
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSMutableDictionary *dict = [db.categoryList objectAtIndex:indexPath.row];
	NSString *string = [dict objectForKey:@"title"];
	[cell setText:string];
	return cell;
}

@end
