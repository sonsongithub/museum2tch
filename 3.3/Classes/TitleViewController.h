//
//  TitleViewController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"
#import "SubjectTxtController.h"

typedef enum {
	TitleViewShowAll,
	TitleViewShowNewComming,
	TitleViewShowCached
}TitleViewShowTarget;

@class TitleViewToolbarController;

@interface TitleViewController : SNTableViewController <UISearchBarDelegate> {
	NSMutableArray				*currentCell_;
	NSMutableArray				*allCell_;
	NSMutableArray				*newCell_;
	NSMutableArray				*cacheCell_;
	
	NSOperationQueue			*queue_;
	TitleViewToolbarController	*toolbarController_;
	UISearchBar					*searchbar_;
	
	NSString					*searchQuery_;
	NSString					*searchPrevQuery_;
	
	BOOL						isMultiThreading_;
	BOOL						isLoading_;
	int							titleVewShowTarget_;
	
	SubjectTxtController		*subjectTxtController_;
	BOOL						isSearching_;
	BOOL						isOpenedKeyboard_;
}
@property (nonatomic, retain) SubjectTxtController *subjectTxtController;
@property (nonatomic, retain) NSString *searchQuery;
@property (nonatomic, retain) NSString *searchPrevQuery;
@property (nonatomic, assign) BOOL isMultiThreading;
@property (nonatomic, assign) BOOL isLoading;
#pragma mark SQLite helper tool
- (void)update_reload_time;
- (BOOL)isNeedUpdate;
- (void)reload;
- (int) readRes:(NSString*)path dat:(int)dat;
- (void)selectWithQuery:(NSString*)query;
- (void)selectWithoutQuery;
- (void) reloadCell;
#pragma mark MultiThread
- (void)setIsLoading:(BOOL)newValue;
- (void)reloadTable;
- (void)setFinished;
#pragma mark Controll Update Thread
- (void)startToUpdateSubjectTable;
- (void)stopToUpdateSubjectTable;
- (void)restartTpUpdateSubjectTable;
#pragma mark Setup NavigationControll bar
- (void)showReloadButton;
- (void)showStopButton;
#pragma mark Push botton method
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushAddButton:(id)sender;
- (void)pushBookmarkButton:(id)sender;
- (void)pushSearchButton:(id)sender;
- (void)pushCloseSearchButton:(id)sender;
#pragma mark SearchView Management
- (void)reduceTableView;
- (void)backTableView;
- (void)showSearchView;
- (void)hideSearchView;
@end
