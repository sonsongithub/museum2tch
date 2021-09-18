#import "ThreadTitleViewController.h"
#import "ThreadViewController.h"
#import "BaseBookmarkViewController.h"
#import "ThreadTitleViewCell.h"
#import "_tchAppDelegate.h"
#import "global.h"

NSString *kThreadTitleViewSubjectTxt = @"ThreadTitleViewSubjectTxtDownload_ID";
NSString *kThreadTitleViewDat = @"ThreadTitleViewDatDownload_ID";

@implementation ThreadTitleViewController

#pragma mark Override

+ (BOOL) updateSubjectDictionary:(NSMutableDictionary*)dict {
	if( ![dict objectForKey:@"title"] ) {
		NSArray *values = [dict objectForKey:@"source"];
		[dict setObject:getThreadTitle( [values objectAtIndex:1] ) forKey:@"title"];
		[dict setObject:getThreadNumber( [values objectAtIndex:1] ) forKey:@"res"];
		[dict setObject:getDat( [values objectAtIndex:0] ) forKey:@"dat"];
	}
	return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		limitedList_ = [[NSMutableArray array] retain];
		downloader_ = [[Downloader alloc] initWithDelegate:self];
		downloader_.navitaionItemDelegate = self.navigationItem;
		isFinishedUpdateDict_ = YES;
		
		board_id_ = 0;
		
		//
		threads_ = [[NSMutableArray array] retain];
		
		//

		
	}
	return self;
}

- (void) dealloc {
	DNSLog( @"[ThreadTitleViewController] dealloc" );
	[downloader_ release];
	[limitedList_ release];
	[threads_ release];
	
	[super dealloc];
}

- (void) prepareTable {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	targetList_ = db.subjectList;
	[limitedList_ removeAllObjects];
	[tableView_ reloadData];
	
	if( !searchBar_.opaque ) {
		CGRect rect = tableView_.frame;
		rect.origin.y -= 44;
		rect.size.height += 44;
		tableView_.frame = rect;	
		[searchBar_ setAlpha:0.0f];
		searchBar_.opaque = YES;
	}
	[self reloadTableView];
}

- (BOOL) stopBackgroundUpdating {
	DNSLog( @"[TheadTitleViewController] stopBackgroundUpdating - trying to stop" );
	isTryingToStopUpdateDict_ = YES;
	while( 1 ) {
		[NSThread sleepForTimeInterval:0.25];
		if( isFinishedUpdateDict_ )
			break;
	}
	DNSLog( @"[TheadTitleViewController] stopBackgroundUpdating - has stopped" );
	return YES;
}

#pragma mark UIViewControllerDelegate

- (void)viewWillAppear:(BOOL)animated {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedThread removeAllObjects];
	[NSThread detachNewThreadSelector:@selector(updateSubjectDictionaryFromTail) toTarget:self withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	DNSLog( @"[BoardViewController] viewWillDisappear:animated" );
	[self stopBackgroundUpdating];
	[downloader_ cancel];
}

- (void)viewDidLoad {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

#pragma mark Original method

- (void) reloadTableView {
	NSIndexPath *tableSelection = [tableView_ indexPathForSelectedRow];
	[tableView_ deselectRowAtIndexPath:tableSelection animated:NO];
	[tableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:0 animated:NO];
	[tableView_ reloadData];
}

- (void) limitBoardlistWithKeywords:(NSString*)keyword {
	[limitedList_ removeAllObjects];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	for( NSMutableDictionary *dict in db.subjectList ) {
		NSString* title = [dict objectForKey:@"title"];
		if( [title rangeOfString:keyword].location != NSNotFound ) {
			[limitedList_ addObject:dict];
		}
	}
	targetList_ = limitedList_;
	[tableView_ reloadData];
}

- (void) setUIToolbarReload {
	NSMutableArray *items = [NSMutableArray arrayWithArray:underToolbar_.items];
	[items removeLastObject];
    UIBarButtonItem *systemItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadAction:)] autorelease];
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

