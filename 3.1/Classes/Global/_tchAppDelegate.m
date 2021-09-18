//
//  _tchfreeAppDelegate.m
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "ThreadViewController.h"
#import "CategoryViewController.h"
#import "BookmarkViewController.h"
#import "HistoryViewController.h"
#import "TitleViewController.h"
#import "BoardViewController.h"
#import "global.h"

@implementation _tchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize toolbarController;
@synthesize downloder = downloder_;
@synthesize bbsmenu = bbsmenu_;
@synthesize subjectTxt = subjectTxt_;
@synthesize bookmark = bookmark_;
@synthesize history = history_;
@synthesize savedLocation = savedLocation_;
@synthesize savedThread = savedThread_;
@synthesize threadDat = threadDat_;
@synthesize bookmarkNaviController = bookmarkNaviController_;

#pragma mark Accessor

- (BookmarkNaviController*)bookmarkNaviController {
	if( bookmarkNaviController_ == nil ) {
		bookmarkNaviController_ = [BookmarkNaviController defaultController];
		bookmarkNaviController_.delegate = navigationController;
		return bookmarkNaviController_;
	}
	else
		return bookmarkNaviController_;
}

- (BBSMenu*)bbsmenu {
	if( bbsmenu_ == nil ) {
		bbsmenu_ = [BBSMenu BBSMenuWithDataFromCache];
		return bbsmenu_;
	}
	else
		return bbsmenu_;
}

- (ThreadDat*)threadDat {
	if( threadDat_ == nil ) {
		threadDat_ = [ThreadDat ThreadDatFromEvacuation];
		return threadDat_;
	}
	else
		return threadDat_;
}

- (Bookmark*)bookmark {
	if( bookmark_ == nil ) {
		bookmark_ = [Bookmark defaultBookmark];
		return bookmark_;
	}
	else
		return bookmark_;
}

- (History*)history {
	if( history_ == nil ) {
		history_ = [History defaultHistory];
		return history_;
	}
	else
		return history_;
}

#pragma mark Original Method

