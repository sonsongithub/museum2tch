#import "BookmarkViewController.h"
#import "HistoryViewController.h"
#import "BaseBookmarkViewController.h"
#import "_tchAppDelegate.h"
#import "global.h"

@implementation BookmarkViewController

- (void) awakeFromNib {
	DNSLog(@"[BookmarkViewController] awakeFromNib");
	self.title = NSLocalizedString(@"BookmarkViewTitle", @"");
	tableView_.dataSource = self;
	tableView_.delegate = self;
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"BookmarkViewClose", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(closeAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = closeButton;
	editButton_.title = NSLocalizedString(@"BookmarkViewEdit", @"");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

- (IBAction) closeAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissBookmarkViewMsg object:self];
}

- (IBAction)editAction:(id)sender {
	if( tableView_.editing ) {
		editButton_.title = NSLocalizedString(@"BookmarkViewEdit", @"");
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[tableView_ setEditing:NO animated:YES];
	}
	else {
		editButton_.title = NSLocalizedString(@"BookmarkViewEditComplete", @"");
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[tableView_ setEditing:YES animated:YES];
	}
}

#pragma mark UITableView delegates

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.row == 0 )
		return UITableViewCellEditingStyleNone;
	else
		return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if( proposedDestinationIndexPath.row == 0 ) {
		return sourceIndexPath;
	}
	else
		return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// If you want to prohibit re-ordering, use following code.
	if( indexPath.row == 0 )
		return NO;
	else
		return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 20;//[menuList_ count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	HistoryViewController* targetViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
	[[self navigationController] pushViewController:targetViewController animated:YES];
	[targetViewController release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
	}
	NSString *string = [NSString stringWithFormat:@"%d", indexPath.row];
	[cell setText:string];
	return cell;
}

@end
