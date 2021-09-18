//
//  TitleViewController.m
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "TitleViewController.h"
#import "TitleViewCell.h"
#import "DatInfo.h"
#import "ThreadDat.h"
#import "global.h"
#import "ThreadViewController.h"
#import "BookmarkNaviController.h"

NSString *kTitleViewSubjectDownload = @"kTitleViewSubjectDownload";
NSString *kTitleViewSubjectAutoreloadDownload = @"kTitleViewSubjectAutoreloadDownload";
NSString *kTitleViewCell = @"TitleViewCell_ID";

@implementation UpdateSubjectTxtOperation

- (id)initWithMutableArray:(NSMutableArray*)list queue:(NSOperationQueue*)qq {
	self = [super init];
	
	list_ = list;
	queue_ = [qq retain];
	
	return self;
}

- (void) dealloc {
	[queue_ release];
	[super dealloc];
}

-(void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSLog( @"[UpdateSubjectTxtOperation] start" );
	
	int i;
	int num;
	@synchronized( UIAppDelegate.subjectTxt ) {
		num = [UIAppDelegate.subjectTxt.subjectList count];
	}
	for( i =  num - 1; i >=0; i-- ) {
		if( [self isCancelled] )
			break;
		@synchronized( UIAppDelegate.subjectTxt ) {
			NSMutableDictionary* dict = [UIAppDelegate.subjectTxt.subjectList objectAtIndex:i];
			updateSubjectDictionary( dict );
		}
	}
	if( ![self isCancelled] ) {
		[NSThread sleepForTimeInterval:0.05];
		@synchronized( UIAppDelegate ) {
		if( [UIAppDelegate.navigationController.topViewController isKindOfClass:[TitleViewController class]] && [UIAppDelegate.navigationController.visibleViewController isKindOfClass:[TitleViewController class]] )
			[UIAppDelegate.toolbarController performSelectorOnMainThread:@selector(updateTitleViewMessageWithString:) withObject:[UIAppDelegate.subjectTxt updateDateString] waitUntilDone:YES];
		}
	}

	if( ![self isCancelled] )
		NSLog( @"[UpdateSubjectTxtOperation] finished" );
	else
		NSLog( @"[UpdateSubjectTxtOperation] canceled" );
	
	[pool release];
}

@end

@implementation TitleViewController

#pragma mark Original method - Update Cell Dictionary

- (void) updateSubjectDictionaryFromTail {
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	
	
	
	UpdateSubjectTxtOperation *op = [[UpdateSubjectTxtOperation alloc] initWithMutableArray:UIAppDelegate.subjectTxt.subjectList queue:queueToUpdateSubjectTxt_];
	[queueToUpdateSubjectTxt_ addOperation: op];
	[op release];	
}

#pragma mark Original Method

- (BOOL) restoreDataFromCache {
	

	UIAppDelegate.subjectTxt = [SubjectTxt RestoreFromEvacuation];
	
	if( UIAppDelegate.subjectTxt != nil ) {
		targetList_ = UIAppDelegate.subjectTxt.subjectList;
		if( ![UIAppDelegate.subjectTxt.keyword isEqualToString:@""] && UIAppDelegate.subjectTxt.keyword != nil) {
			
			[UIAppDelegate.toolbarController setTitleViewWithCancelButtonMode:self];
			
			searchbar_.text = UIAppDelegate.subjectTxt.keyword;
			
			[searchedList_ removeAllObjects];
			
			for( NSMutableDictionary *dict in UIAppDelegate.subjectTxt.subjectList ) {
				updateSubjectDictionary( dict );
				NSString* title = [dict objectForKey:@"title"];
				if( [title rangeOfString:UIAppDelegate.subjectTxt.keyword options:NSCaseInsensitiveSearch].location != NSNotFound ) {
					[searchedList_ addObject:dict];
				}
			}
			targetList_ = searchedList_;
		}
		return YES;
	}

	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	//		NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
	NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
	UIAppDelegate.subjectTxt = [SubjectTxt SubjectTxtFromCacheWithBoardPath:path];

	if( UIAppDelegate.subjectTxt != nil ) {
		targetList_ = UIAppDelegate.subjectTxt.subjectList;
		return YES;
	}
	return NO;
}

- (void) initializeSearchBar {
	

	if( !searchbar_.opaque ) {
		[UIAppDelegate.toolbarController setTitleViewMode:self];
		NSLog( @"Searchbar is opaque" );
	}
	else {
		[UIAppDelegate.toolbarController setTitleViewWithCancelButtonMode:self];
		NSLog( @"Searchbar is not opaque" );
	}
}

