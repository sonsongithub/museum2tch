#import "InfoViewController.h"
#import "_tchAppDelegate.h"
#import "InfoViewCell.h"
#import "MainNavigationController.h"
#import "MainViewController.h"
#import "global.h"

@implementation InfoViewController

- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
	self.title = NSLocalizedString(@"InfoViewTitle", @"");
	self.view.autoresizesSubviews = YES;
}

@end
