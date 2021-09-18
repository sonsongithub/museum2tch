//
//  ThreadViewController.h
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadViewIndex.h"
#import "Downloader.h"

@interface ThreadViewController : UIViewController <UIWebViewDelegate, DownloaderDelegate, UIActionSheetDelegate>{
	UIWebView			*webView_;
	ThreadViewIndex		*indexView_;
	id					memoryWarningDelegate_;
	
	NSMutableDictionary *tempClickedData_;
	BOOL				isPopupOpened_;
	UILabel				*titleLabel_;
	int					currentMode_;
	
	UIActionSheet		*confirmRenewalSheet_;
	UIActionSheet		*confirmBookmarkAddSheet_;
	
	BOOL				isAlreadyOpened_;
}
@property (nonatomic, assign) BOOL isPopupOpened;

#pragma mark Original Method
- (void) startDownload;
- (void) startToDownloadForRenewal;
- (void) updateSavedThread;
- (void) removeCacheAndPopView;
- (void) reload;
- (void) setThreadTitle:(NSString*) newTitle;
- (void) openThreadWithBoardPath:(NSString*)boardPath dat:(NSString*)dat title:(NSString*)title;
- (void) reloadNewThread;
- (void) changeDisplayMode:(int)mode;
#pragma mark Original Method - Toggle above navigationbar's buttons
- (void) toggleReloadButton;
- (void) toggleStopButton;
#pragma mark Original Method - UIWebView Javascript Controll
- (void) scrollToDIV:(int)index;
#pragma mark Original Method - make threadview resource
- (void) appendHeaderPart:(NSMutableString*)buff;
- (NSString*) makeHTMLwithMode:(int)mode;
#pragma mark Original method - function to process new downloaded NSData
- (void) openNewDat:(NSData*)data;
- (void) reloadDat:(NSData*)data;
- (void) renewalDat:(NSData*)data;
- (void) clearWebView;
#pragma mark Original Method - UIButton selector
- (void) addBookmark;
- (void) pushAddButton:(id)sender;
- (void) pushBookmarkButton:(id)sender;
- (void) pushTrashButton:(id)sender;
- (void)pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushReplyButton:(id)sender;
#pragma mark Original method - UIWebViewNavigation - Method
- (void) processHTTPLinkWithURLString:(NSString*)url;
- (void) processAnchorWithURLString:(NSString*)url;

@end