- (IBAction)openBookmarkAction:(id)sender {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[self presentModalViewController:app.baseBookmarkViewController animated:YES];
}

- (IBAction) cancelLoading:(id)sender {
	DNSLog( @"[MainViewController] cancelLoading:" );
	[downloader_ cancel];
	[self setUIToolbarReload];
}

- (IBAction)reloadAction:(id)sender {
	[self setUIToolbarStop];
	[downloader_ cancel];
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	NSString* boardPath = app.currentBoardPath;
	NSString* server = [db serverOfBoardPath:app.currentBoardPath];
	NSString* url = [NSString stringWithFormat:@"http://%@/%@/subject.txt", server, boardPath];
	[downloader_ startWithURL:url identifier:kThreadTitleViewSubjectTxt];
}

- (IBAction)searchAction:(id)sender {
	[UIView beginAnimations:@"start" context:nil];
	if( searchBar_.opaque ) {
		CGRect rect = tableView_.frame;
		rect.origin.y += 44;
		rect.size.height -= 44;
		tableView_.frame = rect;
		searchBar_.text = @"";
		[searchBar_ setAlpha:1.0f];
		
	}
	else {
		CGRect rect = tableView_.frame;
		rect.origin.y -= 44;
		rect.size.height += 44;
		tableView_.frame = rect;	
		
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		DataBase *db = app.mainDatabase;
		targetList_ = db.subjectList;
		[tableView_ reloadData];
		[searchBar_ setAlpha:0.0f];
	}
	searchBar_.opaque = !searchBar_.opaque;
	[UIView commitAnimations];
}

#pragma mark UISearchBar

- (void)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	DNSLog( @"[ThreadTitleViewController] searchBarShouldBeginEditing:" );
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DNSLog( @"[ThreadTitleViewController] searchBarSearchButtonClicked:" );
	[searchBar resignFirstResponder];
	[self limitBoardlistWithKeywords:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	DNSLog( @"[ThreadTitleViewController] searchBarCancelButtonClicked:" );
	[searchBar resignFirstResponder];
	[self searchAction:searchBar];
}

#pragma mark Downloader delegates

- (void) didFailLoadingWithIdentifier:(NSString*)identifier error:(NSError *)error isDifferentURL:(BOOL)isDifferentURL {
	DNSLog( @"[ThreadTitleViewController] didFailLoading - %@", identifier );
	[self setUIToolbarReload];
	
	if( isDifferentURL && ( [identifier isEqualToString:@"resume"] || [identifier isEqualToString:kThreadTitleViewDat] ) ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"DownloaderNetworkErrorMsg", nil) message:NSLocalizedString( @"DownloaderNetworkErrorDatFialed", nil)
													   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	else if( [identifier isEqualToString:@"resume"] ) {		
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		DataBase *db = app.mainDatabase;
		[db loadCurrentDat:[app.savedThread objectForKey:@"boardPath"] dat:[app.savedThread objectForKey:@"dat"]];
		[self pushNextThreadView];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"DownloaderNetworkErrorMsg", nil) message:[error localizedDescription]
														   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedThread removeAllObjects];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void) finishParseSubjectTxt {
	[tableView_ reloadData];
	[tableView_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:0 animated:NO];
	[NSThread detachNewThreadSelector:@selector(updateSubjectDictionaryFromTail) toTarget:self withObject:nil];
}

