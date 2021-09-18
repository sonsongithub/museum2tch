//
//  _tchAppDelegate.m
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright sonson 2008. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "MainNavigationController.h"
#import "StatusManager.h"
#import "HistoryController.h"
#import "SNHUDActivityView.h"
#import "BookmarkController.h"
#import "EmojiConverter.h"

#import "CategoryViewController.h"
#import "BoardViewController.h"
#import "TitleViewController.h"
#import "ThreadViewController.h"


@implementation _tchAppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize database = database_;
@synthesize status = status_;
@synthesize historyController = historyController_;
@synthesize bookmarkController = bookmarkController_;

#pragma mark Method to set back the saved status

- (void)checkFirstRun {
	BOOL isFirstRun4 = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRun4"];
	DNSLog( @"FirstRun4.0 - %d", isFirstRun4 );
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRun4"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if( !isFirstRun4 ) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
															message:LocalStr( @"FirstRunMessage" )
														   delegate:nil
												  cancelButtonTitle:LocalStr( @"OK" )
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (void)setupFont {
	CGSize size;
	float thread_title_size = [[NSUserDefaults standardUserDefaults] floatForKey:@"threadTitleFontSize"];
	thread_title_size = thread_title_size < 1 ? 100 : thread_title_size;
	DNSLog( @"%f", thread_title_size );
	threadTitleFont = [[UIFont boldSystemFontOfSize:thread_title_size/100.0f*14] retain];
	threadTitleInfoFont = [[UIFont boldSystemFontOfSize:11] retain];

	float thread_size = [[NSUserDefaults standardUserDefaults] floatForKey:@"threadFontSize"];	
	thread_size = thread_size < 1 ? 100 : thread_size;
	threadFont = [[UIFont systemFontOfSize:thread_size/100.0f*14] retain];
	threadInfoFont = [[UIFont boldSystemFontOfSize:11] retain];
	
	size = [@"-" sizeWithFont:threadTitleFont constrainedToSize:CGSizeMake(300, 1300) lineBreakMode:UILineBreakModeWordWrap];
	HeightThreadTitleFont = size.height;
	size = [@"-" sizeWithFont:threadTitleInfoFont constrainedToSize:CGSizeMake(300, 1300) lineBreakMode:UILineBreakModeWordWrap];
	HeightThreadTitleInfoFont = size.height;
	
	size = [@"-" sizeWithFont:threadFont constrainedToSize:CGSizeMake(300, 1300) lineBreakMode:UILineBreakModeWordWrap];
	HeightThreadFont = size.height;
	size = [@"-" sizeWithFont:threadInfoFont constrainedToSize:CGSizeMake(300, 1300) lineBreakMode:UILineBreakModeWordWrap];
	HeightThreadInfoFont = size.height;
}

- (void)setBackStatus {
	DNSLogMethod
	
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window_ makeKeyAndVisible];
	
	CategoryViewController *con = [[CategoryViewController alloc] initWithStyle:UITableViewStylePlain];
	navigationController_ = [[MainNavigationController alloc] initWithRootViewController:con];
	navigationController_.view.frame = CGRectMake( 0, 20, 320, 460 );
	
	[window_ addSubview:navigationController_.view];
	[navigationController_.view addSubview:navigationController_.toolbar];
	[con release];
	
	if( status_.path != nil && status_.dat != 0 ) {
		[self gotoThreadOfDat:status_.dat path:status_.path];
	}
	else if( status_.path != nil && status_.dat == 0 ) {
		[self gotoBoardOfPath:status_.path];
	}
	else if( status_.path == nil && status_.dat == 0 && status_.categoryID != 0 ) {
		[self gotoCategoryOfID:status_.categoryID];
	}
}

- (void)gotoCategoryOfID:(int)categoryID {
	DNSLogMethod
	int numberOfViewControllers = [navigationController_.viewControllers count];
	if( numberOfViewControllers < 2 ) {
		BoardViewController* con = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[con release];
	}
	else {
		UIViewController* con = [[navigationController_ viewControllers] objectAtIndex:1];
		[navigationController_ popToViewController:con animated:NO];
	}
}

