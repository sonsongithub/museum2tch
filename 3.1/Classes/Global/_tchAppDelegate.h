//
//  _tchfreeAppDelegate.h
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolbarController.h"
#import "SNHUDActivityView.h"
#import "BBSMenu.h"
#import "SubjectTxt.h"
#import "Downloader.h"
#import "ThreadDat.h"
#import "Bookmark.h"
#import "History.h"
#import "BookmarkNaviController.h"

@interface _tchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window;
    UINavigationController	*navigationController;
	ToolbarController		*toolbarController;
	Downloader				*downloder_;
	
	BBSMenu					*bbsmenu_;
	SubjectTxt				*subjectTxt_;
	ThreadDat				*threadDat_;
	
	Bookmark				*bookmark_;
	History					*history_;
	
	NSMutableArray			*savedLocation_;
	NSMutableDictionary		*savedThread_;
	
	SNHUDActivityView		*hud_;
	BookmarkNaviController	*bookmarkNaviController_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet ToolbarController *toolbarController;
@property (nonatomic, assign) Downloader *downloder;
@property (nonatomic, assign) BBSMenu *bbsmenu;
@property (nonatomic, assign) ThreadDat *threadDat;
@property (nonatomic, assign) SubjectTxt *subjectTxt;
@property (nonatomic, assign) Bookmark *bookmark;
@property (nonatomic, assign) History *history;
@property (nonatomic, assign) NSMutableArray *savedLocation;
@property (nonatomic, assign) NSMutableDictionary *savedThread;
@property (nonatomic, assign) BookmarkNaviController *bookmarkNaviController;

#pragma mark Accessor
- (BBSMenu*)bbsmenu;
- (ThreadDat*)threadDat;
#pragma mark Original Method
- (void) initSaveInfo;
- (void) initThreadInfo;
- (void) backToSavedStatus;
- (void) openHUDOfString:(NSString*)message;
- (void) closeHUD;
- (void) openActivityHUDOfString:(id)obj;
- (void) openActivityHUD:(id)obj;

@end

