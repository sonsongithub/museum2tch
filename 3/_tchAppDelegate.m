//
//  _tchAppDelegate.m
//  2tch
//
//  Created by sonson on 08/05/14.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "_tchAppDelegate.h"
#import "global.h"

@implementation _tchAppDelegate

@synthesize currentDat = currentDat_;
@synthesize currentCategory = currentCategory_;
@synthesize currentBoardPath = currentBoardPath_;

@synthesize window;
@synthesize mainNavigationController = mainNavigationController_;
@synthesize mainDatabase = mainDatabase_;

@synthesize threadViewController = threadViewCon_;
@synthesize boardViewController = boardViewCon_;
@synthesize threadTitleViewController = threadTitleViewCon_;
@synthesize baseInfoViewController = baseInfoViewCon_;
@synthesize baseBookmarkViewController = baseBookmarkViewCon_;
@synthesize replyViewController = replyViewCon_;

@synthesize savedThread = savedThread_;
@synthesize savedLocation = savedLocation_;

@synthesize isAutorotateEnabled = isAutorotateEnabled_;

#pragma mark Override method

- (void) awakeFromNib {
	// alloc database
	mainDatabase_ = [[DataBase alloc] init];
	
	// alloc all view controllers
	boardViewCon_ = [[BoardViewController alloc] initWithNibName:@"BoardViewController" bundle:nil];
	threadViewCon_ = [[ThreadViewController alloc] initWithNibName:@"ThreadViewController" bundle:nil];
	threadTitleViewCon_ = [[ThreadTitleViewController alloc] initWithNibName:@"ThreadTitleViewController" bundle:nil];
	baseInfoViewCon_ = [[BaseInfoViewController alloc] initWithNibName:@"BaseInfoViewController" bundle:nil];
	baseBookmarkViewCon_ = [[BaseBookmarkViewController alloc] initWithNibName:@"BaseBookmarkViewController" bundle:nil];
	replyViewCon_ = [[ReplyViewController alloc] initWithNibName:@"ReplyViewController" bundle:nil];
	
	// rotation flag
	isAutorotateEnabled_ = NO;
	
	DNSLog( @"[_tchAppDelegate] awakeFromNib" );
}

- (void)dealloc {
	[mainDatabase_ release];
	
	[boardViewCon_ release];
	[threadViewCon_ release];
	[threadTitleViewCon_ release];
	[baseInfoViewCon_ release];
	[baseBookmarkViewCon_ release];
	[replyViewCon_ release];
	
	[savedLocation_ release];
	[savedThread_ release];
	
	[window release];
	[super dealloc];
}

#pragma mark Original method

- (void) initSaveInfo {
	DNSLog( @"[_tchAppDelegate] initSaveInfo" );
	// load the stored preference of the user's last location from a previous launch
	self.savedLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreLocation"] mutableCopy];
	
	if( self.savedLocation == nil ) {
		DNSLog( @"[_tchAppDelegate] not saved making new state infomation" );
		self.savedLocation = [[NSMutableArray arrayWithObjects:
						  [NSNumber numberWithInteger:-1],	// item selection at 1st level (-1 = no selection)
						  [NSNumber numberWithInteger:-1],	// .. 2nd level
						  nil] retain];
	}
	else {
		// restore location(state of hierarchy menu)
		DNSLog( @"[_tchAppDelegate] will restore state" );
		for( NSNumber* obj in self.savedLocation ) {
			DNSLog( @"[_tchAppDelegate] initSaveInfo - load - %d", [obj intValue] );
		}
		[self.mainNavigationController.visibleViewController restoreWithSelectionArray:self.savedLocation];
	}
	
	// save into UserDefaults
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:self.savedLocation forKey:@"RestoreLocation"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self initThreadInfo];
}

- (void) initThreadInfo {
	DNSLog( @"[_tchAppDelegate] initThreadInfo" );
	// load the stored preference of the user's last location from a previous launch
	self.savedThread = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RestoreThread"] mutableCopy];
	
	if( self.savedThread == nil ) {
		DNSLog( @"[_tchAppDelegate] not saved making new thread infomation" );
		self.savedThread = [[NSMutableDictionary dictionary] retain];
	}
	else {
		// restore location(state of hierarchy menu)
		DNSLog( @"[_tchAppDelegate] will restore thread" );
		NSArray *keys = [self.savedThread allKeys];
		for( NSString* obj in keys ) {
			DNSLog( @"[_tchAppDelegate] initThreadInfo - %@ - %@", obj, [self.savedThread objectForKey:obj] );
		}
		
		if( [self.savedThread objectForKey:@"dat"] && [self.savedThread objectForKey:@"boardPath"] && [self.savedThread objectForKey:@"title"] ) {
		
		DataBase *db = self.mainDatabase;
		[db loadCurrentDat:[self.savedThread objectForKey:@"boardPath"] dat:[self.savedThread objectForKey:@"dat"]];
		self.threadViewController.title = [self.savedThread objectForKey:@"title"];
//		[self.threadViewController setBoardPath:[self.savedThread objectForKey:@"boardPath"] dat:[self.savedThread objectForKey:@"dat"]];
//		[self.threadViewController load];
		[self.threadViewController loadHTML];
		[self.mainNavigationController pushViewController:self.threadViewController animated:NO];
		}
		
	}
	
	// save into UserDefaults
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:self.savedThread forKey:@"RestoreThread"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark UIApplicationDelegate

- (void)applicationWillTerminate:(UIApplication *)application {
	DNSLog( @"[_tchAppDelegate] applicationWillTerminate" );
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation_ forKey:@"RestoreLocation"];
	[[NSUserDefaults standardUserDefaults] setObject:savedThread_ forKey:@"RestoreThread"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillTerminate" object:nil];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:[mainNavigationController_ view]];
	[window makeKeyAndVisible];
	
	//
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	[app initSaveInfo];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	// for original scheme
	return YES;
}

@end
