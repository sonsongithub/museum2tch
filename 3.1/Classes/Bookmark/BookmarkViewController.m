//
//  BookmarkViewController.m
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryFolderCell.h"
#import "BookmarkViewController.h"
#import "BookmarkNaviController.h"
#import "HistoryViewController.h"
#import "TitleViewCell.h"
#import "_tchAppDelegate.h"
#import "global.h"

#define FIXED_ROW_NUMBER 1

NSString *kBookmarkViewCell = @"kBookmarkViewCell";
NSString *kBookmarkViewNormalCell = @"kBoomarkViewNormalCell";

@implementation BookmarkViewController

@synthesize tableView = tableView_;

#pragma mark Class Method

+ (BookmarkViewController*) defaultController {
	BookmarkViewController* obj = [[BookmarkViewController alloc] initWithNibName:nil bundle:nil];
	obj.view.frame = CGRectMake( 0, 0, 320, 372);
	obj.tableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372)];
	[obj.view addSubview:obj.tableView];
	return obj;
}

#pragma mark Original Method to Correspond Button Events

- (void) pushEdit:(id)sender {
	[tableView_ setEditing:YES animated:YES];
	self.navigationItem.rightBarButtonItem = nil;
	[(BookmarkNaviController*)self.navigationController toolbarOfBookmarkViewWithDelegate:self editingFlag:YES];
}

- (void) pushDone:(id)sender {
	[tableView_ setEditing:NO animated:YES];
	
	UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil ) style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(close)];
	self.navigationItem.rightBarButtonItem = item;
	[item release];
	
	[(BookmarkNaviController*)self.navigationController toolbarOfBookmarkViewWithDelegate:self editingFlag:NO];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row < FIXED_ROW_NUMBER ) {
		return 44.0f;
	}
	else {
		return TitleViewCellHeight;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [UIAppDelegate.bookmark.list count] + FIXED_ROW_NUMBER;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row < FIXED_ROW_NUMBER ) {
		return UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		return UITableViewCellAccessoryNone;
	}
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row >= FIXED_ROW_NUMBER ) {
		NSMutableDictionary *dict = [UIAppDelegate.bookmark.list objectAtIndex:indexPath.row-FIXED_ROW_NUMBER];
		[(BookmarkNaviController*)self.navigationController open:dict];
	}
	else if( indexPath.row == 0 ){
		HistoryViewController* con = [HistoryViewController defaultController];
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row >= FIXED_ROW_NUMBER ) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[UIAppDelegate.bookmark.list removeObjectAtIndex:[indexPath row]-FIXED_ROW_NUMBER];
		
		NSArray *ary = [[NSArray alloc] initWithObjects:indexPath, nil];
		[tableView_ deleteRowsAtIndexPaths:ary withRowAnimation:UITableViewRowAnimationLeft];
		[ary release];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row < FIXED_ROW_NUMBER ) {
		HistoryFolderCell *cell = (HistoryFolderCell*)[tableView dequeueReusableCellWithIdentifier:kBookmarkViewNormalCell];
		if (cell == nil) {
			cell = [[[HistoryFolderCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBookmarkViewNormalCell] autorelease];
			cell.hidesAccessoryWhenEditing = NO;
		}
		if( indexPath.row == 0 ) {
			[cell setText:NSLocalizedString( @"History", nil )];
		}
		return cell;
	}
	else {
		TitleViewCell *cell = (TitleViewCell*)[tableView dequeueReusableCellWithIdentifier:kBookmarkViewCell];
		if (cell == nil) {
			cell = [[[TitleViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBookmarkViewCell] autorelease];
		}
		NSMutableDictionary *dict = [UIAppDelegate.bookmark.list objectAtIndex:indexPath.row-FIXED_ROW_NUMBER];
		
		if( [dict objectForKey:@"dat"] != nil ) {
			[cell setTitle:[dict objectForKey:@"title"] res:[dict objectForKey:@"res"] number:indexPath.row boardTitle:[dict objectForKey:@"boardTitle"]];
			[cell confirmHasCacheWithBoardPath:[dict objectForKey:@"boardPath"] dat:[dict objectForKey:@"dat"]];
		}
		else {
			[cell setTitle:[dict objectForKey:@"title"] number:indexPath.row];
		}
		return cell;
	}
}

#pragma mark Row reordering

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row >= FIXED_ROW_NUMBER ) {
		return YES;
	}
	else {
		return NO;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if( proposedDestinationIndexPath.row < FIXED_ROW_NUMBER )
		return [NSIndexPath indexPathForRow:FIXED_ROW_NUMBER inSection:0];
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	id objectToMove = [UIAppDelegate.bookmark.list objectAtIndex:fromIndexPath.row-1];
	[objectToMove retain];
	[UIAppDelegate.bookmark.list removeObjectAtIndex:fromIndexPath.row-1];
	[UIAppDelegate.bookmark.list insertObject:objectToMove atIndex:toIndexPath.row-1];
	[objectToMove release];
}

#pragma mark Override

- (void)viewWillAppear:(BOOL)animated {

	if( !tableView_.editing ) {
		UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil ) style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(close)];
		self.navigationItem.rightBarButtonItem = item;
		[item release];
	}
	
	[(BookmarkNaviController*)self.navigationController toolbarOfBookmarkViewWithDelegate:self editingFlag:tableView_.editing];
	tableView_.delegate = self;
	tableView_.dataSource = self;
	
	[tableView_ deselectRowAtIndexPath:[tableView_ indexPathForSelectedRow] animated:YES];
	
	[tableView_ reloadData];
	
	self.title = NSLocalizedString( @"Bookmark", nil );
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[tableView_ release];
    [super dealloc];
}


@end