- (void) initSaveInfo {
	DNSLog( @"[_tchAppDelegate] initSaveInfo" );
	// load the stored preference of the user's last location from a previous launch
	self.savedLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreLocation3.2"] mutableCopy];
	
	if( self.savedLocation == nil ) {
		DNSLog( @"[_tchAppDelegate] not saved making new state infomation" );
		self.savedLocation = [[NSMutableArray arrayWithObjects:
							   [NSNumber numberWithInteger:-1],	// item selection at 1st level (-1 = no selection)
							   [NSNumber numberWithInteger:-1],	// .. 2nd level
							   nil] retain];
	}
	
	// save into UserDefaults
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:self.savedLocation forKey:@"RestoreLocation3.2"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) initThreadInfo {
	DNSLog( @"[_tchAppDelegate] initThreadInfo" );
	// load the stored preference of the user's last location from a previous launch
	self.savedThread = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreThread3.2"] mutableCopy];
	
	if( self.savedThread == nil ) {
		DNSLog( @"[_tchAppDelegate] not saved making new thread infomation" );
		self.savedThread = [[NSMutableDictionary dictionary] retain];
	}
	
	// save into UserDefaults
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:self.savedThread forKey:@"RestoreThread3.2"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

typedef enum {
    _tchBackToThreadView,
    _tchBackToTitleView,
    _tchBackToBoardView,
    _tchBackToNone
} _tchBackToWhichView;

- (BOOL) checkCurrentViewControllersStack {
	DNSLog( @"[_tchAppDelegate] checkCurrentViewControllersStack" );
	
	NSArray *array = navigationController.viewControllers;
	
	if( [array count] > 1 ) {
		if( ![[array objectAtIndex:1] isKindOfClass:[BoardViewController class]] )
			return NO;
	}
	if( [array count] > 2 ) {
		if( ![[array objectAtIndex:2] isKindOfClass:[TitleViewController class]] )
			return NO;
	}
	if( [array count] > 3 ) {
		if( ![[array objectAtIndex:3] isKindOfClass:[ThreadViewController class]] )
			return NO;
	}
	DNSLog( @"[_tchAppDelegate] checkCurrentViewControllersStack -> OK" );
	return YES;
}

- (NSMutableArray*) stackBacktoSavedStatus:(_tchBackToWhichView)status {
#ifdef _DEBUG
	int pop_counter = 0;
	int alloc_counter = 0;
#endif
	if( ![self checkCurrentViewControllersStack] ) {
#ifdef _DEBUG
		pop_counter += ([[navigationController viewControllers] count] - 1);
#endif
		DNSLog( @"[_tchAppDelegate] checkCurrentViewControllersStack -> False" );
		[navigationController popToRootViewControllerAnimated:NO];

	}
	
	NSArray *array = navigationController.viewControllers;
	NSMutableArray *viewControllerStack = [[NSMutableArray alloc] init];

	BoardViewController* boardViewCon = nil;
	TitleViewController* titleViewCon = nil;
	ThreadViewController* threadViewCon = nil;
	
	switch( status ) {
		case _tchBackToBoardView:
			if( [array count] > 2 ) {
				[navigationController popToViewController:[array objectAtIndex:1] animated:NO];
#ifdef _DEBUG
				pop_counter++;
#endif
			}
			else {
				boardViewCon = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:boardViewCon];
#ifdef _DEBUG
				alloc_counter++;
#endif
			}
			break;
		case _tchBackToTitleView:
			if( [array count] > 3 ) {
				[navigationController popToViewController:[array objectAtIndex:2] animated:NO];
#ifdef _DEBUG
				pop_counter++;
#endif
			}
			else if( [array count] == 1 ) {
				boardViewCon = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:boardViewCon];
				titleViewCon = [[TitleViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:titleViewCon];
#ifdef _DEBUG
				alloc_counter+=2;
#endif
			}
			else if( [array count] == 2 ) {
				titleViewCon = [[TitleViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:titleViewCon];
#ifdef _DEBUG
				alloc_counter++;
#endif
			}
			break;
		case _tchBackToThreadView:
			if( [array count] == 1 ) {
				boardViewCon = [[BoardViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:boardViewCon];
				titleViewCon = [[TitleViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:titleViewCon];
				threadViewCon = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:threadViewCon];
#ifdef _DEBUG
				alloc_counter+=3;
#endif
			}
			else if( [array count] == 2 ) {
				titleViewCon = [[TitleViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:titleViewCon];
				threadViewCon = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:threadViewCon];
#ifdef _DEBUG
				alloc_counter+=2;
#endif
			}
			else if( [array count] == 3 ) {
				threadViewCon = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
				[viewControllerStack addObject:threadViewCon];
#ifdef _DEBUG
				alloc_counter++;
#endif
			}
			break;
	}
	for( id obj in viewControllerStack ) {
		[obj release];
	}
#ifdef _DEBUG
	DNSLog( @"Previous alloc=%d pop=%d", alloc_counter, pop_counter );
#endif	
	return viewControllerStack;
}

- (void) backToSavedStatus {
	_tchBackToWhichView status = _tchBackToNone;
	
	[ThreadDat removeEvacuation];
	[SubjectTxt removeEvacuation];
	
	if( self.bbsmenu == nil ) {
		[savedLocation_ replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
		[savedLocation_ replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
		[savedThread_ removeAllObjects];
		
		NSDictionary *savedLocationDict_temp = [NSDictionary dictionaryWithObject:self.savedLocation forKey:@"RestoreLocation3.2"];
		[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict_temp];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		savedLocationDict_temp = [NSDictionary dictionaryWithObject:self.savedThread forKey:@"RestoreThread3.2"];
		[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict_temp];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return;
	}
	
	// Which views is back to?
	if( [[self.savedLocation objectAtIndex:0] integerValue] >= 0 ) {
		status = _tchBackToBoardView;
	}
	if( [[self.savedLocation objectAtIndex:1] integerValue] >= 0 && status == _tchBackToBoardView ) {
		status = _tchBackToTitleView;
	}
	if( [self.savedThread objectForKey:@"dat"] && [self.savedThread objectForKey:@"boardPath"] && [self.savedThread objectForKey:@"title"] && status == _tchBackToTitleView ) {
		status = _tchBackToThreadView;
	}
	else if ( status == _tchBackToNone ) {
		return;
	}
	
	NSMutableArray* viewControllerStack = [self stackBacktoSavedStatus:status];
	
	// prepare for use of viewcontroller
	NSInteger selected_category_id = [[self.savedLocation objectAtIndex:0] integerValue];
	NSInteger selected_board_id = [[self.savedLocation objectAtIndex:1] integerValue];
	NSMutableArray *boardList  = [[bbsmenu_.categoryList objectAtIndex:selected_category_id] objectForKey:@"boardList"];
	NSMutableDictionary *dict = nil;
	if( selected_board_id != -1 )
		dict = [boardList objectAtIndex:selected_board_id];
	
	for( id obj in viewControllerStack ) {
		if( [obj isKindOfClass:[BoardViewController class]]) {
			BoardViewController* temp = obj;
			temp.title = [[bbsmenu_.categoryList objectAtIndex:[[self.savedLocation objectAtIndex:0] integerValue]] objectForKey:@"title"];
		}
		else if( [obj isKindOfClass:[TitleViewController class]]) {
			TitleViewController* temp = obj;
			[temp clearSearchStatus];
			temp.title = [[boardList objectAtIndex:selected_board_id] objectForKey:@"title"];
		}
	}
	for( id obj in [navigationController viewControllers] ) {
		if( [obj isKindOfClass:[BoardViewController class]]) {
			BoardViewController* temp = obj;
			temp.title = [[bbsmenu_.categoryList objectAtIndex:[[self.savedLocation objectAtIndex:0] integerValue]] objectForKey:@"title"];
		}
		else if( [obj isKindOfClass:[TitleViewController class]]) {
			TitleViewController* temp = obj;
			[temp clearSearchStatus];
			temp.title = [[boardList objectAtIndex:selected_board_id] objectForKey:@"title"];
		}
	}

	if( status == _tchBackToTitleView || status == _tchBackToThreadView ) {
		[subjectTxt_ release];
		subjectTxt_ = nil;
	}

	if( status == _tchBackToThreadView ) {
		ThreadViewController *tmp = nil;
		if( [[[navigationController viewControllers] lastObject] isKindOfClass:[ThreadViewController class]] )
		   tmp = [[navigationController viewControllers] lastObject];
		else if( [[viewControllerStack lastObject] isKindOfClass:[ThreadViewController class]] )
			tmp = [viewControllerStack lastObject];
		if( tmp )
			[tmp clearWebView];
		[self.threadDat release];
		self.threadDat = nil;
	}
	
	for( UIViewController*viewCon in viewControllerStack ) {
		[self.navigationController pushViewController:viewCon animated:NO];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSuccessOpenThreadFromBookmark object:self];
	[viewControllerStack release];
}

- (void) openHUDOfString:(NSString*)message {
	if( hud_.superview == nil ) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[message retain];	// add retain count, for another thread.
		[NSThread detachNewThreadSelector:@selector(openActivityHUDOfString:) toTarget:self withObject:message];
	}
}

- (void) closeHUD {
	while( [[UIApplication sharedApplication] isIgnoringInteractionEvents] ) {
		DNSLog( @"try to cancel ignoring interaction" );
		[NSThread sleepForTimeInterval:0.05];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	[hud_ dismiss];
}

- (void) openActivityHUDOfString:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		[hud_ setupWithMessage:(NSString*)obj];
		[obj release];
		[hud_ arrange:window.frame];
		[window addSubview:hud_];
	}
	[pool release];
	[NSThread exit];
}

- (void) openActivityHUD:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		[hud_ setupWithMessage:NSLocalizedString( @"Loading", nil )];
		[hud_ arrange:window.frame];
		[window addSubview:hud_];
	}
	[pool release];
	[NSThread exit];
}

