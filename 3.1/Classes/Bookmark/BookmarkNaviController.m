//
//  BookmarkNaviController.m
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkNaviController.h"
#import "BookmarkViewController.h"
#import "ThreadViewController.h"
#import "global.h"
#import "_tchAppDelegate.h"

@implementation BookmarkNaviController

@synthesize toolbar = toolbar_;
@synthesize delegate = delegate_;
@synthesize isNeedUpdate = isNeedUpdate_;

NSString* kNotificationSuccessOpenThreadFromBookmark = @"kNotificationSuccessOpenThreadFromBookmark";
NSString* kNotificationFailedOpenThreadFromBookmark = @"kNotificationFailedOpenThreadFromBookmark";

#pragma mark Class Method

+ (BookmarkNaviController*) defaultController {
	BookmarkViewController* viewcontroller = [BookmarkViewController defaultController];
	BookmarkNaviController* obj = [[BookmarkNaviController alloc] initWithRootViewController:viewcontroller];
	obj.isNeedUpdate = YES;
	[viewcontroller release];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:obj 
											 selector:@selector(success)
												 name:kNotificationSuccessOpenThreadFromBookmark
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:obj 
											 selector:@selector(failed)
												 name:kNotificationFailedOpenThreadFromBookmark
											   object:nil];
	
	obj.view.frame = CGRectMake( 0, 0, 320, 416);
	obj.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, 416, 320, 44)];
	[obj.view addSubview:obj.toolbar];
	[obj.toolbar release];
	
	return obj;
}

#pragma mark Original Method to Controll Toolbar

- (void) toolbarOfBookmarkViewWithDelegate:(id)delegate editingFlag:(BOOL)flag {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	if( flag ) {
		UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Done", nil ) style:UIBarButtonItemStyleBordered target:delegate action:@selector(pushDone:)];
		[array addObject:item];
		[item release];
	}
	else {
		UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Edit", nil ) style:UIBarButtonItemStyleBordered target:delegate action:@selector(pushEdit:)];
		[array addObject:item];
		[item release];
	}
	
	[toolbar_ setItems:array animated:YES];
	
	[array release];
}

- (void) toolbarOfHistoryViewWithDelegate:(id)delegate {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Edit", nil ) style:UIBarButtonItemStyleBordered target:delegate action:@selector(pushEdit:)];
	[array addObject:item];
	[item release];
	[toolbar_ setItems:array animated:YES];
	
	[array release];
}

#pragma mark Original Method

- (void) open:(NSDictionary*)dict {
	[UIAppDelegate.downloder cancel];
	
	int categoryIndex;
	int boardIndex;
	
	if( [dict objectForKey:@"dat"] != nil ) {
		if( ![UIAppDelegate.bbsmenu getCategoryIndex:&categoryIndex andBoardIndex:&boardIndex ofBoardPath:[dict objectForKey:@"boardPath"]] )
			return;
		
		[UIAppDelegate.savedThread removeAllObjects];
		[UIAppDelegate.savedThread setObject:[dict objectForKey:@"dat"] forKey:@"dat"];
		[UIAppDelegate.savedThread setObject:[dict objectForKey:@"boardPath"] forKey:@"boardPath"];
		[UIAppDelegate.savedThread setObject:[dict objectForKey:@"title"] forKey:@"title"];
	
		[UIAppDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:categoryIndex]];
		[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:boardIndex]];
		
		[UIAppDelegate backToSavedStatus];
	}
	else {
		if( ![UIAppDelegate.bbsmenu getCategoryIndex:&categoryIndex andBoardIndex:&boardIndex ofBoardPath:[dict objectForKey:@"boardPath"]] )
			return;
		
		[UIAppDelegate.savedThread removeAllObjects];
		[UIAppDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:categoryIndex]];
		[UIAppDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:boardIndex]];
		[UIAppDelegate backToSavedStatus];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)close {
	isNeedUpdate_ = YES;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)success {
	[self close];
}

- (void)failed {
	[UIAppDelegate closeHUD];
}

#pragma mark Override

- (void) dealloc {
	DNSLog( @"[BookmarkNaviController] dealloc" );
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