- (void) pushBookmarkButton:(id)sender {
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	
	[UIAppDelegate.downloder cancel];
	[[self navigationController] presentModalViewController:UIAppDelegate.bookmarkNaviController animated:YES];
}

- (void) pushAddButton:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AreYouSureToAddBookmark", nil )
													   delegate:self
											  cancelButtonTitle:NSLocalizedString( @"Cancel", nil )
										 destructiveButtonTitle:NSLocalizedString( @"Add", nil )
											  otherButtonTitles:nil];
	[sheet showInView:self.view];
	[sheet release];
	confirmBookmarkAddSheet_ = sheet;
}

- (void) pushNextView {
	
	
	NSString* searchWord = ( searchbar_.text != nil ) ? searchbar_.text : @"";
	[UIAppDelegate.subjectTxt evacuate:searchWord];
	[UIAppDelegate.subjectTxt release];
	UIAppDelegate.subjectTxt = nil;

	// push next view
	ThreadViewController* viewCon = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewCon animated:YES]; 
	[viewCon release];

}

- (BOOL) autoreload {
	DNSLog( @"[TitleViewController] autoreload" );
	
	
	NSDate *dataDate = UIAppDelegate.subjectTxt.updateDate;
	
	if( [dataDate timeIntervalSinceNow] < -AUTO_RELOAD_INTERVAL_SECOND ) {
		DNSLog( @"[TitleViewController] have to update" );
		
		[queueToUpdateSubjectTxt_ cancelAllOperations];
		[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
		
		UIAppDelegate.downloder.delegate = self;
		
		int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
		int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
		NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
		
		NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
		NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, path];
		
		DNSLog( @"URL - %@", url );
		
		[UIAppDelegate.toolbarController clear:self];
		[UIAppDelegate.downloder startWithURL:url identifier:kTitleViewSubjectAutoreloadDownload];
		
		[self toggleStopButton];
		return YES;
	}
	return NO;
}

- (void) pushReloadButton:(id)sender {
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	
	
	UIAppDelegate.downloder.delegate = self;
	
	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	
	NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
	NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
	NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, path];
	
	DNSLog( @"URL - %@", url );
	
	[UIAppDelegate.toolbarController clear:self];
	[UIAppDelegate.downloder startWithURL:url identifier:kTitleViewSubjectDownload];
	
	[self toggleStopButton];
}

- (void)pushStopButton:(id)sender {
	
	[UIAppDelegate.downloder cancel];
	[self toggleReloadButton];
	[UIAppDelegate.toolbarController back];
	
	[self updateSubjectDictionaryFromTail];
}

- (void) clearSearchStatus {
	if( searchbar_.opaque ) {
		CGRect rect = tableView_.frame;
		rect.origin.y -= 44;
		rect.size.height += 44;
		tableView_.frame = rect;
		[searchbar_ setAlpha:0.0f];
		searchbar_.opaque = !searchbar_.opaque;
	}
	searchbar_.text = @"";
	
	[searchedList_ removeAllObjects];
	targetList_ = nil;
	[tableView_ reloadData];
}

- (void)pushReplyButton:(id)sender {
	[UIView beginAnimations:@"start" context:nil];
	if( searchbar_.opaque ) {
		CGRect rect = tableView_.frame;
		rect.origin.y -= 44;
		rect.size.height += 44;
		tableView_.frame = rect;	
		
		[tableView_ reloadData];
		[searchbar_ setAlpha:0.0f];
	}
	searchbar_.text = @"";
	searchbar_.opaque = !searchbar_.opaque;
	[UIView commitAnimations];
	
	
	[UIAppDelegate.toolbarController setTitleViewWithSearchButtonMode:self];
	
	[searchedList_ removeAllObjects];
	targetList_ = UIAppDelegate.subjectTxt.subjectList;
	[tableView_ reloadData];
}

- (void)pushSearchButton:(id)sender {
	[UIView beginAnimations:@"start" context:nil];
	
	CGRect rect = tableView_.frame;
	rect.origin.y += 44;
	rect.size.height -= 44;
	tableView_.frame = rect;
	searchbar_.text = @"";
	[searchbar_ setAlpha:1.0f];
	[searchbar_ becomeFirstResponder];
	
	[UIAppDelegate.toolbarController setTitleViewWithCancelButtonMode:self];
	
	[searchedList_ removeAllObjects];
	[tableView_ reloadData];
	
	searchbar_.opaque = !searchbar_.opaque;
	[UIView commitAnimations];
}