- (void) didFinishLoading:(id)data identifier:(NSString*)identifier {
	
	if( [identifier isEqualToString:kThreadTitleViewSubjectTxt] ) {
		[self stopBackgroundUpdating];
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		DataBase *db = app.mainDatabase;
		[db parseSubjectTxt:data ofBoardPath:app.currentBoardPath delegate:self];
	}
	
	if( [identifier isEqualToString:kThreadTitleViewDat] ) {
		NSDictionary *requestDict = [(NSHTTPURLResponse *)downloader_.lastResponse allHeaderFields];
		DNSLog( @"Content-Length:%@", [requestDict objectForKey:@"Content-Length"] );
		DNSLog( @"Last-Modified :%@", [requestDict objectForKey:@"Last-Modified"] );
		
		_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
		NSMutableDictionary*dict = app.savedThread;
		DataBase *db = app.mainDatabase;
		
		BOOL result = [db readRes:app.currentBoardPath dat:[dict objectForKey:@"dat"] data:data];
		
		if( result ) {
			[db setContentLength:[requestDict objectForKey:@"Content-Length"] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:[dict objectForKey:@"dat"] atBoardPath:app.currentBoardPath];
			[self pushNextThreadView];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", nil) message:NSLocalizedString( @"ErrorWrongDataRead", nil)
														   delegate:self cancelButtonTitle:NSLocalizedString( @"ErrorOKButton", nil) otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	if( [identifier isEqualToString:@"resume"] ) {
		
		if( [data length] > 0 ) {
			NSDictionary *requestDict = [(NSHTTPURLResponse *)downloader_.lastResponse allHeaderFields];
			DNSLog( @"resume get Content-Length:%@", [requestDict objectForKey:@"Content-Length"] );
			DNSLog( @"resume Last-Modified     :%@", [requestDict objectForKey:@"Last-Modified"] );
			
			_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
			NSMutableDictionary*dict = app.savedThread;
			DataBase *db = app.mainDatabase;
			
			BOOL result = [db readRes:app.currentBoardPath dat:[dict objectForKey:@"dat"] data:data];
			
			if( result ) {
				NSMutableDictionary *c = [db contentLengthAndLastModifiedDictOfDat:[dict objectForKey:@"dat"] atBoardPath:app.currentBoardPath];
				int previous_size = [[c objectForKey:@"Content-Length"] intValue];
				int current_size = [[requestDict objectForKey:@"Content-Length"] intValue];
				[db setContentLength:[NSString stringWithFormat:@"%d",previous_size+current_size] lastModified:[requestDict objectForKey:@"Last-Modified"] ofDat:[dict objectForKey:@"dat"] atBoardPath:app.currentBoardPath];
				[self pushNextThreadView];
			}
			else {
				[db loadCurrentDat:app.currentBoardPath dat:[dict objectForKey:@"dat"]];
				[self pushNextThreadView];
			}
		}
		else {		
			_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
			DataBase *db = app.mainDatabase;
			
			NSMutableDictionary*dict = app.savedThread;
			
			[db loadCurrentDat:app.currentBoardPath dat:[dict objectForKey:@"dat"]];
			[self pushNextThreadView];
		}
	}
	[self setUIToolbarReload];
}

- (void) pushNextThreadView {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	NSMutableDictionary*dict = app.savedThread;
	app.threadViewController.title = [dict objectForKey:@"title"];
//	[app.threadViewController setBoardPath:app.currentBoardPath dat:[dict objectForKey:@"dat"]];
	[app.threadViewController loadHTML];
	[[self navigationController] pushViewController:app.threadViewController animated:YES];
//	[app.threadViewController load];
}

#pragma mark UITableView delegates

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 Return the index titles for each of the sections (e.g. "A", "B", "C"...).
	 Use key-value coding to get the value for the key @"letter" in each of the dictionaries in list.
	 */
	
	NSMutableArray *ary = [NSMutableArray array];
	
	int i;
	for( i = 0; i <= [targetList_ count] / ROW_PER_SECTION; i++ ) {
		//[ary addObject:[NSString stringWithFormat:@"%d", i * 100]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( section == [targetList_ count] / ROW_PER_SECTION ) {
		return ( [targetList_ count] % ROW_PER_SECTION );
	}
	else
		return ROW_PER_SECTION;
//	return [targetList_ count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	return [NSString stringWithFormat:@"%d - ", section*ROW_PER_SECTION+1];
	//return [index_ objectAtIndex:section];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int index_row = indexPath.section * ROW_PER_SECTION + indexPath.row;
	
	NSMutableDictionary*dict = [targetList_ objectAtIndex:index_row];
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
	
	NSMutableDictionary *c = [db contentLengthAndLastModifiedDictOfDat:[dict objectForKey:@"dat"] atBoardPath:app.currentBoardPath];

//	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app.savedThread setObject:[dict objectForKey:@"dat"] forKey:@"dat"];
	[app.savedThread setObject:app.currentBoardPath forKey:@"boardPath"];
	[app.savedThread setObject:[dict objectForKey:@"title"] forKey:@"title"];
	
	if( c == nil ) {
		// new download
		NSString* server= [db serverOfBoardPath:app.currentBoardPath];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, app.currentBoardPath, [dict objectForKey:@"dat"]];		
		[downloader_ cancel];
		[self setUIToolbarStop];
		[downloader_ startWithURL:url identifier:kThreadTitleViewDat];
	}
	else {
		NSString* server= [db serverOfBoardPath:app.currentBoardPath];
		NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@.dat", server, app.currentBoardPath, [dict objectForKey:@"dat"]];
		NSString* size = [c objectForKey:@"Content-Length"];
		NSString* last_update = [c objectForKey:@"Last-Modified"];
		DNSLog( @"URL           :%@", url );
		DNSLog( @"Content-Length:%@", size );
		DNSLog( @"Last-Modified :%@",last_update );
		[downloader_ cancel];
		[self setUIToolbarStop];
		[downloader_ startWithURL:url lastModified:last_update size:[size intValue] identifier:@"resume"];
	}
}


