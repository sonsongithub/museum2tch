//
//  _tchAppDelegate.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainNavigationController;
@class StatusManager;
@class ThreadRenderingView;
@class SNHUDActivityView;
@class HistoryController;

@interface _tchAppDelegate : NSObject <UIApplicationDelegate> {
	MainNavigationController		*navigationController_;
	sqlite3							*database_;
	StatusManager					*status_;
	
	SNHUDActivityView				*hud_;
	
    UIWindow						*window_;
	ThreadRenderingView				*webView_;
	HistoryController				*historyController_;
}
@property (nonatomic, assign) MainNavigationController *navigationController;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, assign) StatusManager *status;
@property (nonatomic, assign) ThreadRenderingView *webView;
@property (nonatomic, assign) UIWindow *window;
@property (nonatomic, assign) HistoryController *historyController;
- (void)gotoBoardOfPath:(NSString*)path;
- (void)gotoThreadOfDat:(int)dat path:(NSString*)path;
- (void)initializeDatabase;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)openHUDOfString:(NSString*)message;
- (void)openActivityHUDOfString:(id)obj;
- (void)closeHUD;
@end

