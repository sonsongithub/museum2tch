//
//  _tchAppDelegate.h
//  2tch
//
//  Created by sonson on 08/05/14.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DataBase.h"

#import "MainNavigationController.h"
#import "BoardViewController.h"
#import "ThreadTitleViewController.h"
#import "ThreadViewController.h"
#import "BaseInfoViewController.h"
#import "BaseBookmarkViewController.h"
#import "ReplyViewController.h"

//#ifdef TARGET_IPHONE_SIMULATOR
//#ifdef TARGET_OS_IPHONE

@interface _tchAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow				*window;
	IBOutlet MainNavigationController *mainNavigationController_;
	DataBase						*mainDatabase_;
	
	//
	NSMutableDictionary				*savedThread_;
	NSMutableArray					*savedLocation_;
	
	// all view controllers
	BoardViewController				*boardViewCon_;
	ThreadTitleViewController		*threadTitleViewCon_;
	ThreadViewController			*threadViewCon_;
	BaseInfoViewController			*baseInfoViewCon_;
	BaseBookmarkViewController		*baseBookmarkViewCon_;
	ReplyViewController				*replyViewCon_;
	
	BOOL							isAutorotateEnabled_;
	
	NSString	*currentCategory_;
	NSString	*currentBoardPath_;
	NSString	*currentDat_;
}
@property (nonatomic, retain) NSString					*currentCategory;
@property (nonatomic, retain) NSString					*currentBoardPath;
@property (nonatomic, retain) NSString					*currentDat;

@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) MainNavigationController	*mainNavigationController;
@property (nonatomic, assign) DataBase					*mainDatabase;
@property (nonatomic, assign) BoardViewController		*boardViewController;
@property (nonatomic, assign) ThreadTitleViewController	*threadTitleViewController;
@property (nonatomic, assign) ThreadViewController		*threadViewController;
@property (nonatomic, assign) BaseInfoViewController	*baseInfoViewController;
@property (nonatomic, assign) BaseBookmarkViewController*baseBookmarkViewController;
@property (nonatomic, assign) ReplyViewController		*replyViewController;

@property (nonatomic, assign) NSMutableDictionary		*savedThread;
@property (nonatomic, assign) NSMutableArray			*savedLocation;

@property (nonatomic, assign) BOOL						isAutorotateEnabled;

#pragma mark Override method
- (void) awakeFromNib;
- (void)dealloc;
#pragma mark UIApplicationDelegate
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)applicationDidFinishLaunching:(UIApplication *)application;

@end

