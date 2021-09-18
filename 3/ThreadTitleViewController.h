#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Downloader.h"

#define ROW_PER_SECTION 50

extern NSString *kThreadTitleViewSubjectTxt;
extern NSString *kThreadTitleViewDat;

@interface ThreadTitleViewController : UIViewController {
	IBOutlet UIToolbar			*underToolbar_;
    IBOutlet UIBarButtonItem	*openBookmarkButton_;
    IBOutlet UIBarButtonItem	*searchButton_;
    IBOutlet UIBarButtonItem	*reloadButton_;
    IBOutlet UIBarButtonItem	*statusButton_;
    IBOutlet UISearchBar		*searchBar_;
    IBOutlet UITableView		*tableView_;
	
	int	board_id_;
	
	volatile BOOL	isFinishedUpdateDict_;
	volatile BOOL	isTryingToStopUpdateDict_;
	
	Downloader				*downloader_;
	NSMutableArray			*targetList_;
	NSMutableArray			*limitedList_;
	
	NSMutableArray			*index_;
	
	NSMutableArray			*threads_;
}
+ (BOOL) updateSubjectDictionary:(NSMutableDictionary*)dict;
#pragma mark Override
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void) dealloc;
- (void) prepareTable;
#pragma mark UIViewControllerDelegate
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidLoad;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
#pragma mark Original method
- (void) limitBoardlistWithKeywords:(NSString*)keyword;
- (void) setUIToolbarReload;
- (void) setUIToolbarStop;
#pragma mark IBAction
- (IBAction)openBookmarkAction:(id)sender;
- (IBAction) cancelLoading:(id)sender;
- (IBAction)reloadAction:(id)sender;
- (IBAction)searchAction:(id)sender;
#pragma mark UISearchBar
- (void)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
#pragma mark Downloader delegates
- (void) didFailLoadingWithIdentifier:(NSString*)identifier isDifferentURL:(BOOL)isDifferentURL;
- (void) finishParseSubjectTxt;
- (void) didFinishLoading:(id)data identifier:(NSString*)identifier;
- (void) pushNextThreadView;
#pragma mark UITableView delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
