#import "BoardViewController.h"
#import "BaseBookmarkViewController.h"
#import "ThreadTitleViewController.h"
#import "_tchAppDelegate.h"
#import "global.h"

NSString *kBoardViewCell = @"BoardTitleCell_ID";
NSString *kBoardViewSubjectTxt = @"SubjectTxtDownload_ID";

@implementation BoardViewController

#pragma mark Override 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		downloader_ = [[Downloader alloc] initWithDelegate:self];
		downloader_.navitaionItemDelegate = self.navigationItem;
		boards_ = [[NSMutableArray array] retain];
	}
	return self;
}

- (void) viewWillAppear:(BOOL)animated {
//	[tableView_ reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[app.savedThread removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated {
	DNSLog( @"[BoardViewController] viewWillDisappear:animated" );
	[self hideUIToolbarStop];
	[downloader_ cancel];
}

- (void) dealloc {
	DNSLog( @"[BoardViewController] dealloc" );
	[boards_ release];
	[downloader_ release];
	[super dealloc];
}

#pragma mark UIViewControllerDelegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

#pragma mark Original method

- (void) reloadTableView {
	[tableView_ reloadData];
	NSIndexPath *tableSelection = [tableView_ indexPathForSelectedRow];
	[tableView_ deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void) hideUIToolbarStop {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	if( [items count] == 3 ) {
		[items removeLastObject];
		[underToolbar_ setItems:items animated:NO];
	}
}

- (void) showUIToolbarStop {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	if( [items count] == 2 ) {
		UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLoading:)] autorelease];
		[items addObject:systemItem];
		[underToolbar_ setItems:items animated:NO];
	}
}

- (IBAction) cancelLoading:(id)sender {
	DNSLog( @"[BoardViewController] cancelLoading:" );
	[downloader_ cancel];
	[self hideUIToolbarStop];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
}

#pragma mark IBAction

- (IBAction)openBookmarkAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[self presentModalViewController:app.baseBookmarkViewController animated:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

#pragma mark Downloader delegates

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	DNSLog( @"[BoardViewController] didFailLoading - %@", identifier );
	[self hideUIToolbarStop];
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"DownloaderNetworkErrorMsg", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
}

- (void) finishParseSubjectTxt {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	int currentSelected = [[app.savedLocation objectAtIndex:1] intValue];
	NSMutableDictionary *dict = [db.boardList objectAtIndex:currentSelected];
	
	if( [db.subjectList count] > 0 ) {
		app.threadTitleViewController.title = [dict objectForKey:@"title"];
		app.currentBoardPath = [dict objectForKey:@"path"];
		[app.threadTitleViewController prepareTable];
		[app.threadTitleViewController reloadTableView];
		[[self navigationController] pushViewController:app.threadTitleViewController animated:YES];
	}
	else {
		// here delete strange cache file, this is called when cache exists, but it's not good.
		app.threadTitleViewController.title = [dict objectForKey:@"title"];
		app.currentBoardPath = [dict objectForKey:@"path"];
		[db deleteSubjectTxtOfBoardPath:app.currentBoardPath delegate:self];
	}
}

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[BoardViewController] didFinishLoadging - %@", identifier );
	[self hideUIToolbarStop];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	int currentSelected = [[app.savedLocation objectAtIndex:1] intValue];
	NSMutableDictionary *dict = [db.boardList objectAtIndex:currentSelected];

	NSString* path = [dict objectForKey:@"path"];
	[db parseSubjectTxt:data ofBoardPath:path delegate:self];
}

#pragma mark UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	return [db.boardList count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)restoreWithSelectionArray:(NSArray *)selectionArray {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	NSInteger itemIdx = [[selectionArray objectAtIndex:0] integerValue];
	if (itemIdx != -1) {
		NSMutableDictionary *dict = [db.boardList objectAtIndex:itemIdx];
		if( [SubjectDataBase isExistingCache:[dict objectForKey:@"path"]] ) {
			[db loadSubjectTxtCache:[dict objectForKey:@"path"]];
			if( [db.subjectList count] > 0 ) {
				app.threadTitleViewController.title = [dict objectForKey:@"title"];
				app.currentBoardPath = [dict objectForKey:@"path"];
				[app.threadTitleViewController prepareTable];
				[[self navigationController] pushViewController:app.threadTitleViewController animated:NO];
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSMutableDictionary *dict = [db.boardList objectAtIndex:indexPath.row];
	
	[app.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:indexPath.row]];
	
	if( [SubjectDataBase isExistingCache:[dict objectForKey:@"path"]] ) {
		[db loadSubjectTxtCache:[dict objectForKey:@"path"]];
		[self finishParseSubjectTxt];
	}
	else {
		[self showUIToolbarStop];
		[downloader_ cancel];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", [dict objectForKey:@"server"], [dict objectForKey:@"path"]];
		DNSLog( @"[BoardViewController] %@", url );
		[downloader_ startWithURL:url identifier:kBoardViewSubjectTxt];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kBoardViewCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kBoardViewCell] autorelease];
	}
	[cell prepareForReuse];
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSMutableDictionary *dict = [db.boardList objectAtIndex:indexPath.row];
	NSString *string = [dict objectForKey:@"title"];
	[cell setText:string];
	
	return cell;
}

@end
