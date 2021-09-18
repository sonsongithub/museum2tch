#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MainViewController.h"

@interface MainNavigationController : UINavigationController {
    IBOutlet UIBarButtonItem* barButtonItem;
	IBOutlet MainViewController* mainViewController_;
	
	UIView*				progressBarView_;
	UIProgressView*		progressBar_;
	NSTimer*			progressTimer_;
	
}
@property (nonatomic, assign) MainViewController* mainViewController;
@end
