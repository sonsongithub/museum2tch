//
//  RootViewController.h
//  scroller
//
//  Created by sonson on 08/12/15.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

typedef enum {
	ThreadViewSearchBarHidden,
	ThreadViewSearchBarShown,
	ThreadViewKeyboardShown
}ThreadViewSearchBarStatus;

@class AsciiPopupViewController;
@class AnchorPopupViewController;
@class ThreadViewToolbarController;
@class Dat;
@class PopupLabel;

@interface ThreadViewController : SNTableViewController <UISearchBarDelegate, UIActionSheetDelegate> {
	AnchorPopupViewController	*anchorPopupController_;
	AsciiPopupViewController	*asciiPopupViewController_;
	ThreadViewToolbarController	*toolbarController_;
	NSString					*candidatePath_;
	int							candidateDat_;
	PopupLabel					*titleLabel_;
	
	NSMutableArray				*currentArray_;
	UISearchBar					*searchbar_;
	Dat							*threadDat_;
	Dat							*candidateThreadDat_;
	NSMutableArray				*searchedArray_;
}
@property (nonatomic, retain) Dat *threadDat;
@property (nonatomic, retain) Dat *candidateThreadDat;
@property (nonatomic, retain) NSString *candidatePath;
@property (nonatomic, assign) int candidateDat;
#pragma mark Push botton method
- (void)pushComposeButton:(id)sender;
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushAddButton:(id)sender;
- (void)pushBookmarkButton:(id)sender;
- (void)pushBackButton:(id)sender;
- (void)pushForwardButton:(id)sender;
#pragma mark Setup NavigationControll bar
- (void)showReloadButton;
- (void)showStopButton;
#pragma mark Method to load, set up thread data
- (void)tryToOpen;
- (void)tryToStartDownloadThreadWithCandidateThreadInfo;
- (void)setCandidateData;
- (void)loadThreadWithoutAddingHistory:(NSDictionary*)threadInfo;
- (void)searchWithText:(NSString*)text;
#pragma mark Save scroll amount
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
#pragma mark Open new thread, external site and anchor
- (void)openWebBrowser:(NSString*)url;
- (void)open2chLinkwithPath:(NSString*)path dat:(int)dat;
- (void)openAnchor:(NSArray*)resNumberArray;
- (void)openAsciiView:(int)resNumber;
#pragma mark Push UIToolbar
- (void) pushSearchButton:(id)sender;
- (void) pushCloseSearchButton:(id)sender;
#pragma mark Start download method
- (void)downloadNewDat;
- (void)downloadResumeWithByte:(int)bytes lastModified:(NSString*)lastModified;
#pragma mark SearchView Management
- (void) showSearchBar;
- (void) hideSearchBar;
- (void)reduceTableViewToShowSearchBar:(BOOL)animated;
- (void)expandTableViewToCloseKeyboard:(BOOL)animated;
- (void)expandTableViewToCloseSearchBar:(BOOL)animated;
@end
