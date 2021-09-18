//
//  TitleViewController.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

typedef enum {
	TitleViewShowAll,
	TitleViewShowNewComming,
	TitleViewShowCached
}TitleViewShowTarget;

@class TitleViewToolbarController;
@class SubjectTxt;

@interface TitleViewController : SNTableViewController <UISearchBarDelegate, UIActionSheetDelegate> {
	TitleViewToolbarController	*toolbarController_;
	UISearchBar					*searchbar_;
	NSMutableArray				*currentCell_;
	SubjectTxt					*subjectTxt_;
	BOOL						isSearching_;
}
@property (nonatomic, retain) SubjectTxt *subjectTxt;
#pragma mark Reloading
- (void)reload;
#pragma mark Setup NavigationControll bar
- (void)updateTitle;
- (void)showReloadButton;
- (void)showStopButton;
#pragma mark Push botton method
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushAddButton:(id)sender;
- (void)pushBookmarkButton:(id)sender;
- (void)pushSearchButton:(id)sender;
- (void)pushCloseSearchButton:(id)sender;
#pragma mark Cell Resource Management
- (void)changeShownCell;
#pragma mark UISegmentation Coallback
- (void)segmentChanged:(id)sender;
#pragma mark IndexPath Management
- (int)indexFromIndexPath:(NSIndexPath *)indexPath;
#pragma mark SearchView Management
- (void)reduceTableViewToShowSearchBar:(BOOL)animated;
- (void)expandTableViewToCloseKeyboard:(BOOL)animated;
- (void)expandTableViewToCloseSearchBar:(BOOL)animated;
@end