- (void) updateSubjectDictionaryFromTail {
	int i;
	id pool = [[NSAutoreleasePool alloc] init];
	int num;
	
	DNSLog( @"[ThreadTitleViewController] updateSubjectDictionaryFromTail - start!!!" );

	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	DataBase *db = app.mainDatabase;
/*	
	for( NSMutableDictionary *dict in db.subjectList ) {
		NSString* title = [dict objectForKey:@"title"];
		if( [title rangeOfString:keyword].location != NSNotFound ) {
			[limitedList_ addObject:dict];
		}
	}
*/
	
	@synchronized(self) {
		isFinishedUpdateDict_ = NO;
		isTryingToStopUpdateDict_ = NO;
		num = [db.subjectList count];
	}
	
	for( i =  num - 1; i >=0; i-- ) {
		@synchronized(self) {
			NSMutableDictionary* dict = [db.subjectList objectAtIndex:i];
			[ThreadTitleViewController updateSubjectDictionary:dict];
			if( isTryingToStopUpdateDict_ )
				break;
		}
	}
	@synchronized(self) {
		isFinishedUpdateDict_ = YES;
	}
	DNSLog( @"[ThreadTitleViewController] updateSubjectDictionaryFromTail - stop" );
	[pool release];
	[NSThread exit];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ThreadTitleViewCell *cell = (ThreadTitleViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ThreadTitleViewCell"];
	if (cell == nil) {
		NSArray* ary = [[NSBundle mainBundle] loadNibNamed:@"ThreadTitleCell" owner:self options:nil];
		
		for( id obj in ary ){
			if( [obj isKindOfClass:[ThreadTitleViewCell class]] ) {
				cell = obj;
				break;
			}
		}
		[(ThreadTitleViewCell *)cell setResNumberFontSize];
	}
	else {
	}
	
	int index_row = indexPath.section * ROW_PER_SECTION + indexPath.row;
	
	NSDictionary*dict = [targetList_ objectAtIndex:index_row];
	[ThreadTitleViewController updateSubjectDictionary:dict];
	((ThreadTitleViewCell *)cell).threadTitle = [dict objectForKey:@"title"];
	cell.res = [NSString stringWithFormat:@"%@:%@", NSLocalizedString( @"ThreadTitleCellPrompt", nil ),  [dict objectForKey:@"res"]];
	cell.number = [NSString stringWithFormat:@"%03d",index_row+1];
	
	// check existing cache file
	
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, app.currentBoardPath, [dict objectForKey:@"dat"]];
		
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
		cell.hiddenCacheImage = NO;
	else
		cell.hiddenCacheImage = YES;
	

	return cell;
}

@end
