//
//  SearchViewController.h
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

@class SearchViewToolbarController;
@class SearchTerminateCell;

@interface SearchViewController : SNTableViewController <UISearchBarDelegate> {
	UISearchBar						*searchBar_;
	SearchViewToolbarController		*toolbarController_;
	NSMutableArray					*cellInfo_;
	NSString						*prevSearchText_;
	BOOL							loading_;
	SearchTerminateCell				*terminateCell_;
	BOOL							searchFinished_;
	int								page_;
}
@property (nonatomic, retain) NSString* prevSearchText;
#pragma mark Button Event
- (void)pushBrazil:(id)sender;
- (void)parseSearchResult:(NSData*)data;
- (void)pushDoneButton:(id)sender;
- (void)startSearch:(NSString*)searchWord;
@end
