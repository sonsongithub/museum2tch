//
//  TitleViewController.h
//  2tchfree
//
//  Created by sonson on 08/08/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Downloader.h"

#define ROW_PER_SECTION					50

#ifdef _DEBUG
	#define AUTO_RELOAD_INTERVAL_SECOND		60
#else
	#define AUTO_RELOAD_INTERVAL_SECOND		600
#endif

@interface UpdateSubjectTxtOperation : NSOperation {
	NSMutableArray		*list_;
	NSOperationQueue	*queue_;
}
- (id)initWithMutableArray:(NSMutableArray*)list queue:(NSOperationQueue*)qq;
@end

@interface TitleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DownloaderDelegate, UISearchBarDelegate, UIActionSheetDelegate> {
	UITableView			*tableView_;
	UISearchBar			*searchbar_;

	NSMutableArray		*searchedList_;
	NSMutableArray		*targetList_;
	
	NSOperationQueue	*queueToUpdateSubjectTxt_;
	
	UIActionSheet		*confirmBookmarkAddSheet_;
}

#pragma mark Original method - Update Cell Dictionary
- (void) updateSubjectDictionaryFromTail;
#pragma mark Original Method
- (BOOL) restoreDataFromCache;
- (void) initializeSearchBar;
- (void) pushBookmarkButton:(id)sender;
- (void) pushNextView;
- (void) pushReloadButton:(id)sender;
- (void)pushStopButton:(id)sender;
- (void)pushReplyButton:(id)sender;
- (void)pushSearchButton:(id)sender;
- (void) doSearch:(NSString*)keyword;
- (void) clearSearchStatus;
- (void) toggleReloadButton;
- (void) toggleStopButton;
- (void) toggleInfoViewButton;

@end