- (void) doSearch:(NSString*)keyword {
	
	[searchedList_ removeAllObjects];
	
	for( NSMutableDictionary *dict in UIAppDelegate.subjectTxt.subjectList ) {
		updateSubjectDictionary( dict );
		NSString* title = [dict objectForKey:@"title"];
		if( [title rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			[searchedList_ addObject:dict];
		}
	}
	targetList_ = searchedList_;
	[tableView_ reloadData];
}

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

- (void) addBookmark {
	
	
	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	
//	NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
	NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
//	NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, path];
	NSString* title = [[boardList objectAtIndex:selected_board_id] objectForKey:@"title"];

	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:path forKey:@"boardPath"];
	[dict setObject:title forKey:@"title"];
	
	[UIAppDelegate.bookmark addWithDictinary:dict];	
	[dict release];

}

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		tableView_ = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, 320, 372 )];
		[self.view addSubview:tableView_];
		tableView_.delegate = self;
		tableView_.dataSource = self;

		queueToUpdateSubjectTxt_ = [[NSOperationQueue alloc] init];
		
		searchbar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
		searchbar_.showsCancelButton = YES;
		searchbar_.delegate = self;
		searchbar_.opaque = NO;
		[searchbar_ setAlpha:0.0f];
		searchedList_ = [[NSMutableArray array] retain];
		[self.view addSubview:searchbar_];
	
		
		int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
		int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
		NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
		self.title = [[boardList objectAtIndex:selected_board_id] objectForKey:@"title"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (void)dealloc {
//	
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	[queueToUpdateSubjectTxt_ release];
	NSLog( @"[TitleViewController] %@ dealloc", self );
	[tableView_ release];
	[searchbar_ release];
	[searchedList_ release];
    [super dealloc];
}

- (void) viewDidAppear:(BOOL)animated {
	BOOL isAutoreloading = NO;
	
	
	
	if( UIAppDelegate.subjectTxt == nil ) {
		
		UIAppDelegate.downloder.delegate = self;
		
		int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
		int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
		NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
		
		NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
		NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, path];
		
		DNSLog( @"URL - %@", url );
		
		[UIAppDelegate.downloder startWithURL:url identifier:kTitleViewSubjectDownload];
		[self toggleStopButton];
		return;
	}
	
	if( !searchbar_.opaque )
		isAutoreloading = [self autoreload];
	
	if( targetList_ != nil && [targetList_ count] != 0 && !isAutoreloading ) {
		[self updateSubjectDictionaryFromTail];
	}
}


- (void) viewWillAppear:(BOOL)animated {
	
	[self toggleReloadButton];
	
	[UIAppDelegate.toolbarController clear:self];
	
	// release bbsemenu memory for low memory status
	[UIAppDelegate.bbsmenu release];
	UIAppDelegate.bbsmenu = nil;
	
	[UIAppDelegate.savedThread removeAllObjects];
	
	// clear status
	
	
	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	
//	NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
//	NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
//	NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, path];
	NSString* title = [[boardList objectAtIndex:selected_board_id] objectForKey:@"title"];
	self.title = title;
	
	if( [self restoreDataFromCache] ) {
		[self initializeSearchBar];
		[tableView_ reloadData];
	}
	else {
	}
}

- (void) viewWillDisappear:(BOOL)animated {
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	
	[UIAppDelegate.downloder cancel];
}

- (void) viewDidDisappear:(BOOL)animated {
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( actionSheet == confirmBookmarkAddSheet_ ) {
		if( buttonIndex == 0 )
			[self addBookmark];
	}
}

#pragma mark UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[UIView beginAnimations:@"start" context:nil];
	if( searchbar_.opaque ) {
		CGRect rect = tableView_.frame;
		rect.origin.y -= 44;
		rect.size.height += 44;
		tableView_.frame = rect;	
		
		[tableView_ reloadData];
		[searchbar_ setAlpha:0.0f];
		searchbar_.opaque = !searchbar_.opaque;
	}
	searchbar_.text = @"";
	[UIView commitAnimations];
	
	
	[UIAppDelegate.toolbarController setTitleViewWithSearchButtonMode:self];
	
	[searchedList_ removeAllObjects];
	targetList_ = UIAppDelegate.subjectTxt.subjectList;
	[tableView_ reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[searchBar resignFirstResponder];
	[UIAppDelegate.toolbarController setTitleViewWithCancelButtonMode:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self doSearch:searchText];
}

