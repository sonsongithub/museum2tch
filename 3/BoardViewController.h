#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Downloader.h"

extern NSString *kBoardViewCell;
extern NSString *kBoardViewCell;
extern NSString *kBoardViewSubjectTxt;

@interface BoardViewController : UIViewController {
	IBOutlet UIToolbar		*underToolbar_;
    IBOutlet UITableView	*tableView_;
	NSMutableArray			*boardList_;
	Downloader				*downloader_;
	
	NSMutableArray			*boards_;
}
#pragma mark Override 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void) viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void) dealloc;
#pragma mark UIViewControllerDelegate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
#pragma mark Original method

- (void) hideUIToolbarStop;
- (void) showUIToolbarStop;
- (IBAction) cancelLoading:(id)sender;
#pragma mark IBAction
- (IBAction)openBookmarkAction:(id)sender;
#pragma mark Downloader delegates
- (void) didFailLoadingWithIdentifier:(NSString*)identifier isDifferentURL:(BOOL)isDifferentURL;
- (void) finishParseSubjectTxt;
- (void) didFinishLoading:(id)data identifier:(NSString*)identifier;
#pragma mark UITableView delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
