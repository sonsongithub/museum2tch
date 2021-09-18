//
//  ThreadViewController.h
//  2tch
//
//  Created by sonson on 08/11/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThreadRenderingView;
@class ThreadViewToolbarController;
@class PopupMenuController;
@class ThreadViewIndex;
@class AnchorPopupViewController;

@interface ThreadViewController : UIViewController <UIWebViewDelegate> {
	ThreadRenderingView			*webView_;
	ThreadViewToolbarController	*toolbarController_;
	PopupMenuController			*popupMenuController_;
	ThreadViewIndex				*indexView_;
	AnchorPopupViewController	*anchorPopupController_;
	
	NSMutableArray				*resList_;
	UILabel						*titleLabel_;
	
	NSString					*candidatePath_;
	int							candidateDat_;
}
@property (nonatomic, retain) NSString *candidatePath;
@property (nonatomic, assign) int candidateDat;
@property (nonatomic, retain) NSMutableArray *resList;
#pragma mark Load thread to rendering view
- (void)loadThread;
- (void)loadThreadWithoutAddingHistory:(NSDictionary*)threadInfo;
#pragma mark Push button selectors
- (void)pushBackButton:(id)sender;
- (void)pushForwardButton:(id)sender;
#pragma delegate from child view or viewcontroller 
- (void)openWebBrowser:(NSString*)url;
- (void)open2chLinkwithPath:(NSString*)path dat:(int)dat;
- (void)openAnchor:(NSArray*)resNumberArray;
#pragma mark for WebView to render thread view
- (void)scrollToDIV:(int)index;
- (void)setFrom:(int)from to:(int)to;
#pragma mark Start download method
- (void)tryToStartDownloadThreadWithCandidateThreadInfo;
- (void)downloadNewDat;
- (void)downloadResumeWithByte:(int)bytes lastModified:(NSString*)lastModified;
#pragma mark Setup NavigationControll bar
- (void) updateTitle;
- (void)showReloadButton;
- (void)showStopButton;
#pragma mark Push botton method
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
@end