#pragma mark DownloaderDelegate

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	DNSLog( @"[TitleViewController] didFinishLoading: - %@", identifier );
	[self toggleReloadButton];
	
	if( [identifier isEqualToString:kTitleViewSubjectDownload] || [identifier isEqualToString:kTitleViewSubjectAutoreloadDownload] ) {
		
		
		int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
		int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
		NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
//		NSString* server = [[boardList objectAtIndex:selected_board_id] objectForKey:@"server"];
		NSString* path = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
		
		[UIAppDelegate.subjectTxt release];
		UIAppDelegate.subjectTxt = [SubjectTxt SubjectTxtWithData:data path:path];
		targetList_ = UIAppDelegate.subjectTxt.subjectList;
		[tableView_ reloadData];
		[self updateSubjectDictionaryFromTail];
		[UIAppDelegate.toolbarController setTitleViewMode:self];
	}
}

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	[self toggleReloadButton];

	if( [identifier isEqualToString:kTitleViewSubjectDownload] ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:[error localizedDescription]
												   delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString( @"OK", nil), nil];
		[alert show];
		[alert release];
	}
	if( [identifier isEqualToString:kTitleViewSubjectAutoreloadDownload] ){
		[self updateSubjectDictionaryFromTail];
	}
	
	
	[UIAppDelegate.savedThread removeAllObjects];
	[UIAppDelegate.toolbarController back];
}

#pragma mark UITableView delegates

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *ary = [NSMutableArray array];
	int i;
	for( i = 0; i <= [targetList_ count] / ROW_PER_SECTION; i++ ) {
		if( i % 2 == 0 )
			[ary addObject:[NSString stringWithFormat:@"%d",i*ROW_PER_SECTION+1]];
		else
			[ary addObject:[NSString stringWithFormat:@"●"]];
	}
	return ary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Number of sections is the number of region dictionaries
	return [targetList_ count] / ROW_PER_SECTION + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( section == [targetList_ count] / ROW_PER_SECTION ) {
		return ( [targetList_ count] % ROW_PER_SECTION );
	}
	else
		return ROW_PER_SECTION;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"%d - ", section*ROW_PER_SECTION+1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return TitleViewCellHeight;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[queueToUpdateSubjectTxt_ cancelAllOperations];
	[queueToUpdateSubjectTxt_ waitUntilAllOperationsAreFinished];
	
	[self toggleReloadButton];
	
	int index_row = indexPath.section * ROW_PER_SECTION + indexPath.row;
	
	NSMutableDictionary* targetListDict = [targetList_ objectAtIndex:index_row];
	NSString* dat = [targetListDict objectForKey:@"dat"];
	NSString* title = [targetListDict objectForKey:@"title"];

	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	NSString* boardPath = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
//	NSString* server = [UIAppDelegate.bbsmenu serverOfBoardPath:boardPath];
	
	// set operation info
	[UIAppDelegate.savedThread removeAllObjects];
	[UIAppDelegate.savedThread setObject:dat forKey:@"dat"];
	[UIAppDelegate.savedThread setObject:boardPath forKey:@"boardPath"];
	[UIAppDelegate.savedThread setObject:title forKey:@"title"];
	
	[self pushNextView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TitleViewCell *cell = (TitleViewCell*)[tableView dequeueReusableCellWithIdentifier:kTitleViewCell];
	if (cell == nil) {
		cell = [[[TitleViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kTitleViewCell] autorelease];
	}
	int row_number = indexPath.section * ROW_PER_SECTION + indexPath.row;
	
	
	
	NSMutableDictionary *dict = [targetList_ objectAtIndex:row_number];
	
	updateSubjectDictionary(dict);
	
	int selected_category_id = [[UIAppDelegate.savedLocation objectAtIndex:0] intValue];
	int selected_board_id = [[UIAppDelegate.savedLocation objectAtIndex:1] intValue];
	NSMutableArray *boardList  = [[UIAppDelegate.bbsmenu.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	NSString* boardPath = [[boardList objectAtIndex:selected_board_id] objectForKey:@"path"];
	
	[cell setTitle:[dict objectForKey:@"title"] res:[dict objectForKey:@"res"] number:row_number+1 boardTitle:nil];
	[cell confirmHasCacheWithBoardPath:boardPath dat:[dict objectForKey:@"dat"]];

	return cell;
}

@end