- (void)gotoBoardOfPath:(NSString*)path {
	DNSLogMethod
	int numberOfViewControllers = [navigationController_.viewControllers count];
	if( numberOfViewControllers < 2 ) {
		BoardViewController* con = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[con release];
	}
	if( numberOfViewControllers < 3 ) {
		TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[con release];
	}
	if( numberOfViewControllers == 3 ) {
	}
	else if( numberOfViewControllers == 4 ) {
		[navigationController_ popViewControllerAnimated:NO];
	}
	status_.path = path;
}

- (void)gotoThreadOfDat:(int)dat path:(NSString*)path {
	DNSLogMethod
	int numberOfViewControllers = [navigationController_.viewControllers count];
	if( numberOfViewControllers < 2 ) {
		BoardViewController* con = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[con release];
	}
	if( numberOfViewControllers < 3 ) {
		TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[con release];
	}
	if( numberOfViewControllers < 4 ) {
		ThreadViewController* con = [[ThreadViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
		[(ThreadViewController*)con open2chLinkwithPath:path dat:dat];
		[con release];
	}
	else {
		UIViewController* con = navigationController_.topViewController;
		if( [con isKindOfClass:[ThreadViewController class]] )
			[(ThreadViewController*)con open2chLinkwithPath:path dat:dat];
	}
}

#pragma mark Database management

- (void)initializeDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"2tch.sql"];
	
    if (sqlite3_open([path UTF8String], &database_) == SQLITE_OK) {
		DNSLog( @"[MyController] initializeDatabase - OK" );
		sqlite3_exec( UIAppDelegate.database, "PRAGMA auto_vacuum=1", NULL, NULL, NULL );
    }
	else {
		sqlite3_close( database_ );
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg( database_ ));
	}
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"2tch.sql"];
	DNSLog( writableDBPath );
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
		DNSLog( @"[MyController] createEditableCopyOfDatabaseIfNeeded - Opened sql file from libary" );
		return;
	}
	
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"2tch.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
		DNSLog( @"[MyController] createEditableCopyOfDatabaseIfNeeded - Error" );
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	else
		DNSLog( @"[MyController] createEditableCopyOfDatabaseIfNeeded - copy SQL" );
}

#pragma mark Method for HUD

- (void)openHUDOfString:(NSString*)message {
	if( hud_.superview == nil ) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[message retain];	// add retain count, for another thread.
		[NSThread detachNewThreadSelector:@selector(openActivityHUDOfString:) toTarget:self withObject:message];
	}
}

- (void)openActivityHUDOfString:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {
		[hud_ setupWithMessage:(NSString*)obj];
		[obj release];
		[hud_ arrange:window_.frame];
		[window_ addSubview:hud_];
	}
	[pool release];
	[NSThread exit];
}

- (void)closeHUD {
	if( hud_.superview != nil ) {
		while( [[UIApplication sharedApplication] isIgnoringInteractionEvents] ) {
			DNSLog( @"try to cancel ignoring interaction" );
			[NSThread sleepForTimeInterval:0.05];
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
		[hud_ dismiss];
	}
}

#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	DNSLogMethod
	kUpdateTitleNotification = @"kUpdateTitleNotification";
#ifdef _USE_EMOJI
	setup_emoji_table();		// setup emoji table pointer
#endif
	[self checkFirstRun];
	
	[self setupFont];
	
	UIAppDelegate = self;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	DocumentFolderPath = [documentsDirectory retain];
	
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
	
	
	hud_ = [[SNHUDActivityView alloc] init];
	historyController_ = [[HistoryController alloc] init];
	bookmarkController_ = [BookmarkController defaultBookmark];
		
	status_ = [[StatusManager alloc] init];
	[self setBackStatus];
	
	// for using handleOpenURL
	// [self performSelector:@selector(setBackStatus) withObject:nil afterDelay:0.0];
}

/*
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	DNSLogMethod
	// if use 2tch scheme, analyze URL and path, dat should be set into status.
	// after calling this method, then setBackStatus will be called.
	return NO;
}
*/

- (void)applicationWillTerminate:(UIApplication *)application {
	DNSLogMethod
	[bookmarkController_ writeWithEncoder];
	[status_ write];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[bookmarkController_ release];
	[historyController_ release];
	[navigationController_ release];
	[status_ release];
	[window_ release];
	[super dealloc];
}

@end
