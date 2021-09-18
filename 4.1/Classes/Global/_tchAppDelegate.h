//
//  _tchAppDelegate.h
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright sonson 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainNavigationController;
@class StatusManager;
@class HistoryController;
@class SNHUDActivityView;
@class BookmarkController;

@interface _tchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*window_;
    MainNavigationController	*navigationController_;
	sqlite3						*database_;
	
	SNHUDActivityView			*hud_;
	HistoryController			*historyController_;
	StatusManager				*status_;
	BookmarkController			*bookmarkController_;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainNavigationController *navigationController;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) StatusManager *status;
@property (nonatomic, retain) HistoryController *historyController;
@property (nonatomic, retain) BookmarkController *bookmarkController;
#pragma mark Method to set back the saved status
- (void)setBackStatus;
- (void)gotoCategoryOfID:(int)categoryID;
- (void)gotoBoardOfPath:(NSString*)path;
- (void)gotoThreadOfDat:(int)dat path:(NSString*)path;
#pragma mark Database management
- (void)initializeDatabase;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)setupFont;
#pragma mark Method for HUD
- (void)openHUDOfString:(NSString*)message;
- (void)openActivityHUDOfString:(id)obj;
- (void)closeHUD;
@end