#pragma mark Override

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIApp = [UIApplication sharedApplication];
	UIAppDelegate = [[UIApplication sharedApplication] delegate];
	
	downloder_ = [[Downloader alloc] init];
	[window addSubview:[navigationController view]];
	[navigationController.view addSubview:[toolbarController view]];
	[window makeKeyAndVisible];
	
	hud_ = [[SNHUDActivityView alloc] init];
	
	[self initSaveInfo];
	[self initThreadInfo];
	
	[self backToSavedStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	DNSLog( @"[_tchAppDelegate] applicationWillTerminate:" );	
	// Save data if appropriate
	[bookmark_ write];
	[history_ write];
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation_ forKey:@"RestoreLocation3.2"];
	[[NSUserDefaults standardUserDefaults] setObject:savedThread_ forKey:@"RestoreThread3.2"];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	if( bbsmenu_ != nil ) {
		[bbsmenu_ release];
		bbsmenu_ = nil;
	}
	if( bookmark_ != nil ) {
		[bookmark_ release];
		bookmark_ = nil;
	}
	if( history_ != nil && [navigationController.visibleViewController isKindOfClass:[HistoryViewController class]] ) {
		[history_ release];
		history_ = nil;
	}
	if( ![navigationController.visibleViewController isKindOfClass:[BookmarkViewController class]] && ![navigationController.visibleViewController isKindOfClass:[HistoryViewController class]] ) {
		[bookmarkNaviController_ release];
		bookmarkNaviController_ = nil;
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	DNSLog( @"[_tchAppDelegate] handleOpenURL - %@", [url absoluteURL] ); 
	// for original scheme
	return YES;
}

- (void)dealloc {
	DNSLog( @"[_tchAppDelegate] dealloc" );
	[bookmark_ release];
	[downloder_ release];
	[toolbarController release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
