//
//  _tchAppDelegate.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "_tchAppDelegate.h"

#import "MainNavigationController.h"
#import "StatusManager.h"
#import "SNToolbarController.h"
#import "ThreadRenderingView.h"
#import "SNHUDActivityView.h"
#import "HistoryController.h"

#import "CategoryViewController.h"
#import "BoardViewController.h"
#import "TitleViewController.h"
#import "ThreadViewController.h"

@implementation _tchAppDelegate

@synthesize navigationController = navigationController_;
@synthesize database = database_;
@synthesize status = status_;
@synthesize webView = webView_;
@synthesize window = window_;
@synthesize historyController = historyController_;

- (void)gotoBoardOfPath:(NSString*)path {
	DNSLogMethod
	int numberOfViewControllers = [navigationController_.viewControllers count];
	if( numberOfViewControllers < 2 ) {
		BoardViewController* con = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
	}
	if( numberOfViewControllers < 3 ) {
		TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
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
	}
	if( numberOfViewControllers < 3 ) {
		TitleViewController* con = [[TitleViewController alloc] initWithStyle:UITableViewStylePlain];
		[navigationController_ pushViewController:con animated:NO];
	}
	if( numberOfViewControllers < 4 ) {
		ThreadViewController* con = [[ThreadViewController alloc] initWithNibName:nil bundle:nil];
		[navigationController_ pushViewController:con animated:NO];
		[(ThreadViewController*)con open2chLinkwithPath:path dat:dat];
	}
	else {
		UIViewController* con = navigationController_.topViewController;
		if( [con isKindOfClass:[ThreadViewController class]] )
			[(ThreadViewController*)con open2chLinkwithPath:path dat:dat];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIAppDelegate = self;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	DocumentFolderPath = [documentsDirectory retain];
	
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window_ makeKeyAndVisible];
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeDatabase];
	
	status_ = [[StatusManager alloc] init];
	CategoryViewController *con = [[CategoryViewController alloc] initWithStyle:UITableViewStylePlain];
	navigationController_ = [[MainNavigationController alloc] initWithRootViewController:con];
	navigationController_.view.frame = CGRectMake( 0, 20, 320, 460 );
		
	[window_ addSubview:navigationController_.view];
	[navigationController_.view addSubview:navigationController_.toolbar];
	[con release];
	
	hud_ = [[SNHUDActivityView alloc] init];
	
	historyController_ = [[HistoryController alloc] init];
	
	webView_ = [[ThreadRenderingView alloc] initWithFrame:CGRectZero];
	webView_.detectsPhoneNumbers = NO;
	webView_.backgroundColor = [UIColor whiteColor];
	webView_.scalesPageToFit = NO;
	webView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
}

- (void)applicationWillTerminate:(UIApplication *)application {
	DNSLogMethod
	DNSLog( @"Category - (%d) - %@", status_.categoryID, status_.categoryTitle );
	DNSLog( @"Board    - (%@) - %@", status_.path, status_.boardTitle );
	DNSLog( @"Thread   - (%d) - %@", status_.dat, status_.threadTitle );
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	DNSLogMethod
}

- (void)dealloc {
	sqlite3_close( database_ );
	[hud_ release];
	[DocumentFolderPath release];
	[navigationController_ release];
    [window_ release];
	[webView_ release];
	[historyController_ release];
    [super dealloc];
}

#pragma mark Method for HUD

- (void) openHUDOfString:(NSString*)message {
	if( hud_.superview == nil ) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[message retain];	// add retain count, for another thread.
		[NSThread detachNewThreadSelector:@selector(openActivityHUDOfString:) toTarget:self withObject:message];
	}
}

- (void) openActivityHUDOfString:(id)obj {
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

- (void) closeHUD {
	if( hud_.superview != nil ) {
		while( [[UIApplication sharedApplication] isIgnoringInteractionEvents] ) {
			DNSLog( @"try to cancel ignoring interaction" );
			[NSThread sleepForTimeInterval:0.05];
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
		[hud_ dismiss];
	}
}

#pragma mark Original method

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

@end
