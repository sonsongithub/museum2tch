#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "InfoViewController.h"

extern NSString *kDismissInfoViewMsg;

@interface BaseInfoViewController : UIViewController {
    IBOutlet UINavigationController *InfoNavController_;
    IBOutlet UIBarButtonItem		*closeButton_;
	
    IBOutlet UITableView	*tableView_;
	unsigned long long		allCacheSize_;
	NSMutableDictionary		*cells_;
	volatile BOOL			isFinishedCheckSize_;
	volatile BOOL			isTryingToStopCheckSize_;
}
- (IBAction)closeAction:(id)sender;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void) dealloc;
- (void) dismissInfoView:(NSNotification *)notification;
- (void) viewDidLoad;
@end
