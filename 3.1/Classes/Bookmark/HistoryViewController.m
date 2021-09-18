//
//  HistoryViewController.m
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkNaviController.h"
#import "HistoryViewController.h"
#import "TitleViewCell.h"
#import "_tchAppDelegate.h"
#import "global.h"

NSString *kHistoryViewCell = @"kHistoryViewCell";
NSString *kNotificationCloseLoadingView = @"kNotificationCloseLoadingView";
NSString *kNotificationFinishHistoryLoading = @"kNotificationFinishHistoryLoading";

@implementation HistoryViewController

@synthesize tableView = tableView_;

#pragma mark Class Method

+ (HistoryViewController*) defaultController {
	HistoryViewController* obj = [[HistoryViewController alloc] initWithNibName:nil bundle:nil];
	return obj;
}

#pragma mark Original Method

- (void) pushEdit:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToDeleteHistory", nil )
													   delegate:self
											  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
										 destructiveButtonTitle:NSLocalizedString( @"OK", nil )
											  otherButtonTitles:nil];
	[sheet showInView:self.view];
	[sheet release];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return TitleViewCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [cellList_ count] == 0 ? 1 : [cellList_ count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( [cellList_ count] == 0 )
		return NSLocalizedString( @"NoHistory", nil );
	NSDictionary* dict = [cellList_ objectAtIndex:section];
	return [dict objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( [cellList_ count] == 0 )
		return 0;
	NSDictionary* dict = [cellList_ objectAtIndex:section];
	return [[dict objectForKey:@"rowList"] count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dict = [cellList_ objectAtIndex:indexPath.section];
	NSMutableArray* rowList = [dict objectForKey:@"rowList"];
	[(BookmarkNaviController*)self.navigationController open:[rowList objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	TitleViewCell *cell = (TitleViewCell*)[tableView dequeueReusableCellWithIdentifier:kHistoryViewCell];
	if (cell == nil) {
		cell = [[[TitleViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kHistoryViewCell] autorelease];
	}
	
	NSMutableDictionary *section = [cellList_ objectAtIndex:indexPath.section];
	NSMutableArray* rowList = [section objectForKey:@"rowList"];
	NSMutableDictionary*dict = [rowList objectAtIndex:indexPath.row];
	
	[cell setTitle:[dict objectForKey:@"title"] res:[dict objectForKey:@"res"] number:indexPath.row+1 boardTitle:[dict objectForKey:@"boardTitle"] date:[dict objectForKey:@"date"]];
	[cell confirmHasCacheWithBoardPath:[dict objectForKey:@"boardPath"] dat:[dict objectForKey:@"dat"]];
	
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *ary = [[NSMutableArray alloc] init];
	[ary autorelease];
	int i;
	for( i = 0; i <[cellList_ count]; i++ ) {
		NSString* numberString = [[NSString alloc] initWithFormat:@"%d", i*50+1];
		[ary addObject:numberString];
		[numberString release];
	}
	return ary;
}


#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		[UIAppDelegate.history clear];
		[cellList_ removeAllObjects];
		[tableView_ reloadData];
	}
	else {
		NSLog(@"cancel");
	}
}
#pragma mark Override

- (id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	
	self.view.frame = CGRectMake( 0, 0, 320, 372);
	tableView_ = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372)];
	[self.view addSubview:tableView_];
	[tableView_ release];
	tableView_.delegate = self;
	tableView_.dataSource = self;
	
	return self;
}

- (void) viewDidAppear:(BOOL)animated {
	NSMutableArray* historyList = UIAppDelegate.history.list;
	
	int counter = 0;
	
	cellList_ = [[NSMutableArray alloc] init];
	NSMutableDictionary *data = nil;
	
	for( NSMutableDictionary *dict in historyList ) {
		if( counter % 50 == 0 ) {
			data = [[NSMutableDictionary alloc] init];
			[cellList_ addObject:data];
			[data release];
			
			NSString* numberString = [[NSString alloc] initWithFormat:@"%d", counter+1];
			[data setObject:numberString forKey:@"title"];
			NSMutableArray* rowList = [[NSMutableArray alloc] init];
			[data setObject:rowList forKey:@"rowList"];
			[numberString release];
			[rowList release];
		}
		if( data ) {
			NSMutableArray *rowList = [data objectForKey:@"rowList"];
			[rowList addObject:dict];
		}
		counter++;
	}
	[tableView_ reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !tableView_.editing ) {
		UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil ) style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(close)];
		self.navigationItem.rightBarButtonItem = item;
		[item release];
	}
	[(BookmarkNaviController*)self.navigationController toolbarOfHistoryViewWithDelegate:self];
	self.title = NSLocalizedString( @"History", nil );
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[cellList_ release];
    [super dealloc];
}

@end
